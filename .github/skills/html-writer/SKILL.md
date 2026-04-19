---
name: html-writer
description: 'Write pure, semantic HTML5 following industry standards. Use when creating or editing HTML files without frameworks, avoiding divitis, enforcing semantic structure, form accessibility, heading hierarchy, and standard conventions. Triggered by: HTML page, HTML form, markup, semantic HTML, plain HTML, HTML boilerplate, HTML structure, web page without framework.'
argument-hint: 'Describe the page or component to write (e.g., "landing page with hero and contact form")'
---

# HTML Writer

Write clean, framework-free, semantically correct HTML5.

## When to Use

- Creating a new `.html` file from scratch
- Refactoring existing HTML to remove divitis or add semantics
- Writing accessible forms, navigation, or content sections
- Any HTML task that must not introduce CSS/JS frameworks

## Core Rules (Always Apply)

1. **No divitis** — never use `<div>` when a semantic element exists. Consult [semantic element map](./references/semantic-elements.md) before choosing any container.
2. **One `<h1>` per page** — heading levels must be strictly hierarchical.
3. **Every `<img>` needs `alt`** — decorative images use `alt=""`.
4. **Every form control needs a `<label>`** — linked via `for`/`id` or by wrapping.
5. **No deprecated elements** — never use `<center>`, `<font>`, `<b>` (for styling), `<i>` (for styling), `bgcolor`, `align`, etc.
6. **No inline styles** — use `<style>` or a linked stylesheet instead.
7. **Self-close void elements without slash** — `<br>`, `<input>`, `<img>`, `<meta>`, `<link>` (HTML5 style, not XHTML).


## Principles

- Use the HTML5 doctype: `<!DOCTYPE html>`
- Always declare `<html lang="...">` with the appropriate language code
- Include a complete `<head>` with `<meta charset="UTF-8">`, `<meta name="viewport" content="width=device-width, initial-scale=1.0">`, and a descriptive `<title>`
- Use semantic elements: `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<footer>`, `<figure>`, `<figcaption>`, etc.
- Prefer landmark roles implicitly through semantic elements rather than explicit ARIA unless needed
- Every `<img>` must have a meaningful `alt` attribute
- Form elements must have associated `<label>` elements (via `for`/`id` or wrapping)
- Heading levels must be hierarchical (`<h1>` → `<h2>` → `<h3>`), with only one `<h1>` per page
- Indent with 2 spaces; keep attribute order consistent: `id`, `class`, `name`, `type`, `href`/`src`, other attributes
- Self-close void elements without a slash: `<br>`, `<hr>`, `<input>`, `<img>`, `<meta>`, `<link>`

## Approach

1. Clarify the page purpose and content structure before writing
2. Draft the semantic HTML skeleton first (doctype → html → head → body with landmarks)
3. Fill in content sections using appropriate semantic elements
4. Add accessibility attributes (`alt`, `aria-label`, `role`) where semantic elements are insufficient
5. Validate that heading hierarchy, landmark structure, and form associations are correct
6. Review for deprecated elements, inline styles, or missing required attributes

## Output Format

Produce a single `.html` file (or the requested fragment) with:
- Full boilerplate when creating a new page
- Only the relevant fragment when editing an existing file
- A brief comment block at the top listing any assumptions made about content or structure

## Procedure

### Step 1 — Understand the page
- Identify: page purpose, primary audience, language, main content areas.
- Define the landmark structure before writing any code: which `<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>` zones exist?

### Step 2 — Choose the right elements
- Open [semantic element map](./references/semantic-elements.md) and map each content zone to its correct element.
- Default decision: *"Is there a semantic element that describes this content?"* → Yes → use it. No → use `<div>` as last resort with a clear `class` name.

### Step 3 — Write the boilerplate
- Start from [html5-boilerplate.html](./assets/html5-boilerplate.html).
- Fill in: `lang`, `<title>`, `<meta name="description">`, and the page `<h1>`.

### Step 4 — Build the document outline
- Write all headings first to verify hierarchy.
- Check: exactly one `<h1>`, no skipped levels (e.g., `<h2>` → `<h4>`).

### Step 5 — Fill in content
- Replace every potential `<div>` with its semantic equivalent.
- Mark up lists as `<ul>`/`<ol>`, quotes as `<blockquote>`, code as `<code>`/`<pre>`, etc.
- Add `aria-label` or `aria-labelledby` only when the semantic element alone is insufficient.

### Step 6 — Validate forms and media
- Every `<input>`, `<select>`, `<textarea>` must have an associated `<label>`.
- Use `<fieldset>` + `<legend>` for groups of related controls (radio groups, checkboxes).
- Every `<img>` has `alt`; every `<video>` has `<track kind="captions">` if applicable.

### Step 7 — Review checklist (before delivering)

| Check | Pass condition |
|-------|----------------|
| Doctype | `<!DOCTYPE html>` present |
| Language | `<html lang="...">` set |
| Charset | `<meta charset="UTF-8">` in `<head>` |
| Viewport | `<meta name="viewport" content="width=device-width, initial-scale=1.0">` |
| Title | `<title>` is descriptive, not empty |
| Heading hierarchy | One `<h1>`, no skipped levels |
| Landmark structure | `<main>` present, landmarks don't overlap |
| Divitis check | No `<div>` where a semantic element would fit |
| Images | All `<img>` have `alt` |
| Forms | All controls have associated labels |
| Deprecated elements | None present |
| Inline styles | None (unless trivially unavoidable) |

## Output Format

- New page → full `.html` file starting from the boilerplate.
- Fragment / edit → only the relevant section, with surrounding context for placement.
- Always add a brief comment block at the top listing assumptions about content or structure.
