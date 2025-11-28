#!/usr/bin/env python3
"""
Convert SVG app icon to PNG format for Flutter app.
Requires: cairosvg or inkscape
"""

import subprocess
import sys
import os

def convert_with_cairosvg(svg_path, png_path):
    """Convert SVG to PNG using cairosvg"""
    try:
        import cairosvg
        cairosvg.svg2png(url=svg_path, write_to=png_path, output_width=1024, output_height=1024)
        print(f"✅ Successfully converted {svg_path} to {png_path}")
        return True
    except ImportError:
        print("❌ cairosvg not installed. Install with: pip install cairosvg")
        return False
    except Exception as e:
        print(f"❌ Error with cairosvg: {e}")
        return False

def convert_with_inkscape(svg_path, png_path):
    """Convert SVG to PNG using inkscape"""
    try:
        subprocess.run([
            'inkscape',
            svg_path,
            '--export-type=png',
            f'--export-filename={png_path}',
            '--export-width=1024',
            '--export-height=1024'
        ], check=True, capture_output=True)
        print(f"✅ Successfully converted {svg_path} to {png_path}")
        return True
    except FileNotFoundError:
        print("❌ inkscape not found. Install with: sudo apt install inkscape")
        return False
    except subprocess.CalledProcessError as e:
        print(f"❌ Error with inkscape: {e}")
        return False

def main():
    svg_file = 'assets/app_icon_simple.svg'
    png_file = 'assets/app_icon.png'
    
    if not os.path.exists(svg_file):
        print(f"❌ SVG file not found: {svg_file}")
        sys.exit(1)
    
    print(f"Converting {svg_file} to {png_file}...")
    
    # Try cairosvg first (Python-based, easier to install)
    if convert_with_cairosvg(svg_file, png_file):
        sys.exit(0)
    
    # Try inkscape as fallback
    if convert_with_inkscape(svg_file, png_file):
        sys.exit(0)
    
    # If both fail, provide instructions
    print("\n" + "="*60)
    print("⚠️  Could not convert automatically.")
    print("="*60)
    print("\nOptions to convert SVG to PNG:")
    print("\n1. Install cairosvg (recommended):")
    print("   pip install cairosvg")
    print("   Then run this script again.")
    print("\n2. Install inkscape:")
    print("   sudo apt install inkscape")
    print("   Then run this script again.")
    print("\n3. Use online converter:")
    print("   - Go to https://cloudconvert.com/svg-to-png")
    print("   - Upload assets/app_icon_simple.svg")
    print("   - Set size to 1024x1024")
    print("   - Download and save as assets/app_icon.png")
    print("\n4. Use GIMP or other image editor:")
    print("   - Open assets/app_icon_simple.svg")
    print("   - Export as PNG, 1024x1024 pixels")
    sys.exit(1)

if __name__ == '__main__':
    main()

