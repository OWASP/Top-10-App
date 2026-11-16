# OWASP Top 10 Pocket Guide — presentation outline

**Audience:** stakeholders, delivery leads and reviewers  
**Length:** 20 minutes plus 10 minutes of questions  
**Deck:** `OWASP-Top-10-Pocket-Guide.pptx` (16 slides, 16:9)  
**Companion document:** [`project-summary.md`](project-summary.md)

> **Before presenting:** this is an independent draft. Say so early and say it plainly. Do not imply OWASP endorsement, and do not describe the content as reviewed.

---

## Timing at a glance

| Slides | Section | Minutes |
| --- | --- | ---: |
| 1–2 | Why we are here | 2 |
| 3–4 | What we built | 3 |
| 5–7 | The experience and design | 4 |
| 8–10 | How it is built | 4 |
| 11–12 | Quality, security and privacy | 3 |
| 13–15 | Status, risks and decisions | 3 |
| 16 | Close | 1 |

---

## Slide 1 — Title

**On the slide**

> **OWASP Top 10 Pocket Guide**
> Six editions. One offline reference.
> Working draft · 22 October 2026
> Independent project — not an OWASP publication

**Speaker notes**

- "Thank you for the time. I am going to show what exists today, how it is designed and built, and — importantly — what still stands between this and a release."
- "Two framing points. First, this is a working title and an independent project. We are not claiming OWASP endorsement. Second, the content is a draft: written from the official material and fully cited, but not yet signed off by reviewers."
- "I will keep the demo to a couple of minutes and leave time for decisions at the end."

---

## Slide 2 — The problem

**On the slide**

> Six Top 10 lists. Six PDFs. One practitioner.
>
> - Guidance is split across web, API, LLM, agentic skills, agentic applications and MCP editions.
> - The four AI editions are grouped in the filters, but the documents are still separate.
> - Citations are lost when notes are copied.
> - The moment you need the checklist is often the moment you have no signal.

**Speaker notes**

- "Most teams do not work in one of these areas. A typical application has a web front end, an API, a mobile client, container infrastructure and now model integrations."
- "The official documents are authoritative and should stay that way. The gap is a fast, trustworthy lookup that still points back to them."
- "Two design consequences follow. It has to be offline, because you need it during an incident or a client visit. And every screen has to carry its citation, because a summary without a source is just an opinion."

---

## Slide 3 — What we built

**On the slide**

> A complete offline study guide for six editions.
>
> **6** editions · **60** risk entries · **30** quiz questions · **13** cheatsheets
>
> One Android app. No account. No network permission. No analytics.

**Speaker notes**

- "This is not a mock-up. It is a working Android app."
- "Each of the six editions has ten risks, five quiz questions and at least two cheatsheets. Web has three."
- "The important number is not 60 — it is that all 60 are structured the same way, which is what makes search, review and future updates tractable."
- "The app requests no network permission at all. That is a product statement, not a technical detail: it cannot phone home."

---

## Slide 4 — Five tabs, one learning loop

**On the slide**

Screenshot strip: Learn · Practice · Sheets · Progress · Access, with one line each.

> Learn → Practice → Sheets → Progress → Access

**Speaker notes**

- "The navigation is deliberately five tabs, not six or seven. Each tab answers one question."
- "**Learn** is what is this risk? **Practice** is do I understand it? **Sheets** is what do I check in a review? **Progress** is what have I covered? **Access** is how do I make this work for me?"
- "The fifth tab is unusual. Accessibility is usually buried in system settings. We made it a first-class tab because this material is read by people with very different needs."

**Demo cue (60–90 seconds)**: open Learn, search "broken access", open A01, switch to Defend, then show the Access tab. Keep the draft banner visible and name it.

---

## Slide 5 — Learn and risk detail

**On the slide**

Screenshot: Learn, plus callouts.

> - Search across the selected edition, with read state
> - Six edition filters, never mixed
> - Each risk: summary, example, code, test, fix, citation

**Speaker notes**

- "Search is scoped to the edition you selected. We deliberately do not blend editions: A01 in Web 2025 and API1 in API 2023 are different things with different numbering."
- "The detail screen is three tabs. Overview gives the plain-language explanation. Code shows a vulnerable and a secure sample. Defend gives the test, the fix and the official source."
- "Every risk shows its citation and review date. When content is not signed off it also says so, and when the bundle is draft the whole screen carries the red banner."
- "Search input is capped and sanitised. That matters less for SQL injection — there is no database query behind it — and more for not letting a pasted page of text freeze the UI."

---

## Slide 6 — Design system

**On the slide**

Screenshot: navigation-dark with the five coloured tabs. Palette chips for OWASP blue and the edition accents.

> OWASP blue chrome. A distinct colour per edition. A distinct colour per tab.
> Light · Dark · High contrast, from one palette.

**Speaker notes**

- "The chrome is seeded from OWASP blue so the app feels related to the official material without copying it."
- "Each edition has its own accent: teal for Web, blue for API, purple for LLM, and so on. The accent appears in the list header, the selected filter, the quiz progress and the primary button. You always know which edition you are in."
- "The five tabs also have their own colour and their own hand-drawn glyph. That is a small thing that makes the app feel designed rather than assembled."
- "All of this is generated from one seed colour and a luminance target, so light, dark and high-contrast variants stay consistent instead of being three hand-tuned themes."

**Talking point if asked about the logo:** "The logo is a placeholder. We are using it at the project's direction while permission is confirmed; it is not a claim of affiliation."

---

## Slide 7 — Accessibility

**On the slide**

Screenshot: Access tab.

> - WCAG 2.2 AA contrast, asserted by tests
> - 200% text without overflow
> - TalkBack labels for read state, quiz feedback and progress
> - Theme, text size, contrast, spacing, motion — saved on device

**Speaker notes**

- "Accessibility was treated as a requirement, not a polish pass."
- "Contrast is checked by an automated test for every colour pair the app actually uses, in light, dark and high-contrast themes. That is why the selected navigation pill is a neutral tone: the high-contrast scheme inverts the usual container colours, and the neutral pill stays readable in all of them."
- "The layout survives 200% text. We tested with TalkBack on and off. Touch targets are at least 48 dp."
- "The settings combine with the system font scale rather than replacing it, which is what users expect."

---

## Slide 8 — How it is built

**On the slide**

Architecture diagram:

```
┌──────────────────────────────────────────────┐
│ Presentation   Learn · Practice · Sheets ·   │
│                Progress · Access             │
├──────────────────────────────────────────────┤
│ State          Riverpod providers            │
├───────────────────────┬──────────────────────┤
│ Content               │ Progress              │
│ repository + validator│ repository            │
├───────────────────────┼──────────────────────┤
│ assets/content/       │ Drift / SQLite        │
│ bundle.json           │ (read, quiz, settings)│
└───────────────────────┴──────────────────────┘
```

> UI → state → repositories → immutable inputs  
> The content layer knows nothing about the UI.

**Speaker notes**

- "The architecture is intentionally boring. Screens read providers. Providers call two repositories. One repository loads and validates the bundled JSON; the other reads and writes local progress."
- "The content layer has no dependency on Flutter widgets. That is why the same bundle can also generate the review packet and be validated in a plain Dart test."
- "Everything the app shows comes from one immutable input. There is no server, no cache invalidation and no partial-failure mode beyond a clean error screen."

---

## Slide 9 — The content pipeline

**On the slide**

Pipeline diagram:

```
Official OWASP material
        │  author
        ▼
bundle.json (schema 1.0.0)
        │  validate at build and at startup
        ▼
App  ──►  SME review packet + sign-off.csv
        │
        ▼
draft ──► final (all risks reviewed)
```

> One source of truth. The app and the review packet are generated from the same file.

**Speaker notes**

- "Content is data, not code. One JSON file holds every edition, risk, question, cheatsheet and citation."
- "The validator is the contract. IDs must be unique, quiz answers must be in range, quiz links must resolve, every risk needs a citation and review date, code samples need a language label, and prose may not contain HTML."
- "The same file generates the SME packet: six review sheets and a 60-row sign-off CSV. Reviewers work from the packet; corrections go back into the bundle; the packet is regenerated."
- "That loop is the main reason I am confident about the review process. There is no second copy of the content to drift."

---

## Slide 10 — Technology choices

**On the slide**

| Layer | Choice | Why |
| --- | --- | --- |
| Framework | Flutter 3.47 / Dart | One codebase; strong text scaling and semantics |
| Design | Material 3 | Familiar Android behaviour; accessible defaults |
| State | Riverpod 3 | Explicit dependencies; easy to test |
| Navigation | go_router 18 | Typed routes; independent tab history |
| Storage | Drift / SQLite | Durable local data; schema migrations |
| Content | Validated JSON | Reviewable outside the app; no UI coupling |

**Speaker notes**

- "None of these choices is exotic, and that is deliberate. For a small team, boring technology is a feature."
- "Flutter gives us one implementation of the design and accessibility behaviour, and leaves the door open to iOS without committing to it now."
- "Drift gives us schema migrations. We already used one when accessibility settings were added — the database moved from version 1 to 2 without losing read state."
- "The content format is plain JSON because reviewers should not need a build toolchain to read it."

---

## Slide 11 — Security and privacy posture

**On the slide**

> - No network permission — nothing to intercept, nothing to exfiltrate
> - No accounts, analytics or advertising
> - Content validated at startup; failures close the app instead of showing partial advice
> - Release builds refuse draft content
> - Search treats metacharacters literally; input is sanitised and capped

**Speaker notes**

- "The strongest privacy feature is the one we did not build: there is no network path."
- "The strongest content-safety feature is the fail-closed loader. If the bundle is malformed or unreviewed, the app shows an error, not a half-filled screen."
- "And the strongest release control is this: if someone builds a release APK from the draft bundle, it starts and then refuses to show content. We hit that ourselves when testing on a phone. It is annoying, and it is exactly what we want."
- "On injection: search never touches SQL, HTML or a shell. The hardening is about length and invisible characters, and the characters people worry about are treated as literal text."

---

## Slide 12 — Quality evidence

**On the slide**

> **34** automated tests · `flutter analyze` clean
>
> Covered: content validation · quiz integrity · theme contrast · search handling · settings persistence · review-packet coverage · widget behaviour
>
> Verified on: Android emulator · Samsung Galaxy S22 Ultra

**Speaker notes**

- "The tests are not just widget smoke tests. The content validator has its own tests, the review packet is checked for full coverage of the bundle, and contrast is asserted mathematically for every theme variant."
- "The app has been run on an emulator and on a physical S22 Ultra. TalkBack and 200% text were verified on the emulator."
- "What the tests do not cover is editorial accuracy. That is the SME review, and it is the largest remaining task."

---

## Slide 13 — Licensing and branding

**On the slide**

| Asset | Position |
| --- | --- |
| Source code | GPL-3.0 |
| Content (Web, API, LLM, Agentic Skills, Agentic Applications, MCP) | CC BY-SA 4.0, attribution kept in the bundle |
| OWASP name and logo | Permission not yet confirmed — **blocker** |
| Product name, package ID | Placeholders — **decision needed** |

**Speaker notes**

- "The code is GPL-3.0 and all six content editions are CC BY-SA 4.0. The bundle stores the attribution text and the About screen shows it."
- "One blocker: we have not asked OWASP about the name or the logo."
- "I want to be direct: this is why the app says 'independent project' and 'not an OWASP publication'. If we cannot get permission, the fallback is a neutral name that refers to OWASP descriptively and no logo."

---

## Slide 14 — Status and risks

**On the slide**

| Status | |
| --- | --- |
| Built and verified | App, content, search, progress, accessibility, tests |
| Draft | All 60 risks awaiting SME sign-off |
| Blocked | OWASP branding; release signing |
| Not started | Store listing, privacy statement, release keystore |

**Speaker notes**

- "The engineering is essentially complete. The remaining work is review, permissions and release mechanics."
- "The risk I would highlight is not technical. It is that the app looks finished, so someone distributes a profile build or a screenshot without the draft banner and the content is treated as reviewed advice. The draft gate is our main protection against that."
- "The second risk is time: OWASP publishes new editions, and without an owner the content will age."

---

## Slide 15 — Roadmap and decisions

**On the slide**

> **M1 Review** (2 weeks) → **M2 Content final** (1 week) → **M3 Release candidate** (2 weeks) → **M4 Pilot** (2–4 weeks) → **M5 Release**
>
> Decisions needed today:
> 1. Name reviewers for each edition
> 2. Product name and package ID
> 3. Branding route
> 4. Distribution channel and signing owner
> 5. Content refresh cadence and owner

**Speaker notes**

- "The schedule is dominated by decisions and review, not by coding."
- "If you can name reviewers today, M1 starts this week."
- "I recommend deciding the name and package ID before any external build, because changing the package ID later breaks upgrades."
- "For distribution I recommend internal testing on Play first, with a proper release keystore owned by the organisation."

---

## Slide 16 — Close

**On the slide**

> Six editions. One pocket. Fully offline.
>
> **What we need:** reviewers, a name, a branding route.
>
> Thank you.

**Speaker notes**

- "To summarise: the product works, the content is structured and traceable, and the remaining blockers are review and permissions rather than engineering."
- "The one-sentence ask is: help us name reviewers and settle the name and branding, and we can move to a release candidate in about five weeks."
- "I am happy to take questions, and I can demo any screen."

---

## Questions to expect

**"Is this an official OWASP app?"**  
No. It is independent and not endorsed. The name and logo are placeholders pending permission. If permission is not granted, we rename and remove the mark.

**"How do we know the content is correct?"**  
It is written from the official editions and cites them, but it has not been signed off. That is the purpose of the M1 review. The app is explicitly gated as draft until then.

**"Why not a website?"**  
Offline use is the point. A website cannot be relied on during an incident, on a client site, or on a plane. A website could be added later from the same JSON.

**"Why six editions instead of just web?"**  
The same practitioner increasingly works across web, API, cloud-native and AI systems. Six editions is the differentiator; the risk is scope, which is why each edition is capped at ten risks and five questions.

**"What does it cost to run?"**  
No servers and no per-user cost. The costs are review time, store fees and the effort to keep content current.

**"Can it work on iOS?"**  
The codebase can, but nothing has been built or tested for iOS. Treat it as out of scope until Android is released.

**"What happens if a reviewer rejects a risk?"**  
The correction goes into the bundle, the validator and tests re-run, and the review packet is regenerated. A risk without a named reviewer keeps the whole bundle in draft.

---

## Demo script (optional, 2 minutes)

1. Open **Learn**. Point out the draft banner and the edition filters.
2. Type `broken access` in search. Show the result narrowing to A01.
3. Open **A01**. Show Overview, then **Defend** — test, fix, official source, "Awaiting SME review".
4. Tap **Practice**, answer one question incorrectly and show the explanation. Do not claim a score.
5. Open **Progress**. Show read count and quiz history.
6. Open **Access**. Switch to dark, then back to light. Show text size and high contrast.
7. Close on the five coloured tabs: "That is the whole product."

**Do not** show the About screen unless asked — the placeholder naming is explained better in the deck than in a screenshot.
