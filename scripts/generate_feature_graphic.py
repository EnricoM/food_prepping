#!/usr/bin/env python3
"""
Generate a 1024x500 feature graphic for the Recipe Keeper Play Store listing.
The layout mirrors the new brand direction: jute bag icon, soft greens,
and concise messaging about saving recipes, planning meals, and shopping smart.
"""

from pathlib import Path
from typing import Tuple

from PIL import Image, ImageDraw, ImageFont, ImageFilter

WIDTH, HEIGHT = 1024, 500
BG_TOP = (46, 125, 50)
BG_BOTTOM = (102, 187, 106)
ACCENT = (255, 255, 255, 220)
ACCENT_DARK = (255, 255, 255, 30)
TEXT_PRIMARY = (255, 255, 255)
TEXT_SECONDARY = (232, 245, 233)
CHIP_BG = (255, 255, 255, 35)
CHIP_TEXT = (244, 249, 244)
APP_ICON_PATH = Path("assets/app_icon.png")
OUTPUT_PATH = Path("assets/feature_graphic.png")


def load_font(size: int, weight: str = "bold") -> ImageFont.FreeTypeFont:
    """Load a DejaVu font bundled with Pillow; fall back to default."""
    font_name = "DejaVuSans-Bold.ttf" if weight == "bold" else "DejaVuSans.ttf"
    try:
        return ImageFont.truetype(font_name, size=size)
    except OSError:
        return ImageFont.load_default()


def draw_gradient(draw: ImageDraw.ImageDraw) -> None:
    """Vertical gradient background."""
    for y in range(HEIGHT):
        ratio = y / HEIGHT
        r = int(BG_TOP[0] * (1 - ratio) + BG_BOTTOM[0] * ratio)
        g = int(BG_TOP[1] * (1 - ratio) + BG_BOTTOM[1] * ratio)
        b = int(BG_TOP[2] * (1 - ratio) + BG_BOTTOM[2] * ratio)
        draw.line([(0, y), (WIDTH, y)], fill=(r, g, b))


def add_light_overlay(base: Image.Image) -> None:
    """Add curved translucent overlays for depth."""
    overlay = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    draw.pieslice(
        [(-WIDTH * 0.6, -HEIGHT * 0.8), (WIDTH * 0.9, HEIGHT * 1.2)],
        start=330,
        end=60,
        fill=ACCENT_DARK,
    )
    draw.pieslice(
        [(WIDTH * 0.2, -HEIGHT * 0.2), (WIDTH * 1.4, HEIGHT * 1.4)],
        start=170,
        end=260,
        fill=ACCENT_DARK,
    )
    base.alpha_composite(overlay)


def paste_app_icon(base: Image.Image) -> None:
    """Load and place the jute bag app icon on the right side."""
    if not APP_ICON_PATH.exists():
        return
    icon = Image.open(APP_ICON_PATH).convert("RGBA")
    icon_size = int(min(WIDTH, HEIGHT) * 0.75)
    icon = icon.resize((icon_size, icon_size), Image.LANCZOS)

    # Drop shadow
    shadow = Image.new("RGBA", icon.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse(
        [(icon_size * 0.05, icon_size * 0.7), (icon_size * 0.95, icon_size * 0.95)],
        fill=(0, 0, 0, 60),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=20))

    x = int(WIDTH * 0.58)
    y = int(HEIGHT * 0.12)
    base.alpha_composite(shadow, dest=(x, y + icon_size // 6))
    base.alpha_composite(icon, dest=(x, y))


def draw_text(base: Image.Image) -> None:
    draw = ImageDraw.Draw(base)
    title_font = load_font(72, "bold")
    subtitle_font = load_font(28, "regular")
    chip_font = load_font(26, "regular")

    def measure(text: str, font: ImageFont.ImageFont) -> Tuple[int, int]:
        bbox = draw.textbbox((0, 0), text, font=font)
        return bbox[2] - bbox[0], bbox[3] - bbox[1]

    title = "Recipe Keeper"
    subtitle = "Save from any website · Plan meals · Shop smart"

    # Measure title to ensure it fits
    title_w, title_h = measure(title, title_font)
    # Position with safe margin from left and ensure it doesn't overflow
    title_x = 50
    title_y = 100
    
    # Check if title would overflow (leave margin for icon on right)
    max_title_width = WIDTH * 0.5  # Leave space for icon
    if title_w > max_title_width:
        # Scale down font if needed
        scale = max_title_width / title_w
        new_size = int(72 * scale)
        title_font = load_font(new_size, "bold")
        title_w, title_h = measure(title, title_font)

    draw.text(
        (title_x, title_y),
        title,
        font=title_font,
        fill=TEXT_PRIMARY,
    )
    
    # Measure subtitle to ensure it fits
    subtitle_w, subtitle_h = measure(subtitle, subtitle_font)
    max_subtitle_width = WIDTH * 0.5  # Leave space for icon
    if subtitle_w > max_subtitle_width:
        # Scale down font if needed
        scale = max_subtitle_width / subtitle_w
        new_size = int(28 * scale)
        subtitle_font = load_font(new_size, "regular")
        subtitle_w, subtitle_h = measure(subtitle, subtitle_font)
    
    # Position subtitle below title with proper spacing
    subtitle_y = title_y + title_h + 20
    draw.text(
        (title_x, subtitle_y),
        subtitle,
        font=subtitle_font,
        fill=TEXT_SECONDARY,
    )

    chips = [
        "Personal recipe collection",
        "Smart meal planning",
        "Automated shopping lists",
    ]
    # Position chips below subtitle
    chip_y = subtitle_y + 50
    spacing = 18
    for chip in chips:
        w, h = measure(chip, chip_font)
        padding = 24
        rect = [
            (title_x, chip_y),
            (title_x + w + padding * 2, chip_y + h + padding),
        ]
        draw.rounded_rectangle(rect, radius=18, fill=CHIP_BG, outline=(255, 255, 255, 60))
        draw.text(
            (rect[0][0] + padding, rect[0][1] + padding / 2),
            chip,
            font=chip_font,
            fill=CHIP_TEXT,
        )
        chip_y += h + padding + spacing


def main() -> None:
    base = Image.new("RGBA", (WIDTH, HEIGHT))
    gradient_draw = ImageDraw.Draw(base)
    draw_gradient(gradient_draw)
    add_light_overlay(base)
    draw_text(base)
    paste_app_icon(base)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    base.save(OUTPUT_PATH, format="PNG")
    print(f"Feature graphic saved to {OUTPUT_PATH.resolve()}")


if __name__ == "__main__":
    main()

