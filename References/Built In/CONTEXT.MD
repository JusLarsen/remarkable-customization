The templates/ directory was pulled from a remarkable using the command:

```bash
scp -r root@10.11.99.1:/usr/share/remarkable/templates/ .
```

## Template Format Quick Reference

**Device Dimensions:**
- Portrait: 1404px (width) × 1872px (height)
- Landscape: 1872px (width) × 1404px (height)

**Critical Rules:**
- Horizontal lines: use `templateWidth` for X-endpoints
- Vertical lines: use `templateHeight` for Y-endpoints
- Stroke widths: 1px for ruling lines, 3px for section dividers
- Use double quotes only, no trailing commas
- Filename prefix: `P` = portrait, `LS` = landscape

**Common Patterns:**
- Repeating lines: Use groups with `"repeat": {"rows": "down"}` for auto-fill
- Responsive design: Add constants with `mobileMaxWidth: 1000` threshold
- Centering: `"x": "templateWidth / 2 - contentWidth / 2"`

**Templates.json Entry:**
- `filename` should NOT include extension (.template, .svg, etc)
- Set `landscape: true` for LS templates
- Choose appropriate `iconCode` from templates.json examples
- Use `categories`: ["Planners"], ["Lines"], ["Grids"], or ["Creative"]

**Reference Templates:**
- Simple ruling: See `P Lines small.template`
- Complex layout: See `P Day.template` or `P Checklist.template`
- Music notation: See `Notes.template` (Music)

**Common Mistakes (from code review):**
- Using `templateHeight` for horizontal line endpoints (wrong!)
- Using hardcoded coordinates beyond device bounds
- Including file extensions in templates.json
- Mixing up width/height in different orientations