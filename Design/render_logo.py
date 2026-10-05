"""Generates the Opzegwekker logo SVGs in Design/.

Change BASISAPPS_GREEN to the exact BasisApps colour and run:
    python3 Design/render_logo.py
Then render Design/logo.svg to Opzegwekker/App/Assets.xcassets/AppIcon.appiconset/AppIcon.png
(1024 x 1024, no alpha channel).
"""
import math
import pathlib

ORANGE = "#F26B1D"
PAPER = "#F6F3EE"
INK = "#1B1A18"
BASISAPPS_GREEN = "#22B573"  # placeholder: replace with the exact BasisApps green

CX, CY, R = 512, 532, 300
GAP_START, GAP_END, DOT_ANGLE = 22, 68, 45  # degrees clockwise from 12 o'clock


def point(degrees, radius=R):
    angle = math.radians(degrees - 90)
    return CX + radius * math.cos(angle), CY + radius * math.sin(angle)


def logo(background, mark):
    x1, y1 = point(GAP_END)
    x2, y2 = point(GAP_START)
    dx, dy = point(DOT_ANGLE)
    hx, hy = point(DOT_ANGLE, R * 0.55)
    return f"""<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="{background}"/>
  <!-- The ring: a subscription that keeps renewing, broken where you can cancel. -->
  <path d="M {x1:.1f} {y1:.1f} A {R} {R} 0 1 1 {x2:.1f} {y2:.1f}" fill="none" stroke="{mark}" stroke-width="88" stroke-linecap="round"/>
  <!-- The hand points at the moment to decide. -->
  <line x1="{CX}" y1="{CY}" x2="{hx:.1f}" y2="{hy:.1f}" stroke="{mark}" stroke-width="70" stroke-linecap="round"/>
  <circle cx="{CX}" cy="{CY}" r="52" fill="{mark}"/>
  <!-- The reminder: the BasisApps green dot, with a ring in the mark colour for contrast. -->
  <circle cx="{dx:.1f}" cy="{dy:.1f}" r="66" fill="{mark}"/>
  <circle cx="{dx:.1f}" cy="{dy:.1f}" r="46" fill="{BASISAPPS_GREEN}"/>
</svg>
"""


here = pathlib.Path(__file__).parent
(here / "logo.svg").write_text(logo(ORANGE, PAPER))
(here / "logo-inkt-oranje.svg").write_text(logo(INK, ORANGE))
(here / "logo-papier-inkt.svg").write_text(logo(PAPER, INK))
