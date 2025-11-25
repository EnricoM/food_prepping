#!/usr/bin/env python3
"""
Generate the Recipe Keeper app icon.
Creates a 1024x1024 PNG featuring a jute bag filled with vegetables.
"""

from PIL import Image, ImageDraw

# Palette
PRIMARY_GREEN = (67, 160, 71)  # background
DARK_GREEN = (27, 67, 50)
LIGHT_GRADIENT = (110, 199, 128)
JUTE_MAIN = (203, 164, 110)
JUTE_SHADOW = (175, 135, 86)
JUTE_HIGHLIGHT = (232, 199, 150)
CARROT_ORANGE = (245, 140, 66)
CARROT_SHADOW = (212, 110, 40)
LEAF_GREEN = (129, 199, 132)
DEEP_LEAF = (76, 175, 80)
TOMATO_RED = (233, 77, 77)
TOMATO_SHADOW = (193, 54, 54)
ONION_PURPLE = (186, 104, 200)
FORAGE_GREEN = (120, 170, 90)
STITCH_COLOR = (255, 255, 255, 120)

def create_app_icon():
    size = 1024
    center_x, center_y = size / 2, size / 2

    # Base image with rounded corners
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    corner_radius = size * 0.2

    # Gradient background
    for y in range(size):
        ratio = y / size
        r = int(PRIMARY_GREEN[0] * (1 - ratio * 0.15) + LIGHT_GRADIENT[0] * ratio * 0.05)
        g = int(PRIMARY_GREEN[1] * (1 - ratio * 0.1) + LIGHT_GRADIENT[1] * ratio * 0.05)
        b = int(PRIMARY_GREEN[2] * (1 - ratio * 0.05) + LIGHT_GRADIENT[2] * ratio * 0.05)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)
    img.putalpha(mask)

    base_draw = ImageDraw.Draw(img)
    padding = size * 0.03
    base_draw.rounded_rectangle(
        [(padding, padding), (size - padding, size - padding)],
        corner_radius * 0.9,
        outline=(0, 0, 0, 25),
        width=int(size * 0.012),
    )

    foreground = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    final_draw = ImageDraw.Draw(foreground)

    # Bag dimensions
    bag_width = size * 0.6
    bag_height = size * 0.5
    bag_top_width = bag_width * 0.85
    bag_x = center_x - bag_width / 2
    bag_y = center_y - bag_height / 2 + size * 0.15

    top_left = (center_x - bag_top_width / 2, bag_y - size * 0.05)
    top_right = (center_x + bag_top_width / 2, bag_y - size * 0.05)
    bottom_left = (bag_x, bag_y + bag_height)
    bottom_right = (bag_x + bag_width, bag_y + bag_height)

    # Back shadow of bag
    shadow_offset = size * 0.015
    shadow_points = [
        (top_left[0] + shadow_offset, top_left[1] + shadow_offset),
        (top_right[0] + shadow_offset, top_right[1] + shadow_offset),
        (bottom_right[0] + shadow_offset, bottom_right[1] + shadow_offset),
        (bottom_left[0] + shadow_offset, bottom_left[1] + shadow_offset),
    ]
    final_draw.polygon(shadow_points, fill=(0, 0, 0, 40))

    # Bag base
    bag_points = [top_left, top_right, bottom_right, bottom_left]
    final_draw.polygon(bag_points, fill=JUTE_MAIN, outline=JUTE_SHADOW)

    # Bag texture lines
    for i in range(5):
        y = bag_y + bag_height * 0.2 + i * (bag_height * 0.12)
        final_draw.line(
            [(bag_x + size * 0.05, y), (bag_x + bag_width - size * 0.05, y)],
            fill=(255, 255, 255, 40),
            width=int(size * 0.004),
        )

    # Front pocket
    pocket_height = bag_height * 0.28
    pocket_y = bag_y + bag_height * 0.55
    pocket_radius = size * 0.04
    final_draw.rounded_rectangle(
        [
            (bag_x + bag_width * 0.12, pocket_y),
            (bag_x + bag_width * 0.88, pocket_y + pocket_height),
        ],
        pocket_radius,
        fill=JUTE_HIGHLIGHT,
        outline=JUTE_SHADOW,
        width=int(size * 0.01),
    )

    # Pocket stitches
    stitch_count = 8
    stitch_spacing = (bag_width * 0.76) / (stitch_count - 1)
    start_x = bag_x + bag_width * 0.12
    for i in range(stitch_count):
        x = start_x + i * stitch_spacing
        final_draw.line(
            [(x, pocket_y - size * 0.01), (x, pocket_y + pocket_height + size * 0.01)],
            fill=STITCH_COLOR,
            width=int(size * 0.006),
        )

    # Vegetables (drawn before bag lip)
    def draw_leaf_bundle(cx, cy, scale=1.0):
        leaf_width = size * 0.07 * scale
        leaf_height = size * 0.16 * scale
        for offset in (-leaf_width * 0.8, 0, leaf_width * 0.8):
            final_draw.ellipse(
                [
                    (cx + offset - leaf_width / 2, cy - leaf_height),
                    (cx + offset + leaf_width / 2, cy),
                ],
                fill=LEAF_GREEN if offset != 0 else DEEP_LEAF,
                outline=None,
            )

    def draw_carrot(cx, cy, scale=1.0):
        carrot_height = size * 0.22 * scale
        carrot_width = size * 0.07 * scale
        body = [
            (cx - carrot_width / 2, cy),
            (cx + carrot_width / 2, cy),
            (cx, cy + carrot_height),
        ]
        final_draw.polygon(body, fill=CARROT_ORANGE, outline=CARROT_SHADOW)
        final_draw.line(
            [(cx, cy), (cx, cy - carrot_height * 0.35)],
            fill=DEEP_LEAF,
            width=int(size * 0.01),
        )
        draw_leaf_bundle(cx, cy - carrot_height * 0.3, scale=0.7)

    def draw_tomato(cx, cy, scale=1.0):
        radius = size * 0.07 * scale
        final_draw.ellipse(
            [(cx - radius, cy - radius), (cx + radius, cy + radius)],
            fill=TOMATO_RED,
            outline=TOMATO_SHADOW,
        )
        # Tomato leaves
        leaf_radius = radius * 0.6
        for angle in range(0, 360, 60):
            offset_x = leaf_radius * 0.7
            offset_y = leaf_radius * 0.4
            final_draw.ellipse(
                [
                    (cx - offset_x + angle * 0.1, cy - radius - offset_y),
                    (cx + offset_x - angle * 0.1, cy - radius + offset_y),
                ],
                fill=FORAGE_GREEN,
                outline=None,
            )

    def draw_onion(cx, cy, scale=1.0):
        bulb_width = size * 0.1 * scale
        bulb_height = size * 0.16 * scale
        final_draw.ellipse(
            [
                (cx - bulb_width / 2, cy - bulb_height),
                (cx + bulb_width / 2, cy + bulb_height * 0.1),
            ],
            fill=ONION_PURPLE,
            outline=(120, 59, 140),
        )
        # Shoots
        for i in range(3):
            offset = (i - 1) * bulb_width * 0.15
            final_draw.line(
                [
                    (cx + offset, cy - bulb_height),
                    (cx + offset * 1.2, cy - bulb_height - size * (0.12 - i * 0.01)),
                ],
                fill=FORAGE_GREEN,
                width=int(size * 0.01),
            )

    veggie_base_y = bag_y - size * 0.02
    draw_carrot(center_x - bag_width * 0.22, veggie_base_y, scale=1.05)
    draw_leaf_bundle(center_x + bag_width * 0.1, veggie_base_y - size * 0.02, scale=1.1)
    draw_tomato(center_x + bag_width * 0.02, veggie_base_y + size * 0.04, scale=1.0)
    draw_onion(center_x - bag_width * 0.02, veggie_base_y - size * 0.05, scale=0.9)

    # Bag lip
    lip_height = size * 0.06
    final_draw.rectangle(
        [
            (top_left[0], top_left[1] - lip_height / 2),
            (top_right[0], top_right[1] + lip_height / 2),
        ],
        fill=JUTE_HIGHLIGHT,
        outline=JUTE_SHADOW,
    )

    # Rope tie
    rope_y = top_left[1] + lip_height * 0.2
    final_draw.line(
        [
            (top_left[0] + size * 0.08, rope_y),
            (top_right[0] - size * 0.08, rope_y),
        ],
        fill=JUTE_SHADOW,
        width=int(size * 0.018),
    )
    # Knot
    final_draw.ellipse(
        [
            (center_x - size * 0.035, rope_y - size * 0.02),
            (center_x + size * 0.035, rope_y + size * 0.02),
        ],
        fill=JUTE_SHADOW,
        outline=None,
    )

    # Overlay highlights
    highlight = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    highlight_draw = ImageDraw.Draw(highlight)
    highlight_draw.pieslice(
        [
            (-size * 0.2, -size * 0.2),
            (size * 1.0, size * 0.8),
        ],
        start=0,
        end=90,
        fill=(255, 255, 255, 30),
    )
    combined = Image.alpha_composite(img, foreground)
    combined = Image.alpha_composite(combined, highlight)
    return combined

if __name__ == '__main__':
    icon = create_app_icon()
    
    # Create assets directory if it doesn't exist
    import os
    os.makedirs('assets', exist_ok=True)
    
    # Save the icon
    icon_path = 'assets/app_icon.png'
    icon.save(icon_path, 'PNG')
    print(f'App icon created: {icon_path}')
    print(f'Size: {icon.size[0]}x{icon.size[1]}')

