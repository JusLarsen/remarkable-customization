# reMarkable Template Customization

[![Lint Templates](https://github.com/JusLarsen/remarkable-customization/actions/workflows/lint.yml/badge.svg)](https://github.com/JusLarsen/remarkable-customization/actions/workflows/lint.yml)

Custom templates and splash screens for reMarkable tablets.

## Templates

| Template | Preview | Download |
|----------|---------|----------|
| **Daily Tracker (Portrait)** | <a href="sources/P Daily Tracker.pdf"><img src="sources/previews/P Daily Tracker.png" width="200" alt="Portrait Daily Tracker Preview"></a> | [PDF](sources/P%20Daily%20Tracker.pdf) • [SVG](sources/P%20Daily%20Tracker.svg) |
| **Daily Tracker (Landscape)** | <a href="sources/LS Daily Tracker.pdf"><img src="sources/previews/LS Daily Tracker.png" width="300" alt="Landscape Daily Tracker Preview"></a> | [PDF](sources/LS%20Daily%20Tracker.pdf) • [SVG](sources/LS%20Daily%20Tracker.svg) |

**Features:** Daily priorities, habit tracking, task lists, notes sections, and college-ruled lines.

## Quick Start

### Prerequisites

- reMarkable tablet connected via USB
- SSH access ([find your password](https://remarkable.guide/guide/access/ssh.html): Settings → Help → Copyrights → General information)
- Python 3.x with `uv` (install: `curl -LsSf https://astral.sh/uv/install.sh | sh`)

### SSH Setup (First Time)

```bash
# Copy your SSH key to device (you'll need the password above)
ssh-copy-id root@10.11.99.1

# Test connection
ssh root@10.11.99.1 "echo 'Connected!'"
```

### Deploy to Device

```bash
# Deploy templates
make deploy

# Deploy custom suspend screen
make deploy-splash

# Deploy both
make deploy-all
```

## Custom Splash Screen

Customize the sleep/lock screen that appears when your device suspends.

**Quick Setup:**
1. Create a 1404 × 1872 pixel image in Figma (portrait, grayscale, 72 DPI)
2. Center your logo with 150-200px margins
3. Export as PNG to `sources/splash-screens/suspended.png`
4. Deploy: `make deploy-splash`

See [sources/splash-screens/README.md](sources/splash-screens/README.md) for detailed design guidelines.

## Available Commands

| Command | Description |
|---------|-------------|
| `make deploy` | Deploy templates to device |
| `make deploy-splash` | Deploy custom suspend screen |
| `make deploy-all` | Deploy both templates and splash screen |
| `make validate` | Validate template files |
| `make status` | Check device connection |
| `make clean` | Remove custom templates from device |
| `make help` | Show all available commands |

**Configuration:**
- `DEVICE_IP` - Device IP (default: 10.11.99.1)
- `DEVICE_USER` - SSH user (default: root)

Example: `make deploy DEVICE_IP=192.168.1.100`

## Development

Want to create your own templates or contribute? See [DEVELOPMENT.md](DEVELOPMENT.md) for:
- Template format specifications
- Creating new templates
- Validation and testing
- Contributing guidelines

## Resources

- [reMarkable Template Format Documentation](https://remarkable.guide/guide/software/templates.html)
- [reMarkable Wiki](https://remarkablewiki.com/)
- [Splash Screen Customization](https://remarkable.guide/guide/software/screens.html)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
