---
name: node-express-api
scope: global
description: Validation and conventions for the Node/Express API services (compliance-ai, vendorsafe) — typecheck, route patterns, and the export-route dispatch pattern.
---

# Node / Express API Validation

## Gates before declaring done

```bash
./node_modules/.bin/tsc --noEmit   # typecheck the api/ package
# project test command if configured
# restart + smoke test the affected route
```

## Route conventions

- Routes live in `api/src/routes/*.ts` and are mounted in the app entry.
- Export routes accept a `format` query param (`pdf` | `docx` | `xlsx`) and
  dispatch to the matching generator in `api/src/lib/`.
- Set the correct `Content-Type` and `Content-Disposition` per format:
  - PDF: `application/pdf`, `filename="report.pdf"`
  - Word: `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
  - Excel: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

## Content integrity (critical)

- Report exports must NEVER invent content: no fabricated evidence, owners,
  dates, severities, or certifications. Derive everything from the source
  assessment data.
- When converting a narrative field (semicolon-separated key risks, gaps,
  recommendations) into table rows, split on the separator and keep source
  wording — only derive short titles for navigation.
- Keep source fields (Report ID, score, risk level) byte-for-byte identical.

## Conventions

- Match existing lib conventions when adding a generator (look at how the
  PDF renderer structures sections, then mirror it in docx/xlsx).
- Pin the libs already used (e.g. pdfkit, docx, exceljs) — do not add a new
  library when one is already in the project.

## Verification

- Typecheck passes.
- Each format downloads with the right content type + filename.
- Spot-check the generated file (open it / render it) — a 200 response is
  not proof the layout is right.
