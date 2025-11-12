#!/usr/bin/env python3
"""
Generate app icon for Recipe Parser / Food Prepping app
Creates a 1024x1024 PNG with a modern, food-themed design
"""

from PIL import Image, ImageDraw, ImageFont
import math

# App color scheme
PRIMARY_GREEN = (67, 160, 71)  # #43A047
DARK_GREEN = (27, 67, 50)  # #1B4332
LIGHT_GREEN = (233, 247, 238)  # #E9F7EE
WHITE = (255, 255, 255)
ACCENT_ORANGE = (255, 152, 0)  # For visual interest

def create_app_icon():
    size = 1024
    # Create image with rounded corners effect
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background - gradient-like effect with primary green
    # Draw rounded rectangle background
    corner_radius = size * 0.2
    # Create a mask for rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)
    
    # Fill with gradient-like background
    for y in range(size):
        # Subtle gradient from lighter to darker green
        ratio = y / size
        r = int(PRIMARY_GREEN[0] * (1 - ratio * 0.2))
        g = int(PRIMARY_GREEN[1] * (1 - ratio * 0.15))
        b = int(PRIMARY_GREEN[2] * (1 - ratio * 0.1))
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    # Apply rounded corners
    img.putalpha(mask)
    
    # Create a new image with the rounded background
    final_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    final_draw = ImageDraw.Draw(final_img)
    
    # Draw rounded rectangle background
    final_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=PRIMARY_GREEN)
    
    # Add subtle inner shadow/bevel effect
    padding = size * 0.03
    final_draw.rounded_rectangle(
        [(padding, padding), (size - padding, size - padding)],
        corner_radius * 0.9,
        fill=None,
        outline=(DARK_GREEN[0], DARK_GREEN[1], DARK_GREEN[2], 30),
        width=int(size * 0.01)
    )
    
    # Design: Recipe card with chef's hat
    center_x, center_y = size / 2, size / 2
    
    # Draw a stylized recipe card/notebook
    card_width = size * 0.6
    card_height = size * 0.5
    card_x = center_x - card_width / 2
    card_y = center_y - card_height / 2 + size * 0.05
    
    # Card background (white/light)
    card_radius = size * 0.05
    final_draw.rounded_rectangle(
        [(card_x, card_y), (card_x + card_width, card_y + card_height)],
        card_radius,
        fill=WHITE,
        outline=(DARK_GREEN[0], DARK_GREEN[1], DARK_GREEN[2], 100),
        width=int(size * 0.008)
    )
    
    # Add lines on the card (like a recipe notebook)
    line_spacing = card_height / 6
    for i in range(1, 6):
        y = card_y + line_spacing * i
        final_draw.line(
            [(card_x + card_width * 0.15, y), (card_x + card_width * 0.85, y)],
            fill=(200, 200, 200, 150),
            width=int(size * 0.003)
        )
    
    # Draw a simple chef's hat on top of the card
    hat_base_y = card_y - size * 0.08
    hat_width = size * 0.25
    hat_height = size * 0.15
    
    # Hat base (white band)
    hat_x = center_x - hat_width / 2
    final_draw.ellipse(
        [(hat_x, hat_base_y), (hat_x + hat_width, hat_base_y + hat_height * 0.4)],
        fill=WHITE,
        outline=(DARK_GREEN[0], DARK_GREEN[1], DARK_GREEN[2], 80),
        width=int(size * 0.005)
    )
    
    # Hat top (pleated)
    hat_top_y = hat_base_y - hat_height * 0.6
    # Draw pleats
    pleat_count = 5
    pleat_width = hat_width / pleat_count
    for i in range(pleat_count):
        pleat_x = hat_x + i * pleat_width
        # Create a pleat shape (triangle-like)
        points = [
            (pleat_x + pleat_width / 2, hat_top_y),
            (pleat_x, hat_base_y - hat_height * 0.3),
            (pleat_x + pleat_width, hat_base_y - hat_height * 0.3),
        ]
        final_draw.polygon(points, fill=WHITE, outline=(DARK_GREEN[0], DARK_GREEN[1], DARK_GREEN[2], 60))
    
    # Add a small accent - maybe a spoon or fork
    # Simple spoon on the side
    spoon_x = card_x + card_width * 0.85
    spoon_y = card_y + card_height * 0.3
    spoon_length = size * 0.12
    
    # Spoon handle
    final_draw.ellipse(
        [(spoon_x - size * 0.02, spoon_y), (spoon_x + size * 0.02, spoon_y + spoon_length * 0.7)],
        fill=DARK_GREEN,
        outline=None
    )
    # Spoon head
    final_draw.ellipse(
        [(spoon_x - size * 0.025, spoon_y + spoon_length * 0.65), 
         (spoon_x + size * 0.025, spoon_y + spoon_length)],
        fill=DARK_GREEN,
        outline=None
    )
    
    # Add some decorative elements - small circles (like ingredients)
    ingredient_size = size * 0.03
    ingredient_positions = [
        (card_x + card_width * 0.2, card_y + card_height * 0.2),
        (card_x + card_width * 0.35, card_y + card_height * 0.15),
        (card_x + card_width * 0.5, card_y + card_height * 0.25),
    ]
    
    for pos in ingredient_positions:
        final_draw.ellipse(
            [(pos[0] - ingredient_size/2, pos[1] - ingredient_size/2),
             (pos[0] + ingredient_size/2, pos[1] + ingredient_size/2)],
            fill=ACCENT_ORANGE,
            outline=None
        )
    
    return final_img

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

