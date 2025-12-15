#!/usr/bin/env python3
"""
Generate Android launcher icons in all required densities from the source icon.
"""

from PIL import Image
from pathlib import Path

# Android icon sizes for different densities
ICON_SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

SOURCE_ICON = Path('assets/app_icon.png')
ANDROID_RES_DIR = Path('android/app/src/main/res')


def generate_android_icons():
    """Generate all Android launcher icon sizes from source icon."""
    if not SOURCE_ICON.exists():
        print(f"Error: Source icon not found at {SOURCE_ICON}")
        return False
    
    # Load source icon
    source = Image.open(SOURCE_ICON).convert('RGBA')
    print(f"Loaded source icon: {source.size[0]}x{source.size[1]}")
    
    # Generate icons for each density
    for density, size in ICON_SIZES.items():
        density_dir = ANDROID_RES_DIR / density
        density_dir.mkdir(parents=True, exist_ok=True)
        
        # Resize icon
        icon = source.resize((size, size), Image.LANCZOS)
        
        # Save icon
        icon_path = density_dir / 'ic_launcher.png'
        icon.save(icon_path, 'PNG')
        print(f"Generated {density}/ic_launcher.png ({size}x{size})")
    
    print("\n✅ All Android launcher icons generated successfully!")
    return True


if __name__ == '__main__':
    generate_android_icons()

