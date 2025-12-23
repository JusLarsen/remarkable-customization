# Development Guide

This guide covers creating custom templates, understanding the template format, and contributing to the project.

## Template Specifications

### Device Dimensions
- **Portrait:** 1404 × 1872 pixels
- **Landscape:** 1872 × 1404 pixels
- **Format:** .template files (JSON)
- **Location on device:** `/usr/share/remarkable/templates/`

### Creating New Templates

1. **Design in Figma/Inkscape** at reMarkable dimensions:
   - Portrait: 1404 × 1872 pixels
   - Landscape: 1872 × 1404 pixels

2. **Export to SVG/PDF** and save in `sources/`

3. **Convert to .template format:**
   - Follow the JSON structure below
   - Use `templateWidth` and `templateHeight` for responsive sizing
   - See template format documentation below

4. **Validate:**
   ```bash
   make validate
   ```

5. **Update templates.json:**
   - Add entry for your template
   - Use proper iconCode (browse built-in templates for examples)
   - Set landscape flag for landscape templates
   - Filename should NOT include extension

6. **Deploy and test on device:**
   ```bash
   make deploy
   ```

## Template Format Reference

Templates use JSON format with the following structure:

```json
{
  "name": "Template Name",
  "author": "Your Name",
  "templateVersion": "1.0.0",
  "formatVersion": 1,
  "categories": ["Planners"],
  "orientation": "portrait",
  "items": [
    {
      "id": "line-1",
      "type": "path",
      "strokeWidth": 1,
      "data": ["M", 0, 100, "L", "templateWidth", 100]
    },
    {
      "id": "label-1",
      "type": "text",
      "text": "Notes",
      "fontSize": 18,
      "position": {
        "x": 50,
        "y": 80
      }
    }
  ]
}
```

### Key Principles

- **Responsive sizing:** Use `templateWidth` for horizontal coordinates, `templateHeight` for vertical
- **Stroke widths:** 1px for ruling lines, 3px for section dividers
- **JSON syntax:** No trailing commas, double quotes only
- **Path data:** Follows SVG path syntax (M = moveto, L = lineto)
- **Text positioning:** `position.y` is the baseline of the text

### Icon Codes

Icons use Unicode private use area characters. Common examples:
- `\ue991` - Portrait planner
- `\ue9ac` - Landscape planner
- `\ue9aa` - Checklist

Browse `templates/templates.json` for more iconCode examples from built-in templates.

## Validation

The validation script (`scripts/validate-templates.py`) checks:
- Valid JSON syntax
- Required metadata fields
- Orientation matches filename prefix (P=portrait, LS=landscape)
- Coordinates within device bounds
- Proper templates.json structure
- No .svg or .pdf extensions in filenames

Run validation:
```bash
make validate
# or
./scripts/validate-templates.py
```

## Troubleshooting

### Templates not appearing in picker

- Verify templates.json syntax is valid (no trailing commas)
- Check that filename in templates.json matches actual .template file
- Ensure filename does NOT include extension
- Restart device or xochitl service

### Templates rendering incorrectly

- Validate coordinates are within device bounds
- Check dimension variables (templateWidth/Height) are used correctly
- Verify stroke widths are appropriate (1-3px)
- Run validation script to catch common errors

### Lines missing or cut off

- Horizontal lines must use `templateWidth` for X-coordinates
- Vertical lines must use `templateHeight` for Y-coordinates
- Check that hardcoded values don't exceed device dimensions

## Git Workflow

### Before Committing

```bash
# Validate templates
make lint

# Check git status
make git-status

# Run pre-push checks
make pre-push
```

### Creating Pull Requests

1. Create a feature branch: `git checkout -b feature/my-template`
2. Make your changes
3. Validate: `make lint`
4. Commit with signed commits
5. Push and create PR

## Project Structure

```
.
├── .github/workflows/     # CI/CD workflows
├── Makefile              # Build and deployment automation
├── templates/            # Built template files
│   ├── *.template       # Template JSON files
│   └── templates.json   # Template registry
├── sources/              # Source design files
│   ├── previews/        # Preview images for README
│   ├── splash-screens/  # Custom suspend screen assets
│   ├── *.svg           # Template source files (vector)
│   └── *.pdf           # Template source files (PDF)
└── scripts/              # Validation and deployment scripts
```

## Contributing

Contributions are welcome! Please:

1. Follow the existing code style
2. Validate templates before committing (`make lint`)
3. Add preview images for new templates
4. Update README with template descriptions
5. Test on actual device before submitting PR

## Resources

- [reMarkable Template Format Documentation](https://remarkable.guide/guide/software/templates.html)
- [reMarkable Wiki](https://remarkablewiki.com/)
- [SVG Path Syntax Reference](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths)
- [E-Ink Graphics Preparation](https://learn.adafruit.com/preparing-graphics-for-e-ink-displays)
