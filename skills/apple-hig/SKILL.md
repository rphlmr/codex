---
name: apple-hig
description: Look up Apple's current Human Interface Guidelines when answering a platform design question, assessing HIG compliance, or checking recent guidance for iOS, iPadOS, or macOS.
---

# Apple Human Interface Guidelines

This skill reads Apple's HIG for iOS, iPadOS and macOS from developer.apple.com.
Guidance for tvOS, visionOS and watchOS is left out, as are pages that apply to
none of the three platforms.

Use the lookup script when a design decision depends on Apple's guidance.
Routine UI implementation or a requested visual tweak does not by itself
require a HIG consultation. Read the relevant page before attributing a rule
to Apple; quote only the wording needed to support the decision.

## Looking things up

Run the script with `python3` from this skill's directory:

```bash
python3 scripts/hig.py find toolbar search          # rank pages for some words
python3 scripts/hig.py read toolbars --platform macos
python3 scripts/hig.py read sheets --section "Platform considerations"
python3 scripts/hig.py grep destructive             # lines mentioning a term
python3 scripts/hig.py changes                      # Apple's revisions this year
python3 scripts/hig.py changes sidebars             # one page's whole history
python3 scripts/hig.py catalog                      # every page by Apple's groups
python3 scripts/hig.py read toolbars --live         # the page as of this minute
```

- The script keeps the pages in a local cache and downloads them again once
  the cache is a week old (about half a minute; the first lookup on a machine
  does the same). `refresh` forces it. Offline, it uses the old copy and says
  so. Each page states its source URL, the day it was fetched, and the
  platforms it applies to.
- `read` keeps the general guidance and the chosen platform's considerations:
  `ios` (iPhone), `ipados` or `macos`. An iPad question usually needs the iOS
  section too, so leave `--platform` at `all` unless the question is about one
  device only. `--section` keeps the headings containing its text.
- `find` ranks by title, abstract, headings and body; quote a phrase to keep
  it whole (`find "liquid glass"`). Many rules are bold sentences rather than
  headings, so when `--section` misses, `grep` shows the sentence and its page.
- `catalog` lists every page with its one-line abstract under Apple's groups.
  Browse it when Apple uses another word than the question (a "notice" is under
  Alerts or Feedback, an "inspector" under Split views and Panels).
- Most questions touch more than one page: a toolbar search field is in
  Toolbars and Search fields; a destructive confirmation is in Alerts, Action
  sheets and Buttons. Read each before answering.
- A date beside a page in `find` or `catalog` marks a revision in the last six
  months. When the answer rests on a recently revised page, `changes <page>`
  says what Apple changed, which matters when the app still ships the older
  behaviour.

## Answering

- Quote the sentences that decide the question, with the page title and URL,
  and say which platform they come from.
- Keep Apple's guidance apart from the conclusion you draw from it. The HIG
  states principles; applying one to a particular screen is a judgement, so
  say where the text is direct and where you are interpreting it.
- Say when the HIG is silent or leaves the choice open rather than inventing
  a rule. When two pages disagree, the page about the specific component
  (Action sheets for an action sheet) governs over a general one, and the
  answer should mention the difference. System apps (Mail, Notes, Finder,
  Reminders, System Settings) show how Apple applies it; name the app you take
  a pattern from.
- A project's own recorded decisions (its `AGENTS.md`, `CLAUDE.md`, design
  documents) win inside that project. When one departs from the HIG, point out
  the difference once and follow the project.
- The HIG describes behaviour, not code. For SwiftUI, UIKit or AppKit
  implementation, pair it with the Swift skills or Apple's developer
  documentation linked under a page's Resources.
