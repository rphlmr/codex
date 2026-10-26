---
name: devrel-voice
description: Writes blog posts, articles, upgrade guides, tutorials, slides, and social posts in the user's voice, a senior developer and DevRel who walks the reader through a change and what it breaks, not an AI explaining a topic. Use when drafting, rewriting, or reviewing any of these, even if the user only says "write a post about X" or "make this sound like me".
---

# DevRel Voice

The reader is a developer with a real project who wants to know what changes
for them, what can break, and what to type. The author has already hit the
traps and hands over the fix.

## Find the voice first

When the project already has published articles or posts, read two before
writing and match them: openings, heading style, callouts, and how code is
shown. Their text wins over this skill.

## Shape of an article

- Open with a short "in short" block: where the reader stands, the one
  biggest change, and the exact versions the examples use, before and after.
  A single section still names both versions in its first lines: the reader
  may land on it from a link.
- Headings state the change or the action, not a topic: "Config moves into
  each route", "Don't just delete `timeout`", "Before you start". Never
  "Overview" or "Considerations".
- For each change: what it is, a before/after code pair, what to do, and
  what breaks if you get it wrong.
- End on the next step: a checklist, a command, or the link to the next
  article. No recap.

## How to explain

- Talk to the reader as "you", in the present tense: "You now set it once,
  on the route". Write instructions, not praise for the feature.
- Define a term once, in bold, in one plain sentence, then use it. A small
  analogy is fine when it is exact ("in either order, like a + b = b + a").
- Say what happens to the reader's code or data ("deletes `full_name` and its
  data"), not which SQL or API call runs ("writes `DROP COLUMN`"). Code goes
  in a block, not inside a sentence.
- Leave out edge cases that distract from the lesson. Keep one only when the
  reader needs it to act.
- Make abstract cases concrete with a tiny scenario and named people ("Alice
  and Bob each open a branch") when the case is hard to picture. A short
  rewrite doesn't need one.
- Add the judgment call a senior would make: when the new option is safe and
  when it hurts ("retrying a `GET` is fine, retrying a `POST` that charges a
  card is not").
- Show the trap with its real consequences: the exact error message, the
  exit code, the prompt the tool shows, the data that gets lost. Put the
  consequence in bold: "**Your requests fail.**"
- Cover the paths a reader might take, including the tempting wrong one, and
  say which to pick: "You want neither. Use X instead."
- Say who a change does not affect, so those readers can skip it.
- Be honest about limits: what is not fixed yet, what is expected, and what
  the team is working on. Mark later changes with a dated update note
  instead of silently rewriting the text.

## Code and material

- Every example runs and type-checks against the stated version. Give the
  real install commands, for every package manager the project supports.
- Put a code or output block right after the sentence that introduces it.
- Prefer before/after pairs with the removed and added lines marked.
- Keep one small running example across the article instead of a new one
  per section.

## Sentences

- Short sentences, plain words, concrete nouns. One idea per paragraph.
- Use the reader's words and the tool's own wording: when the prompt says
  "renamed or created", so does the article.
- No AI tells: em dashes, "dive into", "leverage", "seamless", "robust",
  "powerful", "it's worth noting", "let's explore", question headings,
  adjective triplets, closing recaps.

## Rewriting someone's text

Keep every fact and add none: no new advice, numbers, steps, names, or
scenarios the original didn't have. Cut the hype, keep the meaning.

## Before handing a draft over

Read it as the reader with a project open. Cut any sentence that doesn't
change what they type or decide, and rewrite any paragraph that sounds like a
product page. Hand over the draft without commenting on this pass.
