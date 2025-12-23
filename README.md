# reMarkable Template Customization

[![Lint Templates](https://github.com/JusLarsen/remarkable-customization/actions/workflows/lint.yml/badge.svg)](https://github.com/JusLarsen/remarkable-customization/actions/workflows/lint.yml)

Custom templates for reMarkable tablets, including Daily Tracker layouts in both portrait and landscape orientations.

## Templates

| Template | Preview | Full Resolution |
|----------|---------|-----------------|
| **Daily Tracker (Portrait)** | <a href="sources/P Daily Tracker.pdf"><img src="sources/previews/P Daily Tracker.png" width="200" alt="Portrait Daily Tracker Preview"></a> | [PDF](sources/P%20Daily%20Tracker.pdf) • [SVG](sources/P%20Daily%20Tracker.svg) |
| **Daily Tracker (Landscape)** | <a href="sources/LS Daily Tracker.pdf"><img src="sources/previews/LS Daily Tracker.png" width="300" alt="Landscape Daily Tracker Preview"></a> | [PDF](sources/LS%20Daily%20Tracker.pdf) • [SVG](sources/LS%20Daily%20Tracker.svg) |

**Features:**
- **Highlights/Habits** - Top sections for daily priorities and habit tracking
- **Notes/Tasks** - Organized spaces for free-form notes and task lists with checkboxes
- **Date Field** - Positioned in top right corner
- **Ruled Lines** - College-ruled section at bottom for additional notes

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── lint.yml    # GitHub Actions CI workflow
├── Makefile            # Build system for validation and deployment
├── LICENSE             # MIT License
├── templates/          # Built template files (.template JSON format)
│   ├── P Daily Tracker.template
│   ├── LS Daily Tracker.template
│   └── templates.json
├── sources/            # Source design files (SVG/PDF)
│   ├── previews/       # Preview images for README
│   ├── P Daily Tracker.svg
│   ├── P Daily Tracker.pdf
│   ├── LS Daily Tracker.svg
│   └── LS Daily Tracker.pdf
└── scripts/            # Validation and deployment tooling
    ├── validate-templates.py
    └── deploy.sh
```

## Quick Start

### Prerequisites

- reMarkable tablet connected via USB
- SSH access configured (passwordless auth recommended)
- Python 3.x with `uv` (for validation)
- Bash shell (for deployment script)

### Deploy Templates to Device

Using the Makefile (recommended):

```bash
# Validate templates first
make validate

# Deploy to device (default IP: 10.11.99.1)
make deploy

# Or specify custom IP
make deploy DEVICE_IP=192.168.1.100

# See all available commands
make help
```

Or use scripts directly:

```bash
# Validate templates
./scripts/validate-templates.py

# Deploy to device
./scripts/deploy.sh

# Deploy to custom IP
./scripts/deploy.sh 192.168.1.100
```

After deployment, restart your reMarkable or wait for the xochitl service to restart.

## Makefile Commands

The project includes a Makefile for streamlined workflow:

| Command | Description |
|---------|-------------|
| `make` or `make help` | Show all available commands |
| `make validate` | Validate all template files |
| `make lint` | Run linting checks (alias for validate) |
| `make pre-push` | Run all checks before pushing to GitHub |
| `make build` | Validate templates (preparation for deployment) |
| `make deploy` | Deploy templates to device (validates first) |
| `make upload` | Alias for deploy |
| `make clean` | Remove custom templates from device |
| `make backup` | Backup device templates.json |
| `make status` | Check device connection and template counts |

**Configuration:**
- `DEVICE_IP` - Device IP address (default: 10.11.99.1)
- `DEVICE_USER` - SSH user (default: root)

**Examples:**
```bash
# Validate templates before committing
make lint

# Check if working directory is clean
make git-status

# Run pre-push checks
make pre-push

# Deploy to default device
make deploy

# Deploy to custom IP
make deploy DEVICE_IP=192.168.1.100

# Check status and connection
make status

# Clean up custom templates
make clean
```

### Pre-Push Workflow

Before pushing to GitHub, the `pre-push` target runs all quality checks:

```bash
make pre-push
```

This will:
1. Validate all template files (JSON syntax, structure, coordinates)
2. Check for uncommitted changes in the working directory
3. Confirm you're ready to push

If any check fails, the command exits with an error and you should fix the issues before pushing.

## Custom Templates

### Daily Tracker (Portrait)

**Sections:**
- **Highlight** (top left) - Space for daily highlights or priorities
- **Habits** (top right) - Habit tracking checkboxes
- **Date** - Date field in top right corner
- **Notes** (bottom left) - Free-form note-taking area
- **Tasks** (bottom right) - Task list with checkboxes
- **Ruled section** (bottom) - College-ruled lines for additional notes

**Dimensions:** 1404 × 1872 pixels

### Daily Tracker (Landscape)

**Sections:**
- **Left column:** Highlight (top) + Notes with college-ruled lines (bottom)
- **Middle column:** Habits (top) + Tasks (bottom)
- **Right column:** Open space with Date field

**Dimensions:** 1872 × 1404 pixels

## Development

### Creating New Templates

1. **Design in Figma/Inkscape** at reMarkable dimensions:
   - Portrait: 1404 × 1872 pixels
   - Landscape: 1872 × 1404 pixels

2. **Export to SVG/PDF** and save in `sources/`

3. **Convert to .template format:**
   - Follow the JSON structure in `References/Built In/templates/`
   - Use `templateWidth` and `templateHeight` for responsive sizing
   - Add responsive constants for mobile support
   - See template format documentation below

4. **Validate:**
   ```bash
   make validate
   ```

5. **Update templates.json:**
   - Add entry for your template
   - Use proper iconCode (see references)
   - Set landscape flag for landscape templates
   - Filename should NOT include extension

6. **Deploy and test on device:**
   ```bash
   make deploy
   ```

### Template Format Reference

Templates use JSON format with the following structure:

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
  "items": [
    {
      "type": "path",
      "strokeWidth": 1,
      "data": ["M", 0, 0, "L", "templateWidth", 0]
    }
  ]
}
```

**Key Principles:**
- Horizontal lines use `templateWidth` for X-endpoints
- Vertical lines use `templateHeight` for Y-endpoints
- Use constants for responsive sizing
- Stroke width: 1px for ruling, 3px for section dividers
- No trailing commas in JSON
- Double quotes only, no single quotes

## Getting Your reMarkable Password

Each reMarkable device has a unique SSH password that you'll need for the initial connection. To find your device's password:

1. On your reMarkable tablet, swipe down from the top of the screen
2. Tap the **Settings** icon (gear)
3. Navigate to **Help**
4. Tap **Copyrights and licenses**
5. Tap **General information**
6. Scroll down to see the randomly generated password

**Note:** The password is unique to your device and randomly generated at the factory. For convenience, it's recommended to set up SSH keys for passwordless authentication (see SSH Setup below).

## SSH Setup

The deployment script uses SSH for file transfer. For passwordless authentication:

```bash
# Copy your SSH key to the device (you'll need the password from above)
ssh-copy-id root@10.11.99.1

# Test connection (should work without password now)
ssh root@10.11.99.1 "echo 'Connected!'"
```

Default reMarkable IP over USB: `10.11.99.1`

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

## Validation Checks

The validation script checks for:
- Valid JSON syntax
- Required metadata fields
- Orientation matches filename prefix (P=portrait, LS=landscape)
- Coordinates within device bounds
- Proper templates.json structure
- No .svg or .pdf extensions in filenames

## Device Specifications

- **Portrait:** 1404 × 1872 pixels
- **Landscape:** 1872 × 1404 pixels
- **Format:** .template files (JSON)
- **Location on device:** `/usr/share/remarkable/templates/`

## Resources

- [reMarkable Template Format Documentation](https://remarkable.guide/guide/software/templates.html)
- [reMarkable Wiki](https://remarkablewiki.com/)
- [reMarkable Community Forums](https://remarkable.com/community)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
