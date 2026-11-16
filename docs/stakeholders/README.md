# Stakeholder pack

Materials for briefing stakeholders on the OWASP Top 10 Pocket Guide.

> **Status:** working draft. The content has not been reviewed by subject-matter
> experts and the app is not ready for public release. This is an OWASP project.

## What is here

| File | Use |
| --- | --- |
| [`project-summary.md`](project-summary.md) | Written summary (about four pages with tables): problem, scope, experience, technology, quality, status, risks and decisions needed. Send this before the meeting. |
| [`presentation.md`](presentation.md) | Slide-by-slide outline with speaker notes, timings, a demo script and prepared answers to likely questions. |
| [`build_deck.py`](build_deck.py) | Generates the 16-slide deck (`OWASP-Top-10-Pocket-Guide.pptx`, not committed) from the same facts as the written documents. |
| [`screenshots/`](screenshots/) | Current app screenshots used in the deck (see the note in that folder). |

## Presenting

1. Read the summary first; it is written to stand alone.
2. Build the deck if needed, then open it and check the speaker notes in Presenter View.
3. Keep the status in the opening and the close: working draft, content awaiting
   SME review.
4. Leave 10 minutes for the five decisions on slide 15.

The deck deliberately shows the in-app draft banner. Do not crop it out: it is
evidence that the release gate works.

## Rebuilding the deck

Requires Python 3 and `python-pptx` (0.6.18 or later). No PowerPoint or
LibreOffice installation is needed to build it.

```sh
python3 docs/stakeholders/build_deck.py
```

The script prints a conservative text-fit estimate and returns a non-zero exit
code if any text box is likely to overflow. It also checks that exactly 16
slides were produced. The generated `.pptx` is ignored by git; only the script
and screenshots are tracked.

Screenshots are read from `screenshots/` by filename. If you replace one, keep
the filename and the 1080 × 2400 aspect ratio.

## Keeping the facts current

The numbers in the deck and the summary come from `assets/content/bundle.json`
and the test suite. If either changes, update both documents and rebuild:

```sh
flutter test
python3 docs/stakeholders/build_deck.py
```
