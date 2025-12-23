# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is for creating custom templates for the reMarkable tablet. It includes validation tooling, deployment scripts, and a build system via Makefile. Templates are designed in external tools (Figma/Inkscape), converted to JSON format, validated, and deployed to the device via SSH.

## Directory Structure

- `templates/` - Production-ready template files for deployment
  - `*.template` - Template definition files (JSON format)
  - `templates.json` - Manifest of all available templates (merged with device templates)
- `sources/` - Source design files (SVG/PDF exports from design tools)
  - Created in Figma or Inkscape at reMarkable dimensions
  - Serve as visual reference when creating `.template` JSON files
- `scripts/` - Build and deployment automation
  - `validate-templates.py` - Python validation script (requires uv)
  - `deploy.sh` - Bash deployment script using SSH/SCP
  - `README.md` - Script documentation
- `References/Built In/` - Official reMarkable templates extracted from device
  - `templates/` - Built-in template files (`.template` format) and metadata
  - `templates.json` - Template metadata including names, icons, categories, and orientation
- `References/Template Mockups/` - Custom template designs created in Figma
  - Contains SVG and PDF versions for both portrait (P) and landscape (LS) orientations

## reMarkable Template Format

Templates use JSON format with the following structure:
- `name`, `author`, `templateVersion`, `formatVersion` - Metadata
- `categories` - Array of categories (e.g., "Lines", "Creative", "Grids", "Planners")
- `orientation` - "portrait" or "landscape"
- `constants` - Variables for responsive sizing (mobile vs tablet dimensions)
- `items` - Array of visual elements (groups, paths) that define the template layout

Key template concepts:
- Templates are responsive and adapt to different screen sizes using constants
- Paths use SVG-like data format with coordinates
- Groups can have `repeat` properties for creating repeated patterns
- Coordinates can use expressions referencing constants and parent dimensions
- Naming convention: `P` prefix for portrait, `LS` prefix for landscape

## Transferring Files to/from reMarkable

Templates can be transferred using SSH over USB:
```bash
# Pull templates from device
scp -r root@10.11.99.1:/usr/share/remarkable/templates/ .

# Push custom templates to device (example)
scp custom-template.template root@10.11.99.1:/usr/share/remarkable/templates/
```

Default IP when connected via USB: `10.11.99.1`

## Build and Deployment Workflow

The Makefile provides a standardized workflow for template development:

1. **Design** - Create templates in Figma/Inkscape, export to `sources/` as SVG/PDF
2. **Convert** - Manually create `.template` JSON files in `templates/` based on designs
3. **Validate** - Run `make validate` to check JSON syntax, required fields, and coordinate bounds
4. **Build** - Run `make build` to validate templates (templates are already in JSON format)
5. **Deploy** - Run `make deploy` to upload templates to device via SSH and restart xochitl
6. **Clean** - Run `make clean` to remove custom templates from device and restore originals

### Makefile Commands

- `make` or `make help` - Show available commands
- `make validate` - Run validation script on all templates
- `make build` - Validate templates (preparation for deployment)
- `make deploy` - Deploy templates to device (validates first)
- `make clean` - Remove custom templates from device
- `make DEVICE_IP=192.168.1.100 deploy` - Deploy to custom IP address

## Design Process

Custom templates are designed in Figma/Inkscape and exported as SVG/PDF for reference, then manually converted to the `.template` JSON format for deployment to the device.
