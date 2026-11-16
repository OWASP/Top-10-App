#!/usr/bin/env python3
"""Build the stakeholder slide deck for the OWASP Top 10 Pocket Guide.

Run from anywhere:

    python3 docs/stakeholders/build_deck.py

The deck is generated from the same facts as project-summary.md and
presentation.md. Screenshots are read from docs/stakeholders/screenshots.

No renderer is available on this machine, so the script also performs a
conservative text-fit estimate and prints a warning for any box that is
likely to overflow. Treat warnings as a prompt to shorten copy.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.oxml.ns import qn
from pptx.util import Emu, Inches, Pt
from pptx.oxml.xmlchemy import OxmlElement

ROOT = Path(__file__).resolve().parents[2]
SHOTS = ROOT / "docs" / "stakeholders" / "screenshots"
OUT = ROOT / "docs" / "stakeholders" / "OWASP-Top-10-Pocket-Guide.pptx"
LOGO = ROOT / "assets" / "images" / "owasp_logo.png"

# ---------------------------------------------------------------- palette ---
NAVY = RGBColor.from_string("0E2A57")
BLUE = RGBColor.from_string("1B4388")
BLUE_LIGHT = RGBColor.from_string("2E4E86")
STEEL = RGBColor.from_string("5B6472")
MUTED = RGBColor.from_string("77839A")
INK = RGBColor.from_string("191C23")
LINE = RGBColor.from_string("DCE2EC")
WASH = RGBColor.from_string("F4F7FC")
PALE = RGBColor.from_string("E9F0FB")
WHITE = RGBColor.from_string("FFFFFF")
RED = RGBColor.from_string("B3261E")
RED_BG = RGBColor.from_string("FBEAE8")
GREEN = RGBColor.from_string("1D6544")
GREEN_BG = RGBColor.from_string("E7F3EC")
AMBER = RGBColor.from_string("7E4E24")
AMBER_BG = RGBColor.from_string("FBF1E4")
YELLOW = RGBColor.from_string("E8B44A")

# Accents computed from lib/core/brand_icons.dart (light theme, 0.55 sat).
EDITIONS = [
    ("WEB 2025", RGBColor.from_string("1D635C")),
    ("API 2023", RGBColor.from_string("2E589D")),
    ("LLM 2026", RGBColor.from_string("7436BB")),
    ("AGENTIC-SKILLS 2026", RGBColor.from_string("992D75")),
    ("AGENTIC-APP 2026", RGBColor.from_string("7E4E24")),
    ("MCP 2025", RGBColor.from_string("1D6544")),
]

# The accent legend is narrow, so the two agentic editions get compact pills.
SHORT_EDITION_LABELS = {
    "AGENTIC-SKILLS 2026": "SKILLS 2026",
    "AGENTIC-APP 2026": "APP 2026",
}
TABS = [
    ("Learn", RGBColor.from_string("3056A4")),
    ("Practice", RGBColor.from_string("1D635C")),
    ("Sheets", RGBColor.from_string("7436BB")),
    ("Progress", RGBColor.from_string("7E4E24")),
    ("Access", RGBColor.from_string("1D663B")),
]

FONT = "Arial"
MONO = "Consolas"
SLIDE_W = 13.333
SLIDE_H = 7.5
MARGIN = 0.8
CONTENT_W = SLIDE_W - 2 * MARGIN
TOTAL_SLIDES = 16


# ---------------------------------------------------------------- helpers ---
def rgb(hex_or_color: RGBColor) -> RGBColor:
    return hex_or_color


def add_rect(
    slide,
    x: float,
    y: float,
    w: float,
    h: float,
    fill: RGBColor | None = None,
    line: RGBColor | None = None,
    line_w: float = 1.0,
    shape=MSO_SHAPE.RECTANGLE,
    radius: float | None = None,
    name: str | None = None,
):
    box = slide.shapes.add_shape(
        shape, Inches(x), Inches(y), Inches(w), Inches(h)
    )
    if radius is not None and shape == MSO_SHAPE.ROUNDED_RECTANGLE:
        box.adjustments[0] = radius
    if fill is None:
        box.fill.background()
    else:
        box.fill.solid()
        box.fill.fore_color.rgb = fill
    if line is None:
        box.line.fill.background()
    else:
        box.line.color.rgb = line
        box.line.width = Pt(line_w)
    box.text_frame.text = ""
    if name:
        box.name = name
    return box


def add_text(
    slide,
    x: float,
    y: float,
    w: float,
    h: float,
    runs,
    *,
    size: float = 14,
    bold: bool = False,
    color: RGBColor = INK,
    align=PP_ALIGN.LEFT,
    anchor=MSO_ANCHOR.TOP,
    font: str = FONT,
    spacing: float = 0.0,
    line_spacing: float = 1.0,
    name: str | None = None,
    autofit_warn: bool = True,
):
    """Add a text box.

    `runs` is either a string, a list of strings (one paragraph each), or a
    list of dicts: {"text", "size", "bold", "color", "space", "align"}.
    """
    box = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = box.text_frame
    tf.word_wrap = True
    tf.margin_left = 0
    tf.margin_right = 0
    tf.margin_top = 0
    tf.margin_bottom = 0
    tf.vertical_anchor = anchor
    if name:
        box.name = name

    if isinstance(runs, str):
        runs = [runs]

    for index, item in enumerate(runs):
        spec = {"text": item} if isinstance(item, str) else dict(item)
        p = tf.paragraphs[0] if index == 0 else tf.add_paragraph()
        p.alignment = spec.get("align", align)
        p.line_spacing = spec.get("line_spacing", line_spacing)
        p.space_before = Pt(spec.get("space_before", spacing if index else 0))
        p.space_after = Pt(0)
        run = p.add_run()
        run.text = spec["text"]
        run.font.name = spec.get("font", font)
        run.font.size = Pt(spec.get("size", size))
        run.font.bold = spec.get("bold", bold)
        run.font.color.rgb = spec.get("color", color)
    return box


def add_rule(slide, x1, y1, x2, y2, color=LINE, width=1.0):
    """Draw a hairline as a filled rectangle.

    A rectangle renders identically in PowerPoint, LibreOffice and PDF
    exporters, whereas a zero-height connector is handled inconsistently by
    some of them.
    """
    thickness = max(width / 72.0, 0.01)
    if abs(y2 - y1) < 0.005:
        add_rect(slide, x1, y1 - thickness / 2, x2 - x1, thickness, fill=color)
    else:
        add_rect(slide, x1 - thickness / 2, y1, thickness, y2 - y1, fill=color)


def add_down_arrow(slide, cx: float, y: float, h: float = 0.24):
    arrow = slide.shapes.add_shape(
        MSO_SHAPE.DOWN_ARROW,
        Inches(cx - 0.09),
        Inches(y),
        Inches(0.18),
        Inches(h),
    )
    arrow.fill.solid()
    arrow.fill.fore_color.rgb = MUTED
    arrow.line.fill.background()


def add_right_arrow(slide, x: float, cy: float, w: float = 0.26):
    arrow = slide.shapes.add_shape(
        MSO_SHAPE.RIGHT_ARROW,
        Inches(x),
        Inches(cy - 0.08),
        Inches(w),
        Inches(0.16),
    )
    arrow.fill.solid()
    arrow.fill.fore_color.rgb = MUTED
    arrow.line.fill.background()


def add_chip(
    slide,
    x: float,
    y: float,
    w: float,
    h: float,
    label: str,
    color: RGBColor,
    *,
    fill: RGBColor | None = None,
    text_color: RGBColor | None = None,
    size: float = 9,
    bold: bool = True,
):
    chip = add_rect(
        slide,
        x,
        y,
        w,
        h,
        fill=fill,
        line=color,
        line_w=0.9,
        shape=MSO_SHAPE.ROUNDED_RECTANGLE,
        radius=0.5,
    )
    tf = chip.text_frame
    tf.word_wrap = False
    tf.margin_left = Inches(0.04)
    tf.margin_right = Inches(0.04)
    tf.margin_top = 0
    tf.margin_bottom = 0
    tf.vertical_anchor = MSO_ANCHOR.MIDDLE
    p = tf.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    run = p.add_run()
    run.text = label
    run.font.name = FONT
    run.font.size = Pt(size)
    run.font.bold = bold
    run.font.color.rgb = text_color if text_color is not None else color
    return chip


def add_phone(
    slide,
    filename: str,
    x: float,
    y: float,
    height: float,
    *,
    caption: tuple[str, str] | None = None,
):
    path = SHOTS / filename
    if not path.exists():
        raise FileNotFoundError(f"missing screenshot: {path}")
    width = height * 1080 / 2400
    # A hairline frame keeps the screenshot from floating on the page.
    add_rect(
        slide,
        x - 0.035,
        y - 0.035,
        width + 0.07,
        height + 0.07,
        fill=WHITE,
        line=LINE,
        line_w=0.75,
    )
    slide.shapes.add_picture(
        str(path), Inches(x), Inches(y), Inches(width), Inches(height)
    )
    if caption:
        title, role = caption
        add_text(
            slide,
            x - 0.12,
            y + height + 0.10,
            width + 0.24,
            0.2,
            title,
            size=10,
            bold=True,
            color=NAVY,
            align=PP_ALIGN.CENTER,
        )
        add_text(
            slide,
            x - 0.12,
            y + height + 0.30,
            width + 0.24,
            0.2,
            role,
            size=8.5,
            color=MUTED,
            align=PP_ALIGN.CENTER,
        )
    return width


def set_cell_border(cell, color: RGBColor = LINE, width: float = 0.75):
    tc_pr = cell._tc.get_or_add_tcPr()
    for tag in ("a:lnL", "a:lnR", "a:lnT", "a:lnB"):
        ln = tc_pr.find(qn(tag))
        if ln is None:
            ln = OxmlElement(tag)
            tc_pr.append(ln)
        ln.set("w", str(int(Pt(width))))
        ln.set("cap", "flat")
        ln.set("cmpd", "sng")
        ln.set("algn", "ctr")
        for child in list(ln):
            ln.remove(child)
        fill = OxmlElement("a:solidFill")
        srgb = OxmlElement("a:srgbClr")
        srgb.set("val", str(color))
        fill.append(srgb)
        ln.append(fill)


def style_cell(
    cell,
    text: str,
    *,
    size: float = 11,
    bold: bool = False,
    color: RGBColor = INK,
    fill: RGBColor = WHITE,
    align=PP_ALIGN.LEFT,
):
    cell.margin_left = Inches(0.14)
    cell.margin_right = Inches(0.14)
    cell.margin_top = Inches(0.05)
    cell.margin_bottom = Inches(0.05)
    cell.vertical_anchor = MSO_ANCHOR.MIDDLE
    # Borders first: the cell-property schema expects line elements before
    # the fill element, and PowerPoint is strict about that order.
    set_cell_border(cell)
    cell.fill.solid()
    cell.fill.fore_color.rgb = fill
    tf = cell.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.alignment = align
    p.line_spacing = 0.98
    run = p.add_run()
    run.text = text
    run.font.name = FONT
    run.font.size = Pt(size)
    run.font.bold = bold
    run.font.color.rgb = color


def add_table(
    slide,
    x: float,
    y: float,
    w: float,
    col_widths: list[float],
    rows: list[list[tuple]],
    *,
    row_h: float = 0.55,
    header_h: float = 0.45,
    header_fill: RGBColor = NAVY,
    header_color: RGBColor = WHITE,
    header_size: float = 9.5,
    body_size: float = 10.5,
):
    """`rows` includes the header row; each body cell is (text, color, bold, fill)."""
    assert rows and isinstance(rows[0][0], str), "first row must be header labels"
    total_h = header_h + row_h * (len(rows) - 1)
    table_shape = slide.shapes.add_table(
        len(rows), len(col_widths), Inches(x), Inches(y), Inches(w), Inches(total_h)
    )
    table = table_shape.table
    table.first_row = False
    table.horz_banding = False
    for index, cw in enumerate(col_widths):
        table.columns[index].width = Inches(cw)
    table.rows[0].height = Inches(header_h)
    for index in range(1, len(rows)):
        table.rows[index].height = Inches(row_h)

    for col, label in enumerate(rows[0]):
        style_cell(
            table.cell(0, col),
            label,
            size=header_size,
            bold=True,
            color=header_color,
            fill=header_fill,
        )
    body = rows[1:]
    offset = 1

    for r, row in enumerate(body, start=offset):
        for c, spec in enumerate(row):
            if isinstance(spec, str):
                spec = (spec, INK, False, WHITE)
            text, color, bold, fill = spec
            style_cell(
                table.cell(r, c),
                text,
                size=body_size,
                bold=bold,
                color=color,
                fill=fill,
            )
    return table_shape


# ------------------------------------------------------------ page chrome ---
class Deck:
    def __init__(self):
        self.prs = Presentation()
        self.prs.slide_width = Inches(SLIDE_W)
        self.prs.slide_height = Inches(SLIDE_H)
        self.index = 0
        self.checks: list[tuple[int, str, float, float, float]] = []

    def _blank(self):
        return self.prs.slides.add_slide(self.prs.slide_layouts[6])

    def slide(self, kicker: str, title: str, lede: str | None = None):
        s = self._blank()
        self.index += 1
        add_text(
            s,
            MARGIN,
            0.40,
            CONTENT_W,
            0.22,
            kicker.upper(),
            size=8.5,
            bold=True,
            color=BLUE,
        )
        add_text(
            s,
            MARGIN,
            0.66,
            CONTENT_W,
            0.58,
            title,
            size=26,
            bold=True,
            color=NAVY,
        )
        if lede:
            add_text(
                s,
                MARGIN,
                1.25,
                CONTENT_W,
                0.32,
                lede,
                size=13,
                color=STEEL,
            )
        add_rule(s, MARGIN, 1.72, SLIDE_W - MARGIN, 1.72, LINE, 0.9)
        add_rule(s, MARGIN, 7.03, SLIDE_W - MARGIN, 7.03, LINE, 0.75)
        add_text(
            s,
            MARGIN,
            7.12,
            CONTENT_W - 1.0,
            0.18,
            "OWASP Top 10 Pocket Guide  ·  Working draft  ·  OWASP project",
            size=7.5,
            color=MUTED,
        )
        add_text(
            s,
            SLIDE_W - MARGIN - 1.0,
            7.12,
            1.0,
            0.18,
            f"{self.index} / {TOTAL_SLIDES}",
            size=7.5,
            color=MUTED,
            align=PP_ALIGN.RIGHT,
        )
        return s

    def note(self, slide, text: str):
        slide.notes_slide.notes_text_frame.text = text

    def save(self):
        OUT.parent.mkdir(parents=True, exist_ok=True)
        self.prs.save(OUT)


# ------------------------------------------------------------------ slides ---
def slide_title(deck: Deck):
    s = deck._blank()
    deck.index += 1
    s.background.fill.solid()
    s.background.fill.fore_color.rgb = NAVY

    # Quiet geometric motif; no meaning beyond depth.
    for x, y, size in ((9.7, -1.6, 5.4), (11.3, 4.15, 3.2)):
        ring = s.shapes.add_shape(
            MSO_SHAPE.OVAL, Inches(x), Inches(y), Inches(size), Inches(size)
        )
        ring.fill.background()
        ring.line.color.rgb = BLUE_LIGHT
        ring.line.width = Pt(1.2)

    add_rect(
        s, 0.85, 0.85, 0.72, 0.72, fill=WHITE, line=BLUE_LIGHT, line_w=1,
        shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.18,
    )
    s.shapes.add_picture(
        str(LOGO), Inches(0.90), Inches(0.90), Inches(0.62), Inches(0.62)
    )
    add_text(
        s, 1.78, 1.11, 8.0, 0.28,
        "PROJECT BRIEFING   ·   22 OCTOBER 2026",
        size=9, bold=True, color=RGBColor.from_string("A9BEDD"),
    )

    add_text(
        s, 0.85, 2.30, 10.6, 1.70,
        [
            {"text": "OWASP Top 10", "size": 46, "bold": True, "color": WHITE},
            {"text": "Pocket Guide", "size": 46, "bold": True, "color": WHITE},
        ],
        line_spacing=0.95,
    )
    add_rect(s, 0.87, 4.18, 1.15, 0.07, fill=YELLOW)
    add_text(
        s, 0.85, 4.42, 10.0, 0.45,
        "Six editions. One offline reference.",
        size=21, color=RGBColor.from_string("C9D6EA"),
    )

    chips = [
        ("WORKING DRAFT", 1.75, YELLOW, NAVY, True),
        ("OWASP PROJECT", 2.35, BLUE_LIGHT, RGBColor.from_string("D7E2F2"), False),
        ("SME REVIEW PENDING", 2.95, BLUE_LIGHT, RGBColor.from_string("D7E2F2"), False),
    ]
    x = 0.85
    for label, w, edge, text_color, filled in chips:
        add_chip(
            s, x, 5.35, w, 0.38, label, edge,
            fill=YELLOW if filled else None,
            text_color=text_color, size=8.5,
        )
        x += w + 0.18

    add_text(
        s, 0.85, 6.75, 11.0, 0.25,
        "Prepared for stakeholder review  ·  Content status: draft, awaiting SME sign-off",
        size=9, color=RGBColor.from_string("8FA5C6"),
    )
    deck.note(
        s,
        "Say early and plainly: this is OWASP Top 10 Pocket Guide, an OWASP "
        "project, and the content is a draft pending SME review. Then set the "
        "agenda: what exists, how it is designed and built, and the decisions needed.",
    )


def slide_problem(deck: Deck):
    s = deck.slide(
        "The problem",
        "Six lists, six PDFs, one practitioner",
        "The guidance is authoritative. Finding it at the moment of need is not.",
    )
    bullets = [
        (
            "Fragmented by discipline",
            "Web, API, LLM, agentic skills, agentic applications and MCP guidance live "
            "in separate documents, with separate numbering and separate revision dates.",
        ),
        (
            "Citations get lost",
            "Copied notes rarely keep the edition, the category number or the link "
            "back to the source, so a summary becomes an opinion.",
        ),
        (
            "Offline is the normal case",
            "Incident rooms, client sites and travel are exactly where connectivity "
            "is worst, and exactly where a checklist is needed.",
        ),
    ]
    y = 2.02
    for title, body in bullets:
        add_rect(s, MARGIN, y + 0.08, 0.055, 0.78, fill=BLUE)
        add_text(
            s, MARGIN + 0.22, y, 6.55, 0.28,
            title, size=14, bold=True, color=NAVY,
        )
        add_text(
            s, MARGIN + 0.22, y + 0.31, 6.55, 0.75,
            body, size=12, color=STEEL, line_spacing=1.12,
        )
        y += 1.35

    add_rect(
        s, 7.75, 2.02, 4.78, 3.10,
        fill=NAVY, shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.05,
    )
    add_text(
        s, 8.08, 2.35, 4.15, 0.25,
        "DESIGN PRINCIPLE", size=8.5, bold=True,
        color=RGBColor.from_string("9DB4D8"),
    )
    add_text(
        s, 8.08, 2.78, 4.1, 1.9,
        "A summary without a source is just an opinion.",
        size=24, bold=True, color=WHITE, line_spacing=1.05,
    )
    add_rect(s, 8.1, 3.95, 0.9, 0.05, fill=YELLOW)
    add_text(
        s, 8.08, 4.14, 4.1, 0.5,
        "Every screen carries its citation.",
        size=11, color=RGBColor.from_string("C9D6EA"),
    )

    add_text(
        s, MARGIN, 6.35, CONTENT_W, 0.3,
        "So the app had to be offline, cited, and small enough to use in a queue.",
        size=12, bold=True, color=BLUE,
    )
    deck.note(
        s,
        "Most teams now work across web, API, cloud-native and model "
        "integrations at once. The gap is not another PDF; it is a trustworthy "
        "lookup that still points back to the official document.",
    )


def slide_scope(deck: Deck):
    s = deck.slide(
        "What exists today",
        "A complete draft, not a mock-up",
        "One Android app. No account, no network permission, no analytics.",
    )
    stats = [
        ("6", "editions"),
        ("60", "risk entries"),
        ("30", "quiz questions"),
        ("13", "cheatsheets"),
    ]
    tile_w = 2.72
    gap = 0.28
    for i, (number, label) in enumerate(stats):
        x = MARGIN + i * (tile_w + gap)
        add_rect(
            s, x, 2.02, tile_w, 1.78,
            fill=WASH, line=LINE, line_w=0.9,
            shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.055,
        )
        add_text(
            s, x + 0.24, 2.20, tile_w - 0.4, 0.75,
            number, size=44, bold=True, color=NAVY,
        )
        add_text(
            s, x + 0.26, 3.02, tile_w - 0.4, 0.3,
            label, size=11.5, color=STEEL,
        )

    add_text(
        s, MARGIN, 4.16, CONTENT_W, 0.3,
        "Every edition uses the same structure and the same review rules.",
        size=12, color=STEEL,
    )

    x = MARGIN
    y = 4.68
    for label, color in EDITIONS:
        w = 1.75
        add_rect(
            s, x, y, w, 0.42, fill=WHITE, line=LINE, line_w=0.9,
            shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.45,
        )
        add_rect(s, x + 0.14, y + 0.14, 0.14, 0.14, fill=color, shape=MSO_SHAPE.OVAL)
        add_text(
            s, x + 0.34, y + 0.11, w - 0.4, 0.22,
            label, size=8.5, bold=True, color=INK,
        )
        x += w + 0.16

    add_text(
        s, MARGIN, 5.48, CONTENT_W, 0.6,
        "Each risk: summary, real-world example, vulnerable and secure code, "
        "how to test, how to fix, and the official citation.",
        size=12, color=STEEL, line_spacing=1.15,
    )

    add_rect(s, MARGIN, 6.18, CONTENT_W, 0.62, fill=PALE, line=None,
             shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.08)
    add_text(
        s, MARGIN + 0.22, 6.32, CONTENT_W - 0.44, 0.3,
        "Built and verified: app, content, search, progress, accessibility and tests.",
        size=11.5, bold=True, color=BLUE,
    )
    deck.note(
        s,
        "This is a working app, not a prototype. All six editions have ten risks, "
        "five questions and at least two cheatsheets, and every risk shares one "
        "structure. That structure is what makes search, review and updates tractable.",
    )


def slide_tabs(deck: Deck):
    s = deck.slide(
        "The experience",
        "Five tabs, one learning loop",
        "Each tab answers one question. Accessibility is a tab, not a settings screen.",
    )
    shots = [
        ("learn-light.png", ("Learn", "What is this risk?")),
        ("practice-light.png", ("Practice", "Do I understand it?")),
        ("sheets-light.png", ("Sheets", "What do I check?")),
        ("progress-light.png", ("Progress", "What have I covered?")),
        ("access-light.png", ("Access", "Make it work for me")),
    ]
    height = 3.92
    width = height * 1080 / 2400
    gap = 0.24
    total = len(shots) * width + (len(shots) - 1) * gap
    x = MARGIN + (CONTENT_W - total) / 2
    for filename, caption in shots:
        add_phone(s, filename, x, 2.0, height, caption=caption)
        x += width + gap
    deck.note(
        s,
        "The loop is look it up, test yourself, revise, see coverage, adjust the "
        "experience. The fifth tab is deliberate: this material is read by people "
        "with very different access needs, so accessibility is a first-class place.",
    )


def slide_lookup(deck: Deck):
    s = deck.slide(
        "Learn and risk detail",
        "Look it up, then go deeper",
        "Search stays inside the selected edition; editions are never blended.",
    )
    add_phone(s, "learn-light.png", 0.82, 2.0, 4.5)
    add_phone(s, "detail-light.png", 3.02, 2.0, 4.5)

    x = 5.42
    w = SLIDE_W - MARGIN - x
    add_text(
        s, x, 2.02, w, 0.28,
        "Built for the moment of need",
        size=13, bold=True, color=NAVY,
    )
    items = [
        ("Search within the edition", "Capped at 120 characters, with invisible formatting characters removed."),
        ("Six edition filters", "One edition at a time, so Web A01 never blurs with API1."),
        ("Local read state", "Read markers and bookmarks survive restarts; they never leave the device."),
        ("Three detail tabs", "Overview explains it, Code shows vulnerable and secure samples, Defend gives test and fix."),
        ("A citation on every risk", "The official source, the review state and the last-reviewed date."),
    ]
    y = 2.42
    for title, body in items:
        add_text(s, x, y, 0.22, 0.3, "—", size=11, bold=True, color=BLUE)
        add_text(s, x + 0.24, y - 0.02, w - 0.24, 0.28, title, size=11.5, bold=True, color=INK)
        add_text(s, x + 0.24, y + 0.26, w - 0.24, 0.5, body, size=10.5, color=STEEL, line_spacing=1.1)
        y += 0.84

    add_text(
        s, x, 6.62, w, 0.24,
        "Draft banner shown on every content screen until sign-off.",
        size=9, color=MUTED,
    )
    deck.note(
        s,
        "Search is scoped to the selected edition because the numbering is not "
        "interchangeable. The detail screen splits into Overview, Code and Defend, "
        "and every risk ends with its official source and review date. Note the "
        "draft banner: we leave it visible on purpose.",
    )


def slide_design(deck: Deck):
    s = deck.slide(
        "Design",
        "A system, not a coat of paint",
        "OWASP blue chrome, with an accent for every edition and every tab.",
    )
    add_phone(s, "navigation-dark.png", 0.82, 2.0, 4.5)

    x = 3.25
    w = SLIDE_W - MARGIN - x

    add_text(s, x, 2.02, w, 0.22, "EDITION ACCENTS", size=8.5, bold=True, color=MUTED)
    cx = x
    for label, color in EDITIONS:
        add_rect(
            s, cx, 2.28, 1.28, 0.36, fill=WHITE, line=LINE, line_w=0.8,
            shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.45,
        )
        add_rect(s, cx + 0.10, 2.40, 0.12, 0.12, fill=color, shape=MSO_SHAPE.OVAL)
        add_text(
            s, cx + 0.27, 2.355, 1.0, 0.2,
            SHORT_EDITION_LABELS.get(label, label),
            size=7.8, bold=True, color=INK,
        )
        cx += 1.40

    add_text(s, x, 2.92, w, 0.22, "TAB ACCENTS", size=8.5, bold=True, color=MUTED)
    cx = x
    for label, color in TABS:
        add_rect(
            s, cx, 3.18, 1.12, 0.36, fill=WHITE, line=LINE, line_w=0.8,
            shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.45,
        )
        add_rect(s, cx + 0.10, 3.30, 0.12, 0.12, fill=color, shape=MSO_SHAPE.OVAL)
        add_text(s, cx + 0.27, 3.255, 0.82, 0.2, label, size=8, bold=True, color=INK)
        cx += 1.24

    bullets = [
        ("One seed, three themes", "Light, dark and high contrast are generated from the same palette, not hand-tuned separately."),
        ("Luminance, not guesswork", "Accent lightness is solved so text stays above 4.5:1 on tinted surfaces."),
        ("Neutral selection pill", "High-contrast schemes invert container colours, so the selected tab uses a neutral tone."),
        ("Hand-drawn glyphs", "Five marks share one 24 px grid and one stroke weight."),
    ]
    y = 3.82
    for title, body in bullets:
        add_text(s, x, y, w, 0.26, title, size=11.5, bold=True, color=NAVY)
        add_text(s, x, y + 0.24, w, 0.34, body, size=10.5, color=STEEL, line_spacing=1.1)
        y += 0.70

    deck.note(
        s,
        "The chrome is seeded from OWASP blue. Each edition and each tab has its "
        "own hue, so place is recognisable at a glance. Everything is generated from "
        "one seed and a luminance target, which is why the three themes stay coherent.",
    )


def slide_access(deck: Deck):
    s = deck.slide(
        "Accessibility",
        "Accessibility is a tab, not an afterthought",
        "Settings combine with the system rather than overriding it.",
    )
    add_phone(s, "access-light.png", 0.82, 2.0, 4.5)

    x = 3.28
    w = SLIDE_W - MARGIN - x
    items = [
        ("Contrast that is tested", "WCAG 2.2 AA for every text and UI pair, in light, dark and high-contrast themes."),
        ("Text that still fits", "200% scaling with no overflow; long code scrolls horizontally instead of truncating."),
        ("Screen-reader semantics", "Read state, quiz feedback and progress are labelled and announced."),
        ("Touch targets", "At least 48 dp for every control, including the filter chips."),
        ("Real preferences", "Theme, text size, high contrast, readable spacing and reduced motion are saved on the device."),
        ("A live status row", "Screen-reader state is shown in the app, with a shortcut to Android settings."),
    ]
    y = 2.0
    for title, body in items:
        add_rect(s, x, y + 0.06, 0.14, 0.14, fill=GREEN, shape=MSO_SHAPE.OVAL)
        add_text(s, x + 0.28, y - 0.02, w - 0.28, 0.26, title, size=11.5, bold=True, color=NAVY)
        add_text(s, x + 0.28, y + 0.24, w - 0.28, 0.42, body, size=10.5, color=STEEL, line_spacing=1.1)
        y += 0.74

    add_rect(
        s, x, 6.52, w, 0.42, fill=WASH, line=LINE, line_w=0.8,
        shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.2,
    )
    add_text(
        s, x + 0.16, 6.61, w - 0.32, 0.24,
        "Contrast asserted in test/app/theme_contrast_test.dart",
        size=8.5, font=MONO, color=STEEL,
    )
    deck.note(
        s,
        "Accessibility was a requirement, not a polish pass. Contrast is asserted "
        "mathematically in tests; the layout survives 200% text; TalkBack was tested "
        "on and off. The in-app settings layer on top of the system font scale.",
    )


def slide_architecture(deck: Deck):
    s = deck.slide(
        "Technology",
        "A small, layered architecture",
        "Screens read state; state reads repositories; repositories read immutable inputs.",
    )

    def band(y, label, content, fill=WASH):
        add_rect(
            s, MARGIN, y, CONTENT_W, 0.80, fill=fill, line=LINE, line_w=0.9,
            shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.08,
        )
        add_text(s, MARGIN + 0.22, y + 0.27, 1.9, 0.26, label, size=8.5, bold=True, color=BLUE)
        add_text(s, MARGIN + 2.25, y + 0.18, CONTENT_W - 2.5, 0.46, content,
                 size=12, color=INK, anchor=MSO_ANCHOR.MIDDLE)

    band(1.98, "PRESENTATION", "Learn  ·  Practice  ·  Sheets  ·  Progress  ·  Access")
    add_down_arrow(s, SLIDE_W / 2, 2.82, 0.20)
    band(3.05, "STATE", "Riverpod providers  ·  app settings  ·  routing")
    add_down_arrow(s, SLIDE_W / 2, 3.89, 0.20)

    # Two repositories side by side.
    repo_y = 4.12
    repo_h = 0.80
    left_w = 6.0
    right_w = CONTENT_W - left_w - 0.28
    add_rect(
        s, MARGIN, repo_y, left_w, repo_h, fill=WHITE, line=LINE, line_w=0.9,
        shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.08,
    )
    add_text(s, MARGIN + 0.22, repo_y + 0.16, left_w - 0.44, 0.24,
             "CONTENT REPOSITORY", size=8.5, bold=True, color=BLUE)
    add_text(s, MARGIN + 0.22, repo_y + 0.42, left_w - 0.44, 0.26,
             "Loader + schema validator", size=11, color=INK)
    add_rect(
        s, MARGIN + left_w + 0.28, repo_y, right_w, repo_h, fill=WHITE,
        line=LINE, line_w=0.9, shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.08,
    )
    add_text(s, MARGIN + left_w + 0.50, repo_y + 0.16, right_w - 0.44, 0.24,
             "PROGRESS REPOSITORY", size=8.5, bold=True, color=BLUE)
    add_text(s, MARGIN + left_w + 0.50, repo_y + 0.42, right_w - 0.44, 0.26,
             "Read state, bookmarks, quiz history", size=11, color=INK)

    add_down_arrow(s, MARGIN + left_w / 2, 4.96, 0.20)
    add_down_arrow(s, MARGIN + left_w + 0.28 + right_w / 2, 4.96, 0.20)

    src_y = 5.19
    add_rect(
        s, MARGIN, src_y, left_w, repo_h, fill=PALE, line=LINE, line_w=0.9,
        shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.08,
    )
    add_text(s, MARGIN + 0.22, src_y + 0.16, left_w - 0.44, 0.24,
             "IMMUTABLE INPUT", size=8.5, bold=True, color=BLUE)
    add_text(s, MARGIN + 0.22, src_y + 0.42, left_w - 0.44, 0.26,
             "assets/content/bundle.json  (120 KB)", size=11, color=INK, font=MONO)
    add_rect(
        s, MARGIN + left_w + 0.28, src_y, right_w, repo_h, fill=PALE,
        line=LINE, line_w=0.9, shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.08,
    )
    add_text(s, MARGIN + left_w + 0.50, src_y + 0.16, right_w - 0.44, 0.24,
             "DEVICE STORE", size=8.5, bold=True, color=BLUE)
    add_text(s, MARGIN + left_w + 0.50, src_y + 0.42, right_w - 0.44, 0.26,
             "Drift / SQLite, schema v2", size=11, color=INK)

    add_text(
        s, MARGIN, 6.32, CONTENT_W, 0.3,
        "The content layer has no dependency on Flutter widgets — the same bundle drives the app and the review packet.",
        size=10.5, color=STEEL,
    )
    deck.note(
        s,
        "The architecture is deliberately boring. Screens depend on providers, "
        "providers on two repositories, and the repositories on the bundled JSON and "
        "the local database. The content layer knows nothing about widgets, which is "
        "why the app and the SME packet can share one source.",
    )


def slide_pipeline(deck: Deck):
    s = deck.slide(
        "Content",
        "One source of truth, validated twice",
        "The app and the review packet are generated from the same file.",
    )
    steps = [
        ("01", "Official editions", "OWASP Web, API, LLM, Agentic Skills, Agentic Applications and MCP material."),
        ("02", "bundle.json", "Schema 1.0.0. Every risk, question, sheet and citation."),
        ("03", "Validator", "Unique IDs, answer ranges, links, citations, no HTML."),
        ("04", "Runtime", "Loaded once and validated again; failure closes the screen."),
        ("05", "Review packet", "Six sheets and a 60-row sign-off CSV."),
    ]
    w = 2.06
    gap = 0.38
    x = MARGIN + (CONTENT_W - (5 * w + 4 * gap)) / 2
    y = 2.28
    for index, (number, title, body) in enumerate(steps):
        add_rect(
            s, x, y, w, 1.42, fill=WHITE, line=LINE, line_w=0.9,
            shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.07,
        )
        add_text(s, x + 0.18, y + 0.14, w - 0.3, 0.2, number, size=8, bold=True, color=MUTED)
        add_text(s, x + 0.18, y + 0.38, w - 0.3, 0.28, title, size=12, bold=True, color=NAVY)
        add_text(s, x + 0.18, y + 0.70, w - 0.32, 0.62, body, size=9, color=STEEL, line_spacing=1.1)
        if index < len(steps) - 1:
            add_right_arrow(s, x + w + 0.07, y + 0.71, 0.24)
        x += w + gap

    add_rect(
        s, MARGIN, 4.06, CONTENT_W, 1.02, fill=WASH, line=LINE, line_w=0.9,
        shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.07,
    )
    add_text(s, MARGIN + 0.24, 4.20, 1.5, 0.22, "THE GATE", size=8.5, bold=True, color=RED)
    add_text(
        s, MARGIN + 1.55, 4.16, CONTENT_W - 1.8, 0.8,
        "A bundle becomes final only when every risk has named reviewers and a review date, "
        "the validator passes and the tests are green. Until then the app says draft, and a "
        "release build refuses to show it.",
        size=11.5, color=INK, line_spacing=1.12, anchor=MSO_ANCHOR.MIDDLE,
    )

    add_rect(
        s, MARGIN, 5.28, CONTENT_W, 0.92, fill=WHITE, line=LINE, line_w=0.9,
        shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.07,
    )
    add_text(s, MARGIN + 0.24, 5.40, 2.0, 0.22, "THE LOOP", size=8.5, bold=True, color=GREEN)
    add_text(
        s, MARGIN + 1.55, 5.38, CONTENT_W - 1.8, 0.68,
        "Corrections go back into the bundle and the packet is regenerated. There is no second "
        "copy of the content to drift from the app.",
        size=11.5, color=INK, line_spacing=1.12, anchor=MSO_ANCHOR.MIDDLE,
    )

    add_text(
        s, MARGIN, 6.42, CONTENT_W, 0.28,
        "Bundle 2026.10.4-draft  ·  schema 1.0.0  ·  60 risks  ·  30 questions  ·  13 cheatsheets",
        size=9.5, font=MONO, color=MUTED,
    )
    deck.note(
        s,
        "Content is data, not code. One JSON file holds every edition. The validator "
        "is the contract, and the same file generates the SME packet. That is why "
        "there is no second copy to drift.",
    )


def slide_stack(deck: Deck):
    s = deck.slide(
        "Technology",
        "Chosen for boring reliability",
        "A small team benefits more from predictable tools than from novel ones.",
    )
    rows = [
        ["Layer", "Choice", "Why"],
        ["Framework", "Flutter 3.47 / Dart", "One codebase, strong text scaling and semantics, an option on iOS later"],
        ["Design", "Material 3", "Familiar Android behaviour and accessible defaults"],
        ["State", "Riverpod 3", "Explicit, testable dependencies with no hidden global state"],
        ["Navigation", "go_router 18", "Typed routes and independent history in each tab"],
        ["Storage", "Drift / SQLite", "Durable local data with schema migrations (now v2)"],
        ["Content", "Validated JSON", "Reviewable outside the app; no coupling to UI code"],
    ]
    add_table(
        s, MARGIN, 1.98, CONTENT_W,
        [2.15, 3.35, 6.23],
        rows,
        row_h=0.62, header_h=0.46, body_size=11,
    )
    add_text(
        s, MARGIN, 6.54, CONTENT_W, 0.3,
        "No server, no CDN, no background sync and no third-party SDKs beyond these libraries.",
        size=10.5, color=STEEL,
    )
    deck.note(
        s,
        "None of these choices is exotic, and that is deliberate. Flutter gives one "
        "implementation of the design and accessibility behaviour. Drift already "
        "carried us through one schema migration when accessibility settings were added.",
    )


def slide_security(deck: Deck):
    s = deck.slide(
        "Security and privacy",
        "The safest data is the data you never collect",
        "No network path, no accounts, no telemetry — and a loader that fails closed.",
    )
    add_text(s, MARGIN, 2.0, 4.85, 0.55, "No network path.", size=30, bold=True, color=NAVY)
    add_text(
        s, MARGIN, 2.78, 4.8, 1.2,
        "The app declares no INTERNET permission. There is no server to breach, "
        "nothing to intercept and nothing to exfiltrate.",
        size=13, color=STEEL, line_spacing=1.14,
    )
    add_rect(s, MARGIN, 4.18, 4.8, 0.02, fill=LINE)
    add_text(
        s, MARGIN, 4.35, 4.8, 1.4,
        "Progress, bookmarks and quiz history live in a local SQLite database. "
        "Uninstalling the app removes them.",
        size=11, color=STEEL, line_spacing=1.14,
    )

    cards = [
        ("Fails closed", "Malformed or unreviewed content shows an error, never partial advice."),
        ("Draft gate", "A release build refuses to display draft content; only debug and profile builds run today."),
        ("Input hygiene", "Search is capped at 120 characters, strips invisible characters and treats metacharacters as text."),
        ("Local by default", "No account, no analytics, no advertising and no third-party network SDK."),
    ]
    x = 6.05
    w = SLIDE_W - MARGIN - x
    y = 2.0
    for title, body in cards:
        add_rect(
            s, x, y, w, 1.06, fill=WASH, line=LINE, line_w=0.9,
            shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.07,
        )
        add_text(s, x + 0.24, y + 0.14, w - 0.48, 0.26, title, size=12, bold=True, color=NAVY)
        add_text(s, x + 0.24, y + 0.42, w - 0.48, 0.54, body, size=10, color=STEEL, line_spacing=1.1)
        y += 1.18

    add_text(
        s, 6.05, 6.82, w, 0.22,
        "Search has no query language behind it, so SQL and HTML metacharacters stay literal.",
        size=9, color=MUTED,
    )
    deck.note(
        s,
        "The strongest privacy feature is the one we did not build: there is no "
        "network path. The strongest content control is the fail-closed loader and "
        "the release gate. We hit that gate ourselves while testing on a phone.",
    )


def slide_quality(deck: Deck):
    s = deck.slide(
        "Quality",
        "Automated where it can be, reviewed where it must be",
        "The tests protect structure and contrast. They cannot judge editorial accuracy.",
    )
    stats = [
        ("34", "tests passing"),
        ("0", "analyzer issues"),
        ("6", "editions validated"),
        ("60", "risks structure-checked"),
    ]
    tile_w = 2.72
    gap = 0.28
    for i, (number, label) in enumerate(stats):
        x = MARGIN + i * (tile_w + gap)
        add_rect(
            s, x, 1.98, tile_w, 1.42, fill=WASH, line=LINE, line_w=0.9,
            shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.06,
        )
        add_text(s, x + 0.22, 2.10, tile_w - 0.4, 0.62, number, size=36, bold=True, color=NAVY)
        add_text(s, x + 0.24, 2.80, tile_w - 0.4, 0.24, label, size=10, color=STEEL)

    left = [
        "Content rules, quiz integrity and citation coverage",
        "Theme contrast in light, dark and high contrast",
        "Search sanitisation and pasted-text limits",
        "Settings persistence across restarts",
    ]
    right = [
        "Review packet covers every risk and question",
        "Widget behaviour for the five tabs",
        "Database migration from schema v1 to v2",
        "Accessibility settings channel on Android",
    ]
    add_text(s, MARGIN, 3.72, 5.7, 0.24, "WHAT THE TESTS COVER", size=8.5, bold=True, color=MUTED)
    add_text(s, 6.4, 3.72, 5.7, 0.24, "ALSO COVERED", size=8.5, bold=True, color=MUTED)
    y = 4.02
    for item in left:
        add_text(s, MARGIN, y, 0.2, 0.24, "·", size=14, bold=True, color=GREEN)
        add_text(s, MARGIN + 0.22, y + 0.01, 5.4, 0.26, item, size=10.5, color=INK)
        y += 0.40
    y = 4.02
    for item in right:
        add_text(s, 6.4, y, 0.2, 0.24, "·", size=14, bold=True, color=GREEN)
        add_text(s, 6.62, y + 0.01, 5.2, 0.26, item, size=10.5, color=INK)
        y += 0.40

    add_rect(
        s, MARGIN, 5.90, CONTENT_W, 0.86, fill=AMBER_BG, line=None,
        shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.08,
    )
    add_text(
        s, MARGIN + 0.24, 6.02, CONTENT_W - 0.48, 0.62,
        "Not automated: whether the advice is correct. That is the SME review — the largest "
        "remaining task and the reason the bundle is still draft.",
        size=11, color=AMBER, line_spacing=1.1,
    )
    deck.note(
        s,
        "The tests are structural, not cosmetic: content validation, quiz integrity, "
        "theme contrast, search handling, settings persistence and review-packet "
        "coverage. What they cannot do is agree with OWASP. That is the SME review.",
    )


def slide_licensing(deck: Deck):
    s = deck.slide(
        "Licensing and branding",
        "Open content, marks confirmed",
        "The code and content licences and the OWASP marks are settled.",
    )
    rows = [
        ["Asset", "Position", "Status"],
        ["Source code", "GPL-3.0; licence file in the repository", "Cleared"],
        ["Web, API, LLM, Agentic Skills, Agentic Applications and MCP content", "CC BY-SA 4.0; attribution stored per edition", "Cleared"],
        ["OWASP name and logo", "Permission confirmed", "CLEARED"],
        ["Package ID", "com.example.top_10_app is a placeholder", "DECISION"],
    ]
    styled = [rows[0]]
    status_colors = [
        (GREEN, GREEN_BG),
        (GREEN, GREEN_BG),
        (GREEN, GREEN_BG),
        (AMBER, AMBER_BG),
    ]
    for row, (fg, bg) in zip(rows[1:], status_colors):
        styled.append([
            (row[0], INK, True, WHITE),
            (row[1], STEEL, False, WHITE),
            (row[2], fg, True, bg),
        ])
    add_table(
        s, MARGIN, 1.98, CONTENT_W,
        [3.55, 5.55, 2.63],
        styled,
        row_h=0.60, header_h=0.42, body_size=10.5,
    )

    add_rect(
        s, MARGIN, 5.62, CONTENT_W, 1.04, fill=WASH, line=LINE, line_w=0.9,
        shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.07,
    )
    add_text(
        s, MARGIN + 0.24, 5.74, CONTENT_W - 0.48, 0.82,
        "Attribution is stored with the content and shown on the About screen. The "
        "OWASP name and logo are used with permission for this project.",
        size=11, color=STEEL, line_spacing=1.12,
    )
    deck.note(
        s,
        "The code is GPL-3.0 and all six content editions are CC BY-SA 4.0. The "
        "name and logo permission is confirmed. The remaining blocker is content "
        "review.",
    )


def slide_status(deck: Deck):
    s = deck.slide(
        "Status",
        "Engineering is done; review is not",
        "What is built, what is draft, what is blocked and what has not started.",
    )
    quads = [
        ("BUILT AND VERIFIED", GREEN, GREEN_BG, [
            "Six editions, 60 risks, 30 questions, 13 sheets",
            "Search, read state, bookmarks, quiz history",
            "Accessibility settings and TalkBack support",
            "34 tests and a clean analyzer",
        ]),
        ("DRAFT", BLUE, PALE, [
            "Every risk is written and cited",
            "No named SME reviewer or review date",
            "Draft banner visible on every content screen",
            "Release builds refuse the bundle",
        ]),
        ("BLOCKED", RED, RED_BG, [
            "Release keystore and signing owner",
        ]),
        ("NOT STARTED", STEEL, WASH, [
            "Store listing and screenshots",
            "Privacy statement",
            "Pilot plan and support owner",
        ]),
    ]
    w = 5.78
    h = 2.18
    positions = [(MARGIN, 1.98), (MARGIN + w + 0.22, 1.98), (MARGIN, 4.32), (MARGIN + w + 0.22, 4.32)]
    for (title, color, bg, items), (x, y) in zip(quads, positions):
        add_rect(s, x, y, w, h, fill=WHITE, line=LINE, line_w=0.9,
                 shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.05)
        add_rect(s, x, y, 0.07, h, fill=color)
        add_text(s, x + 0.26, y + 0.14, w - 0.5, 0.22, title, size=8.5, bold=True, color=color)
        yy = y + 0.44
        for item in items:
            add_text(s, x + 0.26, yy, 0.18, 0.2, "·", size=12, bold=True, color=color)
            add_text(s, x + 0.44, yy, w - 0.7, 0.34, item, size=9.8, color=INK, line_spacing=1.02)
            yy += 0.38
    deck.note(
        s,
        "Engineering is essentially complete. The remaining work is review and "
        "release mechanics. The main product risk is that a polished "
        "draft gets treated as reviewed advice, which is what the draft gate prevents.",
    )


def slide_roadmap(deck: Deck):
    s = deck.slide(
        "Plan and decisions",
        "A release candidate in about five weeks",
        "The schedule is dominated by review, not by code.",
    )
    milestones = [
        ("M1", "Review", "2 weeks"),
        ("M2", "Content final", "1 week"),
        ("M3", "Release candidate", "2 weeks"),
        ("M4", "Pilot", "2–4 weeks"),
        ("M5", "Release", "after M4"),
    ]
    line_y = 2.98
    add_rule(s, 1.15, line_y, 12.2, line_y, RGBColor.from_string("B9C7DC"), 1.5)
    xs = [1.15, 3.62, 6.09, 8.56, 11.03]
    for (code, name, duration), x in zip(milestones, xs):
        add_rect(s, x - 0.11, line_y - 0.11, 0.22, 0.22, fill=BLUE, shape=MSO_SHAPE.OVAL)
        add_text(s, x - 0.85, 2.10, 1.7, 0.22, code, size=8.5, bold=True, color=BLUE, align=PP_ALIGN.CENTER)
        add_text(s, x - 0.95, 2.34, 1.9, 0.28, name, size=11.5, bold=True, color=NAVY, align=PP_ALIGN.CENTER)
        add_text(s, x - 0.85, 3.16, 1.7, 0.24, duration, size=9, color=MUTED, align=PP_ALIGN.CENTER)

    add_text(s, MARGIN, 4.02, CONTENT_W, 0.26,
             "DECISIONS REQUESTED TODAY", size=8.5, bold=True, color=MUTED)
    decisions = [
        ("1", "Name reviewers", "At least one practitioner and one editor per edition."),
        ("2", "Fix the package ID", "Changing the app ID after release breaks upgrades."),
        ("3", "Confirm the branding route", "Permission recorded; confirm store and About wording."),
        ("4", "Pick distribution and signer", "Play internal testing first; organisation-owned keystore."),
        ("5", "Set a refresh cadence", "Review on each new OWASP edition and twice a year."),
    ]
    y = 4.38
    for index, (number, title, body) in enumerate(decisions):
        col = index % 2
        row = index // 2
        x = MARGIN + col * 5.95
        yy = y + row * 0.78
        add_rect(s, x, yy, 0.30, 0.30, fill=BLUE, shape=MSO_SHAPE.OVAL)
        add_text(s, x, yy + 0.055, 0.30, 0.2, number, size=8.5, bold=True,
                 color=WHITE, align=PP_ALIGN.CENTER)
        add_text(s, x + 0.42, yy - 0.01, 4.9, 0.24, title, size=11, bold=True, color=NAVY)
        add_text(s, x + 0.42, yy + 0.23, 4.9, 0.3, body, size=9.5, color=STEEL)
    deck.note(
        s,
        "If reviewers are named today, M1 starts this week. Decide the package ID "
        "before any external build.",
    )


def slide_close(deck: Deck):
    s = deck._blank()
    deck.index += 1
    s.background.fill.solid()
    s.background.fill.fore_color.rgb = NAVY

    for x, y, size in ((9.9, -1.8, 5.6), (11.6, 4.2, 3.0)):
        ring = s.shapes.add_shape(MSO_SHAPE.OVAL, Inches(x), Inches(y), Inches(size), Inches(size))
        ring.fill.background()
        ring.line.color.rgb = BLUE_LIGHT
        ring.line.width = Pt(1.2)

    add_text(s, 0.85, 1.55, 10.5, 0.3, "IN ONE LINE", size=9, bold=True,
             color=RGBColor.from_string("9DB4D8"))
    add_text(
        s, 0.85, 1.92, 10.2, 1.9,
        "Six editions. One pocket. Fully offline.",
        size=34, bold=True, color=WHITE, line_spacing=1.02,
    )
    add_rect(s, 0.87, 3.62, 1.15, 0.07, fill=YELLOW)
    add_text(
        s, 0.85, 3.86, 9.6, 0.34,
        "What we need: reviewers, a package ID, a branding route.",
        size=15, color=RGBColor.from_string("C9D6EA"),
    )

    asks = [
        ("Reviewers", "Named per edition, two-week window"),
        ("Identity", "Package ID and branding route"),
        ("Distribution", "Play testing first; organisation-owned signing key"),
    ]
    x = 0.85
    for title, body in asks:
        add_rect(
            s, x, 4.72, 3.72, 1.02, fill=RGBColor.from_string("14335F"),
            line=BLUE_LIGHT, line_w=0.8, shape=MSO_SHAPE.ROUNDED_RECTANGLE, radius=0.08,
        )
        add_text(s, x + 0.22, 4.86, 3.3, 0.24, title, size=11, bold=True, color=WHITE)
        add_text(s, x + 0.22, 5.14, 3.3, 0.44, body, size=9, color=RGBColor.from_string("C9D6EA"),
                 line_spacing=1.05)
        x += 3.88

    add_text(s, 0.85, 6.55, 11.0, 0.4, "Thank you  ·  questions and demo", size=13,
             color=RGBColor.from_string("A9BEDD"))
    add_text(s, 0.85, 6.92, 11.0, 0.24,
             "Working draft  ·  OWASP project",
             size=8, color=RGBColor.from_string("7E97BB"))
    deck.note(
        s,
        "Close on the ask: reviewers, a package ID, a branding route and a signing route. "
        "Offer the demo and leave time for questions. Repeat the status once more so "
        "nobody leaves thinking the content has been reviewed.",
    )


# -------------------------------------------------------------- text fit ----
def estimate_overflow(prs) -> list[str]:
    """A conservative, renderer-free estimate of text overflow.

    Arial averages roughly 0.5 em per character; we use 0.56 regular and 0.60
    bold to stay pessimistic. Line height is 1.22 em. It will not catch every
    case, but it catches copy that is far too long for its box.
    """
    warnings: list[str] = []
    for index, slide in enumerate(prs.slides, start=1):
        for shape in slide.shapes:
            if not shape.has_text_frame:
                continue
            tf = shape.text_frame
            text = tf.text.strip()
            if not text:
                continue
            width_in = Emu(shape.width).inches - Emu(tf.margin_left).inches - Emu(tf.margin_right).inches
            height_in = Emu(shape.height).inches - Emu(tf.margin_top).inches - Emu(tf.margin_bottom).inches
            if width_in <= 0.1:
                continue
            needed = 0.0
            for paragraph in tf.paragraphs:
                runs = [r for r in paragraph.runs if r.text]
                if not runs:
                    continue
                size = max((r.font.size.pt if r.font.size else 12) for r in runs)
                bold = any(r.font.bold for r in runs)
                factor = 0.60 if bold else 0.56
                chars_per_line = max(1, int(width_in * 72 / (size * factor)))
                # +1 because wrapping breaks at word boundaries.
                lines = math.ceil(len("".join(r.text for r in runs)) / chars_per_line)
                needed += lines * size * 1.22 / 72
                needed += (paragraph.space_before.pt if paragraph.space_before else 0) / 72
            if needed > height_in + 0.06:
                warnings.append(
                    f"slide {index}: '{text[:44]}…' needs ~{needed:.2f}in "
                    f"in a {height_in:.2f}in box"
                )
    return warnings


def main() -> int:
    deck = Deck()
    slide_title(deck)
    slide_problem(deck)
    slide_scope(deck)
    slide_tabs(deck)
    slide_lookup(deck)
    slide_design(deck)
    slide_access(deck)
    slide_architecture(deck)
    slide_pipeline(deck)
    slide_stack(deck)
    slide_security(deck)
    slide_quality(deck)
    slide_licensing(deck)
    slide_status(deck)
    slide_roadmap(deck)
    slide_close(deck)

    if deck.index != TOTAL_SLIDES:
        raise SystemExit(f"expected {TOTAL_SLIDES} slides, built {deck.index}")

    deck.save()
    prs = Presentation(str(OUT))
    warnings = estimate_overflow(prs)
    print(f"wrote {OUT.relative_to(ROOT)}")
    print(f"slides: {len(prs.slides)}  size: {OUT.stat().st_size / 1024:.0f} KB")
    if warnings:
        print(f"possible overflow in {len(warnings)} text boxes:")
        for warning in warnings:
            print("  -", warning)
        return 1
    print("text-fit estimate: no overflow flagged")
    return 0


if __name__ == "__main__":
    sys.exit(main())
