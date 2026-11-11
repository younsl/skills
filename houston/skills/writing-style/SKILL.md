---
name: writing-style
description: Personal writing rules for prose meant for humans, including README, docs, Confluence pages, MR and PR bodies, Jira text, commit messages, Slack announcements, UI copy, and slides.
when_to_use: Whenever drafting or editing such text, and for requests like "간결하게", "문서화해줘", "가이드 작성", "슬랙 공지 작성", "하위 페이지로 정리", "구분선 제거", "emdash 금지", "N%로 축소". Not for code comments (global AGENTS.md), commit, push, and MR mechanics (use git-ship), or Jira fields and transitions (use jira-issue).
argument-hint: "[file or target]"
license: Apache-2.0
compatibility: Confluence rules assume mcp-atlassian storage-format writes
metadata:
  version: "1.1.0"
  category: style
  related: git-ship jira-issue
allowed-tools: Bash(grep *) Bash(wc *) Read Edit Write Grep Glob
user-invocable: true
disable-model-invocation: false
---

# Writing Style

## Output Requirements

- No em dash (—), en dash (–), middle dot (·), or arrow (→) as prose shorthand; rewrite as a sentence, comma, colon, or parentheses
- No horizontal rules (`---`, `***`) in bodies; headings separate sections. Table separators and frontmatter are exempt
- No emoji in titles or headings
- No semicolons in prose
- No colon in UI description, help, or tooltip prose. `Label: value` field labels keep theirs
- Bullets over tables; a table only when rows and columns are both meaningful axes
- One idea per bullet, no filler intro or recap
- Length requests ("N%로 축소") land within 5 points of N percent by character count (`wc -m`). Every shrink, "더 간결하게" included, keeps the existing section skeleton (every heading, same order) and every screenshot
- URLs wrapped on a keyword (`[Helm docs](https://example.com)` in markdown, `<a href>` in storage format), never raw; cross-repo MR or PR references as full URL links
- Unambiguous notation: no `4/4`-style shorthand that reads as a date; HTTP status as code plus reason (`403 Forbidden`)
- Shared documents use dates, never clock times. Text that configures or documents a schedule states exact times with timezone
- A date shown to readers carries its weekday in the text's language, computed with `date` rather than guessed, e.g. `2026-10-19 (Mon)`. Dates inside identifiers stay as they are
- No backtick spans or `<code>` around plain words in prose, wiki, Slack, or UI copy; reserve them for real identifiers in markdown that renders code. External GitHub issues use no backticks at all
- Chat replies to the user use no inline code spans. Identifiers go as plain text, real code in fenced blocks
- Markdown paragraphs are one line each; no hard wrapping
- Language follows the existing document; new public OSS text is English, internal team text is Korean
- Chat replies, progress reports, and plans follow the user's language. `CLAUDE.md`, `AGENTS.md`, README, and docs in public repos are English
- Public repos never mention company names, internal hosts, or internal systems; internal docs never mention personal repos or public personal registries
- Responses to another team's request use neutral wording in titles, statuses, and figure text: review opinion instead of rejected, options rated recommended, not recommended, or conditionally recommended
- Comments to upstream maintainers are one or two sentences, a thanks plus the single ask, with no restated review notes or offered follow-ups

## Document Structure

- Guides open with an overview stating purpose and target reader in one or two sentences
- Default order: overview, background, guide body, conclusion; table of contents for long pages
- Background is its own section right after the overview, never an info or panel box at the top. Remarks go in a closing notes section
- Diagrams, infographics, and slide decks follow the diagram skill
- A guide covers the single path its reader takes; alternatives collapse to one line pointing at the owning team
- Step guides: one sentence per step, plus a screenshot for a UI step or a code block for a CLI step. A UI step without a supplied screenshot gets a centered image placeholder, never silence
- Slack announcements: three to five short lines, sentence form, link to the doc at the end

## Confluence Reference

| Need | Rule |
|------|------|
| Body format | Storage format (XHTML) directly; markdown conversion flattens nested bullets and breaks Korean particles next to code or bold |
| Centered image | `<p style="text-align: center;"><ac:image ac:align="center" ac:width="760"><ri:attachment ri:filename="x.png"/></ac:image></p>` |
| New page location | Child of the page URL the user gives, title text only. No URL given means draft the body and ask for the parent before creating |
| Diagram | PNG rendered at 2x, displayed at width 760 |

## Validation

- `grep -n '[—–·→]' <file>` returns nothing (no `-P`, BSD grep lacks it)
- `grep -nE '^(-{3,}|\*{3,})$' <file>` returns only frontmatter lines
- No raw `https://` outside link syntax or code blocks
- `grep -n ';' <file>` hits only code, URLs, or XHTML entities, and headings carry no emoji
