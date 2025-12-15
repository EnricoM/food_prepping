# Quick Icon Conversion

To convert the SVG to PNG, run this single command:

```bash
sudo apt install -y librsvg2-bin && rsvg-convert -w 1024 -h 1024 -o assets/app_icon.png assets/app_icon_simple.svg
```

This will:
1. Install the rsvg-convert tool
2. Convert the SVG to PNG at 1024x1024 pixels
3. Save it as `assets/app_icon.png`

After conversion, run:
```bash
flutter pub run flutter_launcher_icons
```

