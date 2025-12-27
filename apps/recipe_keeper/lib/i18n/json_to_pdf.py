#!/usr/bin/env python3
"""Convert JSON file to PDF"""
import json
import sys
from pathlib import Path

try:
    from reportlab.pdfgen import canvas
    from reportlab.lib.pagesizes import letter, A4
    from reportlab.lib.units import inch
    from reportlab.lib import colors
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
    from reportlab.lib.enums import TA_LEFT
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.ttfonts import TTFont
    HAS_REPORTLAB = True
except ImportError:
    HAS_REPORTLAB = False

def format_json_to_text(data, indent=0):
    """Recursively format JSON data to readable text"""
    lines = []
    indent_str = "  " * indent
    
    if isinstance(data, dict):
        for key, value in data.items():
            key_str = f"{indent_str}{key}:"
            if isinstance(value, (dict, list)):
                lines.append(key_str)
                lines.extend(format_json_to_text(value, indent + 1))
            else:
                lines.append(f"{key_str} {value}")
    elif isinstance(data, list):
        for i, item in enumerate(data):
            if isinstance(item, (dict, list)):
                lines.append(f"{indent_str}[{i}]")
                lines.extend(format_json_to_text(item, indent + 1))
            else:
                lines.append(f"{indent_str}[{i}] {item}")
    else:
        lines.append(f"{indent_str}{data}")
    
    return lines

def create_pdf_reportlab(input_file, output_file):
    """Create PDF using reportlab library"""
    # Read JSON file
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Format to text
    text_lines = format_json_to_text(data)
    
    # Create PDF
    doc = SimpleDocTemplate(
        str(output_file),
        pagesize=letter,
        rightMargin=72,
        leftMargin=72,
        topMargin=72,
        bottomMargin=18
    )
    
    # Styles
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=16,
        textColor=colors.HexColor('#1B4332'),
        spaceAfter=30,
    )
    normal_style = ParagraphStyle(
        'CustomNormal',
        parent=styles['Normal'],
        fontSize=9,
        leading=11,
        fontName='Courier',
        textColor=colors.HexColor('#000000'),
        leftIndent=0,
        rightIndent=0,
    )
    
    # Build content
    story = []
    story.append(Paragraph("Recipe Keeper - English Translations", title_style))
    story.append(Spacer(1, 0.2*inch))
    
    for line in text_lines:
        # Escape HTML special characters
        escaped_line = line.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;')
        story.append(Paragraph(escaped_line, normal_style))
    
    # Build PDF
    doc.build(story)
    print(f"PDF created successfully: {output_file}")

def main():
    input_file = Path(__file__).parent / "en.json"
    output_file = Path(__file__).parent / "en.pdf"
    
    if not input_file.exists():
        print(f"Error: {input_file} not found")
        sys.exit(1)
    
    if HAS_REPORTLAB:
        try:
            create_pdf_reportlab(input_file, output_file)
        except Exception as e:
            print(f"Error creating PDF: {e}")
            import traceback
            traceback.print_exc()
            sys.exit(1)
    else:
        print("Error: reportlab library not found")
        print("Please install it with: pip3 install reportlab")
        sys.exit(1)

if __name__ == "__main__":
    main()



