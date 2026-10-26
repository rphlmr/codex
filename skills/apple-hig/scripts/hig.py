#!/usr/bin/env python3
"""Look up Apple's current Human Interface Guidelines for iOS, iPadOS and macOS.

Commands:
  find WORDS...                 rank pages for some words
  read SLUG [options]           print a page as Markdown
  grep TERM                     print the lines that mention a term
  changes [SLUG] [--since DATE] list Apple's dated revisions
  catalog                       list every page by Apple's groups
  refresh                       download every page again now

Pages come from developer.apple.com and are kept in a local cache that
refreshes itself once it is older than a week, so answers follow Apple's
latest text without a copy of it living in this skill.
"""

import argparse
import concurrent.futures
import datetime
import gzip
import json
import os
import re
import shutil
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

SITE = "https://developer.apple.com"
DATA = SITE + "/tutorials/data"
ROOT = "/design/human-interface-guidelines"

# Apple revises a few pages a month; a week keeps answers current cheaply.
MAX_AGE = datetime.timedelta(days=7)

PLATFORMS = ("iOS", "iPadOS", "macOS")
OTHER_PLATFORMS = ("tvOS", "visionOS", "watchOS")

# Platform overview pages that only concern other devices.
SKIPPED_PAGES = {
    "designing-for-tvos",
    "designing-for-visionos",
    "designing-for-watchos",
}

GROUP_TITLES = {
    "getting-started": "Getting started",
    "foundations": "Foundations",
    "patterns": "Patterns",
    "components": "Components",
    "inputs": "Inputs",
    "technologies": "Technologies",
}


def cache_dir():
    if os.environ.get("HIG_CACHE_DIR"):
        return Path(os.environ["HIG_CACHE_DIR"])

    if sys.platform == "darwin":
        return Path.home() / "Library" / "Caches" / "apple-hig"

    return Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "apple-hig"


CACHE = cache_dir()
PAGES = CACHE / "pages"
INDEX_PATH = CACHE / "index.json"


# Fetching


def fetch_json(url, attempts=3):
    request = urllib.request.Request(url, headers={"User-Agent": "apple-hig-skill"})

    for attempt in range(attempts):
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                body = response.read()

            if body[:2] == b"\x1f\x8b":
                body = gzip.decompress(body)

            return json.loads(body)
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError):
            if attempt == attempts - 1:
                raise

            time.sleep(2 ** (attempt + 1))


def page_url(slug):
    return f"{SITE}{ROOT}/{slug}"


def fetch_live(slug):
    return fetch_json(f"{DATA}{ROOT}/{slug}.json")


# Markdown conversion


def inline_text(nodes, references):
    parts = []

    for node in nodes or []:
        kind = node.get("type")

        if kind == "text":
            parts.append(node["text"])
        elif kind == "codeVoice":
            parts.append("`" + node["code"] + "`")
        elif kind == "emphasis":
            parts.append("*" + inline_text(node.get("inlineContent"), references) + "*")
        elif kind == "strong":
            parts.append("**" + inline_text(node.get("inlineContent"), references) + "**")
        elif kind == "reference":
            parts.append(reference_link(node["identifier"], references,
                                        node.get("overridingTitle")))
        elif kind == "link":
            title = node.get("title") or node.get("destination")
            parts.append(f"[{title}]({node.get('destination')})")
        elif "inlineContent" in node:
            parts.append(inline_text(node["inlineContent"], references))

    return "".join(parts)


def reference_link(identifier, references, wording=None):
    reference = references.get(identifier, {})
    title = wording or reference.get("title") or identifier.split("/")[-1]
    url = reference.get("url", "")

    if url.startswith("/"):
        url = SITE + url

    # Documentation paths are case-insensitive and Apple changes their case
    # between revisions; lowercase them so diffs show only real changes.
    if url.startswith(SITE + "/documentation/"):
        url = url.lower()

    if not url:
        return title

    return f"[{title}]({url})"


def block_text(node, references, depth=0):
    kind = node.get("type")
    indent = "  " * depth

    if kind == "heading":
        return "\n" + "#" * node["level"] + " " + node["text"] + "\n\n"

    if kind in ("paragraph", "small"):
        text = inline_text(node.get("inlineContent"), references).strip()

        if not text:
            return ""

        return indent + text + "\n\n"

    if kind in ("unorderedList", "orderedList"):
        lines = []

        for number, item in enumerate(node.get("items", []), start=1):
            body = "".join(
                block_text(child, references, depth + 1)
                for child in item.get("content", [])
            ).strip()
            marker = "- " if kind == "unorderedList" else f"{number}. "
            lines.append(indent + marker + body)

        return "\n".join(lines) + "\n\n"

    if kind == "aside":
        label = node.get("name") or node.get("style", "note").title()
        body = " ".join(
            block_text(child, references).strip() for child in node.get("content", [])
        )

        return f"> **{label}:** {body}\n\n"

    if kind == "table":
        return table_text(node, references)

    if kind == "links":
        return "".join(
            "- " + reference_link(identifier, references) + "\n"
            for identifier in node.get("items", [])
        ) + "\n"

    if kind == "row":
        return "".join(
            block_text(child, references, depth)
            for column in node.get("columns", [])
            for child in column.get("content", [])
        )

    if kind == "tabNavigator":
        tabs = []

        for tab in node.get("tabs", []):
            body = "".join(block_text(child, references) for child in tab.get("content", []))

            # Tabs that only switch between illustrations have no text.
            if body.strip():
                tabs.append(f"**{tab.get('title')}**\n\n{body}")

        return "".join(tabs)

    if isinstance(node.get("content"), list):
        return "".join(block_text(child, references, depth) for child in node["content"])

    # Images and videos carry no text beyond their captions.
    return ""


def table_text(node, references):
    lines = []

    for index, row in enumerate(node.get("rows", [])):
        cells = [
            " ".join(block_text(child, references).strip() for child in cell)
            .replace("\n", " ")
            .replace("|", "\\|")
            for cell in row
        ]
        lines.append("| " + " | ".join(cells) + " |")

        if index == 0:
            lines.append("|" + " --- |" * len(row))

    return "\n".join(lines) + "\n\n"


def page_markdown(page):
    references = page.get("references", {})
    body = "".join(
        block_text(block, references)
        for section in page.get("primaryContentSections", [])
        for block in section.get("content", [])
    )

    return re.sub(r"\n{3,}", "\n\n", body).strip() + "\n"


# Sections


def split_sections(markdown, level):
    """Split Markdown into (heading, text) pairs at one heading level.

    A section ends at the next heading of its level or above, so the text after
    the last one (heading None) holds whatever follows at a higher level.
    """
    sections = []
    heading = None
    lines = []

    for line in markdown.splitlines():
        match = re.match(r"(#{1,%d}) (.*)" % level, line)

        if match:
            sections.append((heading, "\n".join(lines)))
            heading = match.group(2).strip() if len(match.group(1)) == level else None
            lines = [line]
        else:
            lines.append(line)

    sections.append((heading, "\n".join(lines)))

    return sections


def names_platform(heading, platforms):
    return any(re.search(rf"\b{name}\b", heading) for name in platforms)


def filter_platforms(markdown, platforms):
    """Keep general guidance and the platform considerations for `platforms`."""
    kept = []

    for heading, text in split_sections(markdown, 2):
        if heading != "Platform considerations":
            kept.append(text)
            continue

        # The heading and its introduction come back without a heading name.
        kept.extend(
            body
            for name, body in split_sections(text, 3)
            if name is None or names_platform(name, platforms)
        )

    return re.sub(r"\n{3,}", "\n\n", "\n\n".join(kept)).strip() + "\n"


def change_log(markdown):
    entries = []

    for heading, text in split_sections(markdown, 2):
        if heading != "Change log":
            continue

        for line in text.splitlines():
            match = re.match(r"\| (\w+ \d{1,2}, \d{4}) \| (.*) \|$", line)

            if match:
                date = datetime.datetime.strptime(match.group(1), "%B %d, %Y").date()
                entries.append({"date": date.isoformat(), "change": match.group(2)})

    return entries


def headings(markdown):
    return [
        line.lstrip("#").strip()
        for line in markdown.splitlines()
        if re.match(r"#{2,3} ", line)
    ]


def unsupported_platforms(markdown):
    match = re.search(r"Not supported in ([^.*\n]+)", markdown)

    if not match:
        return []

    return [name for name in PLATFORMS + OTHER_PLATFORMS if name in match.group(1)]


# Crawl


def crawl():
    """Fetch every page reachable from the HIG's own collections."""
    pages = {}
    groups = {}
    frontier = ["human-interface-guidelines"]
    seen = set(frontier)

    with concurrent.futures.ThreadPoolExecutor(8) as pool:
        while frontier:
            slugs = frontier
            frontier = []
            fetched = pool.map(
                lambda slug: (slug, fetch_json(f"{DATA}/design/{slug}.json")
                              if slug == "human-interface-guidelines" else fetch_live(slug)),
                slugs,
            )

            for slug, page in fetched:
                pages[slug] = page
                children = [
                    identifier.split("/")[-1]
                    for section in page.get("topicSections", [])
                    for identifier in section.get("identifiers", [])
                ]

                for reference in page.get("references", {}).values():
                    url = reference.get("url", "")

                    if url.startswith(ROOT + "/") and "#" not in url:
                        children.append(url.split("/")[-1])

                if page.get("metadata", {}).get("role") == "collectionGroup":
                    groups[slug] = [
                        identifier.split("/")[-1]
                        for section in page.get("topicSections", [])
                        for identifier in section.get("identifiers", [])
                    ]

                for child in children:
                    if child not in seen:
                        seen.add(child)
                        frontier.append(child)

    return pages, groups


def group_of(slug, groups):
    """Return the top-level group and, for components, the subgroup."""
    for top in GROUP_TITLES:
        members = groups.get(top, [])

        if slug in members:
            return GROUP_TITLES[top], None

        for member in members:
            if slug in groups.get(member, []):
                return GROUP_TITLES[top], member

    return "Other", None


# Cache


def refresh():
    """Download every page and replace the cache in one step."""
    print("Downloading the HIG from developer.apple.com (about a minute).",
          file=sys.stderr, flush=True)

    fetched = datetime.datetime.now().astimezone()
    pages, groups = crawl()
    staging = CACHE / "pages.new"
    shutil.rmtree(staging, ignore_errors=True)
    staging.mkdir(parents=True)

    index = {"fetched": fetched.isoformat(timespec="seconds"), "groups": {}, "pages": {}}

    for slug, page in sorted(pages.items()):
        if page.get("metadata", {}).get("role") != "article":
            continue

        full = page_markdown(page)
        unsupported = unsupported_platforms(full)

        if slug in SKIPPED_PAGES or all(name in unsupported for name in PLATFORMS):
            continue

        group, subgroup = group_of(slug, groups)
        title = page["metadata"]["title"]
        abstract = inline_text(page.get("abstract"), page.get("references", {}))
        markdown = filter_platforms(full, PLATFORMS)
        write_page(staging / f"{slug}.md", title, slug, abstract, unsupported,
                   fetched.date().isoformat(), markdown)

        index["pages"][slug] = {
            "title": title,
            "abstract": abstract,
            "group": group,
            "subgroup": subgroup,
            "unsupported": unsupported,
            "headings": headings(markdown),
            "changes": change_log(full),
        }

    for title in GROUP_TITLES.values():
        index["groups"][title] = [
            slug for slug, entry in index["pages"].items() if entry["group"] == title
        ]

    shutil.rmtree(PAGES, ignore_errors=True)
    staging.rename(PAGES)
    INDEX_PATH.write_text(json.dumps(index, indent=1, ensure_ascii=False) + "\n")
    write_catalog(index)

    return index


def load_index():
    """Return the cached index, refreshing it first when it is a week old."""
    index = json.loads(INDEX_PATH.read_text()) if INDEX_PATH.exists() else None

    if index:
        fetched = datetime.datetime.fromisoformat(index["fetched"])

        if datetime.datetime.now().astimezone() - fetched < MAX_AGE:
            return index

    try:
        return refresh()
    except Exception as error:
        if index is None:
            sys.exit(f"Couldn't download the HIG ({error}); check the network and retry.")

        print(f"Couldn't refresh the HIG ({error}); using the copy of {index['fetched']}.",
              file=sys.stderr)

        return index


def write_page(path, title, slug, abstract, unsupported, fetched, markdown):
    supported = [name for name in PLATFORMS if name not in unsupported]
    header = [
        f"# {title}",
        "",
        f"Source: {page_url(slug)}",
        f"Fetched: {fetched}",
        f"Applies to: {', '.join(supported)}",
        "",
        abstract,
        "",
    ]
    path.write_text("\n".join(header) + "\n" + markdown)


def write_catalog(index):
    lines = [
        "# HIG catalog",
        "",
        f"Fetched {index['fetched']}. Read a page with `hig.py read <slug>`;"
        " a date marks a page Apple revised in the last six months.",
        "",
    ]

    for title, slugs in index["groups"].items():
        lines += [f"## {title}", ""]
        subgroups = {}

        # Components come in Apple's subgroups; other groups have none.
        for slug in slugs:
            subgroups.setdefault(index["pages"][slug].get("subgroup"), []).append(slug)

        for subgroup, members in sorted(subgroups.items(), key=lambda item: item[0] or ""):
            if subgroup:
                lines += [f"### {subgroup.replace('-', ' ').capitalize()}", ""]

            for slug in members:
                entry = index["pages"][slug]
                mark = recent_mark(entry)
                only = [name for name in PLATFORMS if name not in entry["unsupported"]]
                scope = "" if len(only) == len(PLATFORMS) else f" ({', '.join(only)} only)"
                lines.append(f"- `{slug}`{mark}{scope}: {entry['abstract']}")

            lines.append("")

    (CACHE / "catalog.md").write_text("\n".join(lines))


def recent_mark(entry):
    """Name the last revision when it is under six months old."""
    latest = max((item["date"] for item in entry["changes"]), default="")
    cutoff = (datetime.date.today() - datetime.timedelta(days=182)).isoformat()

    return f" (revised {latest})" if latest >= cutoff else ""


# Queries


def find(arguments):
    index = load_index()
    words = [word.lower() for word in arguments.words]
    results = []

    for slug, entry in index["pages"].items():
        title = entry["title"].lower()
        abstract = entry["abstract"].lower()
        heading_text = " ".join(entry["headings"]).lower()
        body = (PAGES / f"{slug}.md").read_text().lower()
        score = 0
        matched = 0

        for word in words:
            before = score
            # Match at the start of a word, so "search" finds "searching"
            # but not "research".
            pattern = re.compile(r"\b" + re.escape(word))

            if pattern.search(slug.replace("-", " ")) or pattern.search(title):
                score += 5

            if pattern.search(abstract):
                score += 2

            if pattern.search(heading_text):
                score += 2

            # How often a word recurs says how much the page is about it.
            score += min(3, len(pattern.findall(body)))
            matched += score > before

        # A page matching every word beats one that matches one word strongly.
        if score:
            results.append((score * matched, slug, entry))

    results.sort(key=lambda item: (-item[0], item[1]))

    for score, slug, entry in results[: arguments.limit]:
        print(f"{slug}{recent_mark(entry)}: {entry['abstract']}")

    if not results:
        print("No page matched. Try `hig.py grep` or `hig.py catalog`.")


def read(arguments):
    index = load_index()
    slug = arguments.slug

    if slug not in index["pages"]:
        sys.exit(f"Unknown page `{slug}`. Try `hig.py find` or `hig.py catalog`.")

    if arguments.live:
        page = fetch_live(slug)
        entry = index["pages"][slug]
        text = f"# {entry['title']}\n\nSource: {page_url(slug)}\n" \
            f"Fetched: {datetime.date.today().isoformat()} (live)\n\n" \
            f"{entry['abstract']}\n\n{page_markdown(page)}"
    else:
        text = (PAGES / f"{slug}.md").read_text()

    platforms = PLATFORMS if arguments.platform == "all" else (
        {"ios": "iOS", "ipados": "iPadOS", "macos": "macOS"}[arguments.platform],
    )
    text = filter_platforms(text, platforms)

    if arguments.section:
        text = pick_section(text, arguments.section)

    print(text)


def grep(arguments):
    index = load_index()
    pattern = re.compile(re.escape(arguments.term), re.IGNORECASE)
    shown = 0

    for slug in sorted(index["pages"]):
        for line in (PAGES / f"{slug}.md").read_text().splitlines():
            if pattern.search(line):
                print(f"{slug}: {line.strip()}")
                shown += 1

                if shown == arguments.limit:
                    print(f"(stopped at {shown} lines; raise --limit for more)")
                    return

    if not shown:
        print(f"No page mentions `{arguments.term}`.")


def pick_section(markdown, wanted):
    wanted = wanted.lower()
    header = page_header(markdown)
    matches = []

    for level in (2, 3):
        for heading, text in split_sections(markdown, level):
            # Skip a subsection already printed inside a matching section.
            if (
                heading
                and wanted in heading.lower()
                and not any(text.strip() in match for match in matches)
            ):
                matches.append(text.strip())

    if not matches:
        return header + f"\n\nNo section matching `{wanted}`. Sections: " + \
            ", ".join(headings(markdown)) + "\n"

    return header.strip() + "\n\n" + "\n\n".join(matches) + "\n"


def page_header(markdown):
    """Return the lines before the body: title, source, date, scope, abstract."""
    lines = markdown.splitlines()

    for number, line in enumerate(lines):
        if line.startswith("Fetched:"):
            rest = number + 1

            while rest < len(lines) and (
                not lines[rest].strip() or lines[rest].startswith("Applies to:")
            ):
                rest += 1

            return "\n".join(lines[: rest + 1])

    return lines[0] if lines else ""


def changes(arguments):
    index = load_index()

    if arguments.slug and arguments.slug not in index["pages"]:
        sys.exit(f"Unknown page `{arguments.slug}`.")

    # One page shows its whole history; all pages default to the last year.
    year_ago = (datetime.date.today() - datetime.timedelta(days=365)).isoformat()
    since = arguments.since or ("0000" if arguments.slug else year_ago)
    entries = [
        (item["date"], slug, item["change"])
        for slug, entry in index["pages"].items()
        if not arguments.slug or slug == arguments.slug
        for item in entry["changes"]
        if item["date"] >= since
    ]

    for date, slug, change in sorted(entries, reverse=True):
        print(f"{date}  {slug}: {change}")


def catalog(arguments):
    load_index()
    print((CACHE / "catalog.md").read_text())


def refresh_command(arguments):
    index = refresh()
    print(f"{len(index['pages'])} pages, fetched {index['fetched']}.", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)

    find_parser = commands.add_parser("find", help="rank pages for some words")
    find_parser.add_argument("words", nargs="+")
    find_parser.add_argument("--limit", type=int, default=8)
    find_parser.set_defaults(run=find)

    read_parser = commands.add_parser("read", help="print a page")
    read_parser.add_argument("slug")
    read_parser.add_argument("--platform", choices=("all", "ios", "ipados", "macos"),
                             default="all")
    read_parser.add_argument("--section", help="only headings containing this text")
    read_parser.add_argument("--live", action="store_true",
                             help="fetch the page now instead of reading the cache")
    read_parser.set_defaults(run=read)

    grep_parser = commands.add_parser("grep", help="lines mentioning a term")
    grep_parser.add_argument("term")
    grep_parser.add_argument("--limit", type=int, default=40)
    grep_parser.set_defaults(run=grep)

    changes_parser = commands.add_parser("changes", help="list dated revisions")
    changes_parser.add_argument("slug", nargs="?", help="one page's history")
    changes_parser.add_argument("--since", help="YYYY-MM-DD; default a year ago")
    changes_parser.set_defaults(run=changes)

    catalog_parser = commands.add_parser("catalog", help="list every page")
    catalog_parser.set_defaults(run=catalog)

    refresh_parser = commands.add_parser("refresh", help="download every page now")
    refresh_parser.set_defaults(run=refresh_command)

    arguments = parser.parse_args()
    arguments.run(arguments)


if __name__ == "__main__":
    main()
