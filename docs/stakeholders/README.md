# Stakeholder pack

Materials for briefing stakeholders on the Top 10 Pocket Guide.

> **Status:** working draft. The content has not been reviewed by subject-matter
> experts and the app is not ready for public release. This is an independent
> project, not an OWASP publication.

## What is here

| File | Use |
| --- | --- |
| [`project-summary.md`](project-summary.md) | Written summary (about four pages with tables): problem, scope, experience, technology, quality, status, risks and decisions needed. Send this before the meeting. |
| [`presentation.md`](presentation.md) | Slide-by-slide outline with speaker notes, timings, a demo script and prepared answers to likely questions. |
| [`OWASP-Top-10-Pocket-Guide.pptx`](OWASP-Top-10-Pocket-Guide.pptx) | 16-slide deck, 16:9, with speaker notes on every slide. |
| [`build_deck.py`](build_deck.py) | Regenerates the deck from the same facts as the written documents. |
| [`screenshots/`](screenshots/) | Current app screenshots used in the deck (see the note in that folder). |

## Presenting

1. Read the summary first; it is written to stand alone.
2. Open the deck and check the speaker notes in Presenter View.
3. Keep the disclaimer in the opening and the close: working draft, independent
   project, no OWASP endorsement.
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
slides were produced.

Screenshots are read from `screenshots/` by filename. If you replace one, keep
the filename and the 1080 × 2400 aspect ratio.

## Keeping the facts current

The numbers in the deck and the summary come from `assets/content/bundle.json`
and the test suite. If either changes, update both documents and rebuild:

```sh
cd ~/projects/OWASP/Top-10-App
~/development/flutter/bin/flutter test
python3 docs/stakeholders/build_deck.py
```
