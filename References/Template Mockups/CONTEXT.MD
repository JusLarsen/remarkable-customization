These references were generated with Figma and exported as SVG/PDF.

## Design Guidelines for Future Templates

**Canvas Setup:**
- Portrait: 1404 × 1872 pixels (CONFIRMED - these are the correct dimensions)
- Landscape: 1872 × 1404 pixels (CONFIRMED - these are the correct dimensions)
- Export as both SVG and PDF to sources/ directory

**File Format:**
- Renders are in SVG and PDF format for reference
- Actual templates on reMarkable use `.template` JSON format
- SVG is easier to extract coordinates from for conversion

**Naming Convention:**
- Portrait: `P Template Name.svg` / `P Template Name.pdf`
- Landscape: `LS Template Name.svg` / `LS Template Name.pdf`

**Design Best Practices:**
- Use black (#000000) for all lines and elements (device is grayscale)
- Section dividers: 3px stroke width
- Ruling lines: 1px stroke width
- Keep critical elements at least 20px from edges
- Design for finger/pen input - keep interactive areas spacious

**SVG to Template Conversion Workflow:**
1. Export design from Figma to sources/
2. Open SVG in text editor to extract coordinates
3. Create corresponding .template JSON in templates/
4. Convert SVG paths to template path data format:
   - SVG: `<line x1="0" y1="100" x2="1404" y2="100"/>`
   - Template: `"data": ["M", 0, 100, "L", "templateWidth", 100]`
5. Replace hardcoded dimensions with template variables
6. Add responsive constants for mobile support
7. Validate with `make validate`

**Common Element Conversions:**
- Horizontal divider: `["M", 0, Y, "L", "templateWidth", Y]`
- Vertical divider: `["M", X, 0, "L", X, "templateHeight"]`
- Ruled lines: Use group with repeat for auto-fill
- Text labels: `{"type": "text", "value": "Label", "x": X, "y": Y, "fontSize": 18}`

**Line Spacing Examples:**
- College-ruled: 54-55px spacing
- Wide-ruled: ~80px spacing
- Grid small: 25-30px spacing
- Grid medium: 50-55px spacing

**Template Metadata Template:**
```json
{
  "name": "Template Name",
  "author": "Your Name",
  "templateVersion": "1.0.0",
  "formatVersion": 1,
  "categories": ["Planners"],
  "orientation": "portrait",
  "constants": [
    {"mobileMaxWidth": 1000},
    {"offsetX": "templateWidth > mobileMaxWidth ? 0 : 100"}
  ],
  "items": []
}
```
