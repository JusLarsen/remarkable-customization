# reMarkable Template Scripts

Scripts for validating and deploying custom templates to your reMarkable tablet.

## Prerequisites

- **Python 3.x** (managed via asdf)
- **uv** for Python package management
- **SSH access** to your reMarkable device (passwordless with SSH keys)
- **Device connection** via USB

## Scripts

### validate-templates.py

Validates template files and templates.json before deployment.

**Usage:**
```bash
./scripts/validate-templates.py
```

**What it checks:**
- JSON syntax for all `.template` files
- Required fields: `name`, `author`, `templateVersion`, `formatVersion`, `categories`, `orientation`
- Orientation matches filename prefix (P=portrait, LS=landscape)
- Coordinate values are within device bounds (1404x1872 portrait, 1872x1404 landscape)
- templates.json structure and syntax
- No `.svg` extensions in filenames
- Consistency between filename prefixes and landscape flags

**Exit codes:**
- `0` - All validations passed (or only warnings)
- `1` - Errors found that must be fixed

### deploy.sh

Deploys templates to your reMarkable device.

**Usage:**
```bash
# Deploy to default IP (10.11.99.1)
./scripts/deploy.sh

# Deploy to specific IP
./scripts/deploy.sh 192.168.1.100
```

**What it does:**
1. Validates templates before deploying
2. Checks device connectivity
3. Copies `.template` files to `/usr/share/remarkable/templates/`
4. Copies `templates.json` to `/usr/share/remarkable/templates/`
5. Restarts the xochitl service (or prompts for manual reboot)

**Requirements:**
- SSH keys configured for passwordless access to root@device
- Device connected and reachable

## Template Structure

### Template Files (.template)

Located in `templates/` directory with naming convention:
- `P <name>.template` - Portrait templates
- `LS <name>.template` - Landscape templates

Required fields:
```json
{
  "name": "Template Name",
  "author": "Author Name",
  "templateVersion": "1.0.0",
  "formatVersion": 1,
  "categories": ["Planners"],
  "orientation": "portrait",
  "items": [...]
}
```

### templates.json

Registry file that tells reMarkable about available templates:

```json
{
  "templates": [
    {
      "name": "Template Name",
      "filename": "P Template Name",
      "iconCode": "\ue9aa",
      "categories": ["Planners"]
    },
    {
      "name": "Template Name (Landscape)",
      "filename": "LS Template Name",
      "iconCode": "\ue9aa",
      "landscape": true,
      "categories": ["Planners"]
    }
  ]
}
```

**Important:**
- `filename` should NOT include `.template` extension
- `filename` should NOT include `.svg` extension
- Use `landscape: true` for landscape templates
- Match filename prefix (P/LS) with orientation

## Device Dimensions

- Portrait: 1404px wide × 1872px tall
- Landscape: 1872px wide × 1404px tall

## Examples

### Creating a new template

1. Create your template file:
   ```bash
   templates/P My Template.template
   ```

2. Add entry to templates.json:
   ```json
   {
     "name": "My Template",
     "filename": "P My Template",
     "iconCode": "\ue9aa",
     "categories": ["Planners"]
   }
   ```

3. Validate:
   ```bash
   ./scripts/validate-templates.py
   ```

4. Deploy:
   ```bash
   ./scripts/deploy.sh
   ```

## Troubleshooting

### "Cannot connect to device"
- Check USB connection
- Verify device IP (Settings → Help → Copyright and Licenses → General information)
- Ensure SSH keys are configured

### "Validation failed"
- Fix all ERROR messages before deploying
- WARNING messages are informational and won't block deployment

### Templates don't appear
- Manually reboot device: Settings → Power → Restart
- Or SSH and run: `systemctl restart xochitl`

## Icon Codes

Common icon codes for templates:
- `\ue9aa` - Planner/calendar icon
- `\ue9ab` - Checklist icon
- `\ue9ac` - Day planner icon
- `\ue9fe` - Blank portrait icon
- `\ue9fd` - Blank landscape icon

See existing templates.json for more icon options.
