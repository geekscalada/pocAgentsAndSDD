# Semantic Element Map

Use this reference to choose the correct element before reaching for `<div>`.

## Page-Level Landmarks

| Element | Use when... |
|---------|-------------|
| `<header>` | Introductory content for the page or a section (logo, site title, primary nav) |
| `<nav>` | A group of navigation links (main menu, breadcrumbs, pagination) |
| `<main>` | The primary, unique content of the page — **one per page** |
| `<aside>` | Content tangentially related to the surrounding content (sidebar, pull-quote, callout) |
| `<footer>` | Footer for the page or a section (copyright, secondary links, contact info) |

## Content Sectioning

| Element | Use when... |
|---------|-------------|
| `<article>` | A self-contained piece that makes sense on its own (blog post, news item, comment, card) |
| `<section>` | A thematic grouping of content with its own heading — NOT a generic wrapper |
| `<h1>`–`<h6>` | Hierarchical headings; levels must not be skipped |
| `<address>` | Contact information for the nearest `<article>` or `<body>` |

## Text-Level & Inline

| Element | Use when... | NOT for... |
|---------|-------------|-----------|
| `<p>` | A paragraph of text | Generic spacing |
| `<strong>` | Strong importance, seriousness, or urgency | Visual bold only → use CSS |
| `<em>` | Stress emphasis that changes meaning | Visual italic only → use CSS |
| `<b>` | Keywords, product names — no extra importance | Styling |
| `<i>` | Technical terms, foreign phrases, thoughts | Styling |
| `<mark>` | Highlighted / search-result text | Generic highlight → use CSS |
| `<small>` | Fine print, side comments, legal text | Small font size → use CSS |
| `<abbr>` | Abbreviations and acronyms (with `title`) | — |
| `<time>` | Dates and times (with `datetime` attribute) | — |
| `<code>` | Inline code snippet | — |
| `<kbd>` | Keyboard input | — |
| `<samp>` | Sample output from a program | — |
| `<var>` | Variables in math or code | — |
| `<cite>` | Title of a creative work | Author name |
| `<q>` | Short inline quotation | Long quotes → `<blockquote>` |
| `<dfn>` | The defining instance of a term | — |
| `<del>` / `<ins>` | Removed / inserted content in edits | Strikethrough/underline styling |
| `<sup>` / `<sub>` | Superscript / subscript (math, footnotes) | Styling only |

## Grouping Content

| Element | Use when... |
|---------|-------------|
| `<ul>` | Unordered list — order doesn't matter |
| `<ol>` | Ordered list — sequence matters |
| `<li>` | List item inside `<ul>` or `<ol>` |
| `<dl>` | Description / definition list (term–value pairs, FAQs, metadata) |
| `<dt>` | Term in a `<dl>` |
| `<dd>` | Description/value for the preceding `<dt>` |
| `<figure>` | Self-contained media with an optional caption (image, diagram, chart, code block) |
| `<figcaption>` | Caption for a `<figure>` |
| `<blockquote>` | Extended quotation (use `cite` attribute for source URL) |
| `<pre>` | Preformatted text (code blocks — wrap content in `<code>`) |
| `<hr>` | Thematic break between paragraphs or sections |

## Interactive & Form Elements

| Element | Use when... |
|---------|-------------|
| `<form>` | Any set of inputs submitted together |
| `<fieldset>` | Group of related controls (radio group, checkbox group) |
| `<legend>` | Caption for a `<fieldset>` — always the first child |
| `<label>` | Label for any form control — link via `for`/`id` or by wrapping |
| `<input>` | Single-line input — always set `type` explicitly |
| `<textarea>` | Multi-line text input |
| `<select>` / `<option>` | Dropdown selection |
| `<datalist>` | Suggested values for an `<input>` |
| `<button>` | Clickable button — prefer over `<input type="button">` |
| `<output>` | Result of a calculation |
| `<progress>` | Completion progress of a task |
| `<meter>` | Scalar measurement within a known range |
| `<details>` / `<summary>` | Disclosure widget (accordion, expandable section) |
| `<dialog>` | Modal or non-modal dialog |

## Media & Embedding

| Element | Use when... |
|---------|-------------|
| `<img>` | Raster/vector images — always include `alt` |
| `<picture>` | Responsive images with art-direction or format fallbacks |
| `<source>` | Alternative media source inside `<picture>`, `<video>`, `<audio>` |
| `<video>` | Embedded video — include `<track kind="captions">` |
| `<audio>` | Embedded audio |
| `<canvas>` | Programmatic 2D/3D drawing |
| `<svg>` | Inline vector graphics |
| `<table>` | Tabular data — never for layout |
| `<thead>` / `<tbody>` / `<tfoot>` | Table sections |
| `<th>` | Header cell — use `scope` attribute (`col`, `row`) |
| `<caption>` | Title for a `<table>` — always the first child |

## Common Divitis Patterns to Fix

| Wrong | Right | Why |
|-------|-------|-----|
| `<div class="header">` | `<header>` | Landmark element exists |
| `<div class="nav">` | `<nav>` | Landmark element exists |
| `<div class="footer">` | `<footer>` | Landmark element exists |
| `<div class="article">` | `<article>` | Self-contained content |
| `<div class="sidebar">` | `<aside>` | Tangential content |
| `<div class="list">` + `<div class="item">` | `<ul>` + `<li>` | It's a list |
| `<div class="quote">` | `<blockquote>` | It's a quotation |
| `<div class="menu">` | `<nav>` + `<ul>` | Navigation list |
| `<div onclick="...">` | `<button>` or `<a>` | Interactive element |
| `<div class="card">` with independent meaning | `<article>` | Self-contained piece |
| `<div class="section">` with heading | `<section>` | Thematic grouping |
