#!/usr/bin/env -S uv run python
"""
Validation script for reMarkable templates.

This script validates:
1. JSON syntax for all .template files
2. Required fields in template files
3. Orientation matches filename prefix (P=portrait, LS=landscape)
4. Coordinate reasonableness based on device dimensions
5. templates.json structure and syntax
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Any

# reMarkable device dimensions
PORTRAIT_WIDTH = 1404
PORTRAIT_HEIGHT = 1872
LANDSCAPE_WIDTH = 1872
LANDSCAPE_HEIGHT = 1404

# Required fields for template files
REQUIRED_TEMPLATE_FIELDS = [
    "name",
    "author",
    "templateVersion",
    "formatVersion",
    "categories",
    "orientation"
]

# Required fields for templates.json entries
REQUIRED_JSON_FIELDS = [
    "name",
    "filename",
    "iconCode",
    "categories"
]


class ValidationError:
    """Represents a validation error."""

    def __init__(self, severity: str, file: str, message: str):
        self.severity = severity  # "ERROR" or "WARNING"
        self.file = file
        self.message = message

    def __str__(self):
        return f"[{self.severity}] {self.file}: {self.message}"


def validate_json_syntax(file_path: Path) -> Tuple[bool, Any, str]:
    """
    Validate JSON syntax of a file.

    Returns:
        (is_valid, parsed_data, error_message)
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return True, data, ""
    except json.JSONDecodeError as e:
        return False, None, f"JSON syntax error: {e}"
    except Exception as e:
        return False, None, f"Error reading file: {e}"


def validate_template_file(file_path: Path) -> List[ValidationError]:
    """Validate a single .template file."""
    errors = []

    # Validate JSON syntax
    is_valid, data, error_msg = validate_json_syntax(file_path)
    if not is_valid:
        errors.append(ValidationError("ERROR", str(file_path), error_msg))
        return errors

    # Check required fields
    for field in REQUIRED_TEMPLATE_FIELDS:
        if field not in data:
            errors.append(ValidationError(
                "ERROR",
                str(file_path),
                f"Missing required field: {field}"
            ))

    # Validate orientation matches filename
    filename = file_path.stem  # filename without extension
    orientation = data.get("orientation", "")

    if filename.startswith("P "):
        expected_orientation = "portrait"
    elif filename.startswith("LS "):
        expected_orientation = "landscape"
    else:
        errors.append(ValidationError(
            "WARNING",
            str(file_path),
            f"Filename '{filename}' doesn't follow P/LS prefix convention"
        ))
        expected_orientation = None

    if expected_orientation and orientation != expected_orientation:
        errors.append(ValidationError(
            "ERROR",
            str(file_path),
            f"Orientation '{orientation}' doesn't match filename prefix "
            f"(expected '{expected_orientation}')"
        ))

    # Validate coordinates in items
    max_width = PORTRAIT_WIDTH if orientation == "portrait" else LANDSCAPE_WIDTH
    max_height = PORTRAIT_HEIGHT if orientation == "portrait" else LANDSCAPE_HEIGHT

    if "items" in data:
        coord_errors = validate_coordinates(
            data["items"],
            max_width,
            max_height,
            file_path
        )
        errors.extend(coord_errors)

    return errors


def validate_coordinates(
    items: List[Dict],
    max_width: int,
    max_height: int,
    file_path: Path,
    path: str = ""
) -> List[ValidationError]:
    """
    Recursively validate coordinates in template items.

    Checks that numeric coordinates are within device bounds.
    """
    errors = []

    for i, item in enumerate(items):
        item_id = item.get("id", f"item[{i}]")
        current_path = f"{path}/{item_id}" if path else item_id

        # Check position coordinates
        if "position" in item:
            pos = item["position"]
            if "x" in pos and isinstance(pos["x"], (int, float)):
                if pos["x"] < 0 or pos["x"] > max_width:
                    errors.append(ValidationError(
                        "WARNING",
                        str(file_path),
                        f"{current_path}: x-coordinate {pos['x']} outside "
                        f"reasonable bounds (0-{max_width})"
                    ))
            if "y" in pos and isinstance(pos["y"], (int, float)):
                if pos["y"] < 0 or pos["y"] > max_height:
                    errors.append(ValidationError(
                        "WARNING",
                        str(file_path),
                        f"{current_path}: y-coordinate {pos['y']} outside "
                        f"reasonable bounds (0-{max_height})"
                    ))

        # Check path data coordinates
        if "data" in item and isinstance(item["data"], list):
            for j, val in enumerate(item["data"]):
                if isinstance(val, (int, float)):
                    # Heuristic: even indices are typically x, odd are y
                    # This is not perfect but catches obvious issues
                    if j % 4 == 1:  # x coordinates after M or L
                        if val > max_width * 2:  # Allow some overflow
                            errors.append(ValidationError(
                                "WARNING",
                                str(file_path),
                                f"{current_path}: path coordinate {val} seems "
                                f"unusually large for x-axis (max: {max_width})"
                            ))
                    elif j % 4 == 2:  # y coordinates
                        if val > max_height * 2:
                            errors.append(ValidationError(
                                "WARNING",
                                str(file_path),
                                f"{current_path}: path coordinate {val} seems "
                                f"unusually large for y-axis (max: {max_height})"
                            ))

        # Recursively check children
        if "children" in item and isinstance(item["children"], list):
            child_errors = validate_coordinates(
                item["children"],
                max_width,
                max_height,
                file_path,
                current_path
            )
            errors.extend(child_errors)

    return errors


def validate_templates_json(file_path: Path, custom_only: bool = True) -> List[ValidationError]:
    """Validate templates.json file.

    Args:
        file_path: Path to templates.json
        custom_only: If True, only report warnings for custom templates (default: True)
    """
    errors = []

    # Validate JSON syntax
    is_valid, data, error_msg = validate_json_syntax(file_path)
    if not is_valid:
        errors.append(ValidationError("ERROR", str(file_path), error_msg))
        return errors

    # Check root structure
    if "templates" not in data:
        errors.append(ValidationError(
            "ERROR",
            str(file_path),
            "Missing 'templates' root array"
        ))
        return errors

    if not isinstance(data["templates"], list):
        errors.append(ValidationError(
            "ERROR",
            str(file_path),
            "'templates' must be an array"
        ))
        return errors

    # Custom template prefixes to validate
    custom_prefixes = ["P Daily Tracker", "LS Daily Tracker"]

    # Validate each template entry
    filenames_seen = {}
    for i, template in enumerate(data["templates"]):
        filename = template.get("filename", "")

        # Check if this is a custom template
        is_custom = any(filename.startswith(prefix) for prefix in custom_prefixes)

        # Skip warnings for non-custom templates if custom_only is True
        skip_warnings = custom_only and not is_custom

        # Check required fields (always check for errors)
        for field in REQUIRED_JSON_FIELDS:
            if field not in template:
                errors.append(ValidationError(
                    "ERROR",
                    str(file_path),
                    f"Entry {i}: Missing required field '{field}'"
                ))

        # Check filename doesn't have .svg extension (always check)
        if filename.endswith(".svg"):
            errors.append(ValidationError(
                "ERROR",
                str(file_path),
                f"Entry {i}: Filename '{filename}' should not have .svg extension"
            ))

        # Check for duplicate filenames (only warn for custom templates if custom_only)
        if filename in filenames_seen:
            if not skip_warnings:
                errors.append(ValidationError(
                    "WARNING",
                    str(file_path),
                    f"Entry {i}: Duplicate filename '{filename}' "
                    f"(also at entry {filenames_seen[filename]})"
                ))
        else:
            filenames_seen[filename] = i

        # Validate landscape flag matches LS prefix (only warn for custom if custom_only)
        if not skip_warnings:
            is_landscape = template.get("landscape", False)
            if filename.startswith("LS ") and not is_landscape:
                errors.append(ValidationError(
                    "WARNING",
                    str(file_path),
                    f"Entry {i}: Filename '{filename}' has LS prefix but "
                    f"landscape flag is not true"
                ))
            elif filename.startswith("P ") and is_landscape:
                errors.append(ValidationError(
                    "WARNING",
                    str(file_path),
                    f"Entry {i}: Filename '{filename}' has P prefix but "
                    f"landscape flag is true"
                ))

    return errors


def main():
    """Main validation function."""
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    templates_dir = project_root / "templates"

    print("=" * 70)
    print("reMarkable Template Validation")
    print("=" * 70)
    print()

    all_errors = []

    # Validate all .template files
    template_files = list(templates_dir.glob("*.template"))
    if not template_files:
        print("WARNING: No .template files found in templates/ directory")
        print()
    else:
        print(f"Validating {len(template_files)} template file(s)...")
        for template_file in sorted(template_files):
            errors = validate_template_file(template_file)
            all_errors.extend(errors)
        print()

    # Validate templates.json
    templates_json = templates_dir / "templates.json"
    if templates_json.exists():
        print("Validating templates.json (custom templates only)...")
        errors = validate_templates_json(templates_json, custom_only=True)
        all_errors.extend(errors)
        print()
    else:
        all_errors.append(ValidationError(
            "ERROR",
            str(templates_json),
            "templates.json file not found"
        ))

    # Report results
    if not all_errors:
        print("SUCCESS: All validations passed!")
        print()
        return 0

    # Separate errors and warnings
    errors = [e for e in all_errors if e.severity == "ERROR"]
    warnings = [e for e in all_errors if e.severity == "WARNING"]

    if warnings:
        print(f"Found {len(warnings)} warning(s):")
        print("-" * 70)
        for warning in warnings:
            print(f"  {warning}")
        print()

    if errors:
        print(f"Found {len(errors)} error(s):")
        print("-" * 70)
        for error in errors:
            print(f"  {error}")
        print()
        print("FAILED: Please fix errors before deploying.")
        return 1

    print("PASSED: No errors found (warnings are non-blocking).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
