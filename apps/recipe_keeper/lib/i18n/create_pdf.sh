#!/bin/bash
# Simple script to create PDF from JSON
# This creates an HTML file that can be printed to PDF from a browser

cd "$(dirname "$0")"

# Create HTML version
python3 << 'EOF'
import json
from pathlib import Path

input_file = Path("en.json")
output_file = Path("en.html")

if not input_file.exists():
    print(f"Error: {input_file} not found")
    exit(1)

# Read and format JSON
with open(input_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

formatted_json = json.dumps(data, indent=2, ensure_ascii=False)

# Create HTML
html_content = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Recipe Keeper - English Translations</title>
    <style>
        @media print {{
            @page {{
                margin: 2cm;
            }}
        }}
        body {{
            font-family: 'Courier New', 'Monaco', 'Menlo', monospace;
            font-size: 9pt;
            margin: 2cm;
            line-height: 1.4;
            color: #000;
        }}
        h1 {{
            color: #1B4332;
            font-size: 18pt;
            margin-bottom: 20pt;
            font-family: Arial, sans-serif;
        }}
        pre {{
            white-space: pre-wrap;
            word-wrap: break-word;
            background: #f9f9f9;
            padding: 15pt;
            border: 1px solid #ddd;
            border-radius: 4px;
        }}
        @media print {{
            body {{
                margin: 1cm;
            }}
            pre {{
                border: none;
                background: white;
            }}
        }}
    </style>
</head>
<body>
    <h1>Recipe Keeper - English Translations</h1>
    <pre>{formatted_json}</pre>
    <script>
        // Auto-print dialog (optional - uncomment if desired)
        // window.onload = function() {{ window.print(); }};
    </script>
</body>
</html>"""

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"HTML file created: {output_file}")
print("\nTo create PDF:")
print("1. Open en.html in your browser")
print("2. Press Ctrl+P (or Cmd+P on Mac)")
print("3. Choose 'Save as PDF' as the destination")
print("4. Click Save")
EOF

