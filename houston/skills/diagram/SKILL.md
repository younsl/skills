---
name: diagram
description: Draw architecture diagrams, workflow diagrams, infographics, chart images, and slide decks in the user's black minimal style, and publish them as images that render on code hosts and wikis.
when_to_use: Any picture for a doc, MR, wiki page, guide, report, or deck, e.g. "아키텍처 다이어그램", "인포그래픽", "워크플로우 그림", "차트 이미지", "장표 작성", "발표 자료", "SVG로 그려줘". Not for Grafana dashboards or alert panels (use promql-generator), charts inside an app UI (use web-ui), or document prose (use writing-style).
argument-hint: "[message or doc path]"
license: Apache-2.0
compatibility: headless Chrome or rsvg-convert for PNG rendering, Marp CLI for markdown decks
metadata:
  version: "1.0.0"
  category: generator
  related: writing-style web-ui git-ship
allowed-tools: Bash(rsvg-convert *) Bash(grep *) Bash(file *) Read Write Edit Grep Glob
user-invocable: true
disable-model-invocation: false
---

# Diagrams, Infographics, Decks

## Output Requirements

### Message

- One message per image. The title is the message as a sentence ("The PVC only raises its request, the CSI driver does the resize"), not a topic name
- Different kinds of information (comparison, step flow, state values, settings) go on separate images
- Workflow diagrams carry only the core steps: one row of four to six numbered cards, a title and one short line each, at most one footer line. Versions, model names, and results stay in the body text
- Every number on an image is measured for the stated window (principle-its-always-dns)

### Style

- Hand-written SVG. No Mermaid or other diagram-as-code renderers
- Black background with a faint grid, cards `#0a0a0a` with a 1px `#2e2e2e` border, monospace eyebrow labels, numbered badges
- One accent color (`#3291ff`), red only for failure or regression. Charts use white for current or improved and gray `#4d4d4d` for previous or baseline, 2px lines, thin grid, and secondary series as gray dashed lines with direct labels. No decoration
- A small category badge in the top right corner of every image (for example `Infrastructure`)
- System architecture flows left to right in traffic order, and the order inside each card follows the same direction
- Arrows never pass through a box other than their own ends. Align boxes in rows and columns so arrows run straight, and spread several exits from one side along that side
- Open source projects get their official logo as an embedded data URI from the project's or foundation's artwork repo. A logo invisible on black uses the project's secondary brand color. Managed cloud services get no logo
- Text inside images follows writing-style, and the same characters are banned there as in prose

### Size and Export

- Canvas 1200px wide for wiki pages with body text at least 17px, rendered to PNG at 2x and displayed at width 760
- The SVG source is kept next to the doc (`docs/**/assets/*.svg`) as the source of truth

### Publishing

- Code hosts and wikis can serve an uploaded SVG as a download instead of an image. Embed the PNG and link the SVG
- Wiki images are attachments placed in storage format inside a centered paragraph with an explicit width, never external image links
- Upload tools that refuse paths outside the project get a temporary copy inside the project, deleted right after upload
- Re-uploading under the same file name can fail or keep the old image. Upload under a new name and update the reference

## Slides

- A deck lives in the repo that owns the topic, as one file under its docs slides directory (self-contained HTML with inline CSS, JS, and SVG, or Marp markdown), never in a hosted artifact. The directory's index lists it
- Pure black background, one image and one caption line per slide, and the slide number as current and total only
- Every slide's claim is backed by a number: count, ratio, time, cost, or lines of code
- Abstraction matches the audience. Leadership decks use general terms (metadata store, not the database product) and drop implementation detail
- No CDN references. Assets by relative path
- Public decks follow principle-air-gap, including registry and repo URLs shown on slides

## Validation

- The writing-style character check returns nothing on the SVG text
- The PNG is twice the SVG width (`file <png>`)
- The doc embeds the PNG and links the SVG source
- Each image has exactly one title sentence
