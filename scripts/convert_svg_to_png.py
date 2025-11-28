#!/usr/bin/env python3
"""
Convert SVG to PNG using available methods.
Tries multiple approaches in order of preference.
"""

import subprocess
import sys
import os
import base64
import urllib.request
import urllib.parse
import json

def method1_cairosvg(svg_path, png_path):
    """Try using cairosvg (requires: pip install cairosvg)"""
    try:
        import cairosvg
        cairosvg.svg2png(
            url=svg_path,
            write_to=png_path,
            output_width=1024,
            output_height=1024
        )
        print(f"✅ Converted using cairosvg: {png_path}")
        return True
    except ImportError:
        return False
    except Exception as e:
        print(f"❌ cairosvg error: {e}")
        return False

def method2_inkscape(svg_path, png_path):
    """Try using inkscape command line"""
    try:
        result = subprocess.run([
            'inkscape',
            svg_path,
            '--export-type=png',
            f'--export-filename={png_path}',
            '--export-width=1024',
            '--export-height=1024'
        ], capture_output=True, text=True, timeout=30)
        if result.returncode == 0 and os.path.exists(png_path):
            print(f"✅ Converted using inkscape: {png_path}")
            return True
        return False
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False
    except Exception as e:
        print(f"❌ inkscape error: {e}")
        return False

def method3_rsvg_convert(svg_path, png_path):
    """Try using rsvg-convert (librsvg)"""
    try:
        result = subprocess.run([
            'rsvg-convert',
            '-w', '1024',
            '-h', '1024',
            '-o', png_path,
            svg_path
        ], capture_output=True, text=True, timeout=30)
        if result.returncode == 0 and os.path.exists(png_path):
            print(f"✅ Converted using rsvg-convert: {png_path}")
            return True
        return False
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False
    except Exception as e:
        print(f"❌ rsvg-convert error: {e}")
        return False

def method4_imagemagick(svg_path, png_path):
    """Try using ImageMagick convert"""
    try:
        result = subprocess.run([
            'convert',
            '-background', 'none',
            '-resize', '1024x1024',
            svg_path,
            png_path
        ], capture_output=True, text=True, timeout=30)
        if result.returncode == 0 and os.path.exists(png_path):
            print(f"✅ Converted using ImageMagick: {png_path}")
            return True
        return False
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False
    except Exception as e:
        print(f"❌ ImageMagick error: {e}")
        return False

def method5_manual_install_instructions():
    """Provide instructions for manual installation"""
    print("\n" + "="*60)
    print("⚠️  No conversion tools found automatically.")
    print("="*60)
    print("\nTo convert the SVG to PNG, choose one option:\n")
    print("1. Install cairosvg (recommended, no sudo needed for user install):")
    print("   python3 -m ensurepip --user")
    print("   python3 -m pip install --user cairosvg")
    print("   Then run this script again.\n")
    print("2. Install system tools (requires sudo):")
    print("   sudo apt install inkscape")
    print("   # OR")
    print("   sudo apt install librsvg2-bin")
    print("   # OR")
    print("   sudo apt install imagemagick")
    print("   Then run this script again.\n")
    print("3. Use online converter:")
    print("   - Go to https://cloudconvert.com/svg-to-png")
    print("   - Upload assets/app_icon_simple.svg")
    print("   - Set size to 1024x1024")
    print("   - Download as assets/app_icon.png\n")
    return False

def main():
    svg_file = 'assets/app_icon_simple.svg'
    png_file = 'assets/app_icon.png'
    
    if not os.path.exists(svg_file):
        print(f"❌ SVG file not found: {svg_file}")
        sys.exit(1)
    
    print(f"Converting {svg_file} to {png_file}...")
    print("Trying available conversion methods...\n")
    
    # Try methods in order
    methods = [
        ("cairosvg", method1_cairosvg),
        ("inkscape", method2_inkscape),
        ("rsvg-convert", method3_rsvg_convert),
        ("ImageMagick", method4_imagemagick),
    ]
    
    for name, method in methods:
        print(f"Trying {name}...", end=" ")
        if method(svg_file, png_file):
            # Verify the output
            if os.path.exists(png_file):
                size = os.path.getsize(png_file)
                print(f"\n✅ Success! Created {png_file} ({size:,} bytes)")
                print(f"\nNext step: Run 'flutter pub run flutter_launcher_icons'")
                sys.exit(0)
        else:
            print("not available")
    
    # If all methods failed, show instructions
    method5_manual_install_instructions()
    sys.exit(1)

if __name__ == '__main__':
    main()

