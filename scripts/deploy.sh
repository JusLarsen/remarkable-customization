#!/usr/bin/env bash

#
# Deployment script for reMarkable templates
#
# This script:
# 1. Validates templates before deploying
# 2. Copies .template files to the device
# 3. Copies templates.json to the device
# 4. Restarts the xochitl service or prompts for reboot
#
# Usage:
#   ./scripts/deploy.sh [device_ip]
#
# Examples:
#   ./scripts/deploy.sh              # Uses default IP: 10.11.99.1
#   ./scripts/deploy.sh 10.11.99.1   # Specify device IP
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default device IP
DEFAULT_DEVICE_IP="10.11.99.1"
DEVICE_IP="${1:-$DEFAULT_DEVICE_IP}"
DEVICE_USER="root"
DEVICE_PATH="/usr/share/remarkable/templates"

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$PROJECT_ROOT/templates"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate-templates.py"

# Print helper functions
print_header() {
    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

# Check if validation script exists
check_validation_script() {
    if [[ ! -f "$VALIDATE_SCRIPT" ]]; then
        print_error "Validation script not found: $VALIDATE_SCRIPT"
        exit 1
    fi

    if [[ ! -x "$VALIDATE_SCRIPT" ]]; then
        print_info "Making validation script executable..."
        chmod +x "$VALIDATE_SCRIPT"
    fi
}

# Validate templates before deployment
validate_templates() {
    print_header "Validating Templates"

    if uv run python "$VALIDATE_SCRIPT"; then
        print_success "Template validation passed"
        echo ""
        return 0
    else
        print_error "Template validation failed"
        echo ""
        print_warning "Deployment aborted. Please fix validation errors before deploying."
        exit 1
    fi
}

# Check if device is reachable
check_device() {
    print_header "Checking Device Connection"
    print_info "Attempting to connect to $DEVICE_USER@$DEVICE_IP..."

    if ssh -o ConnectTimeout=5 -o BatchMode=yes "$DEVICE_USER@$DEVICE_IP" "echo 'Connection successful'" &>/dev/null; then
        print_success "Device is reachable at $DEVICE_IP"
        echo ""
        return 0
    else
        print_error "Cannot connect to device at $DEVICE_IP"
        echo ""
        print_warning "Please check:"
        print_warning "  1. Device is connected via USB"
        print_warning "  2. Device IP is correct (default: $DEFAULT_DEVICE_IP)"
        print_warning "  3. SSH keys are configured for passwordless access"
        echo ""
        exit 1
    fi
}

# Count template files
count_templates() {
    find "$TEMPLATES_DIR" -name "*.template" -type f | wc -l | tr -d ' '
}

# Deploy template files
deploy_templates() {
    print_header "Deploying Template Files"

    local template_count
    template_count=$(count_templates)

    if [[ "$template_count" -eq 0 ]]; then
        print_warning "No .template files found in $TEMPLATES_DIR"
        return 1
    fi

    print_info "Copying $template_count template file(s) to device..."

    # Copy each .template file
    while IFS= read -r template_file; do
        local filename
        filename=$(basename "$template_file")
        print_info "  Copying $filename..."

        if scp -q "$template_file" "$DEVICE_USER@$DEVICE_IP:$DEVICE_PATH/"; then
            print_success "    ✓ $filename copied"
        else
            print_error "    ✗ Failed to copy $filename"
            return 1
        fi
    done < <(find "$TEMPLATES_DIR" -name "*.template" -type f)

    echo ""
    print_success "All template files deployed"
    echo ""
}

# Deploy templates.json
deploy_json() {
    print_header "Deploying templates.json"

    local templates_json="$TEMPLATES_DIR/templates.json"

    if [[ ! -f "$templates_json" ]]; then
        print_error "templates.json not found at $templates_json"
        return 1
    fi

    print_info "Copying templates.json to device..."

    if scp -q "$templates_json" "$DEVICE_USER@$DEVICE_IP:$DEVICE_PATH/templates.json"; then
        print_success "templates.json deployed"
        echo ""
        return 0
    else
        print_error "Failed to copy templates.json"
        return 1
    fi
}

# Restart xochitl service
restart_service() {
    print_header "Restarting reMarkable Interface"

    print_info "Restarting xochitl service..."

    if ssh "$DEVICE_USER@$DEVICE_IP" "systemctl restart xochitl" 2>/dev/null; then
        print_success "xochitl service restarted successfully"
        echo ""
        print_success "Deployment complete!"
        print_info "Your new templates should now be available on the device."
    else
        print_warning "Could not restart xochitl service automatically"
        echo ""
        print_info "Please restart your reMarkable device manually:"
        print_info "  1. Swipe down from the top of the screen"
        print_info "  2. Tap the power icon"
        print_info "  3. Tap 'Restart'"
        echo ""
        print_info "Or run this command on the device:"
        print_info "  systemctl restart xochitl"
    fi
    echo ""
}

# Main deployment function
main() {
    print_header "reMarkable Template Deployment"
    echo ""
    print_info "Device: $DEVICE_USER@$DEVICE_IP"
    print_info "Destination: $DEVICE_PATH"
    echo ""

    # Step 1: Check validation script
    check_validation_script

    # Step 2: Validate templates
    validate_templates

    # Step 3: Check device connection
    check_device

    # Step 4: Deploy template files
    if ! deploy_templates; then
        print_error "Template deployment failed"
        exit 1
    fi

    # Step 5: Deploy templates.json
    if ! deploy_json; then
        print_error "templates.json deployment failed"
        exit 1
    fi

    # Step 6: Restart service
    restart_service

    print_success "All done!"
}

# Run main function
main
