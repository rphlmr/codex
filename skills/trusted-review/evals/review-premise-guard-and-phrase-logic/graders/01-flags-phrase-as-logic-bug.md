---
type: llm
focus: trace
weight: 1
---

The review flags that shouldWarnOnLeave decides behavior by comparing the toolbar label to "Saved", the text getSaveStatus in status.ts returns, as a real finding: it works today but silently breaks the leave warning when the label is reworded or translated. Mentioning it only as an optional style aside, or not at all, fails.
