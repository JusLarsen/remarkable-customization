# Splash Screen Customization

Custom suspend screen (sleep/lock screen) for reMarkable tablet.

## Specifications

- **File name:** `suspended.png`
- **Dimensions:** 1404 × 1872 pixels (portrait)
- **Format:** PNG, grayscale
- **DPI:** 72 DPI
- **Device location:** `/usr/share/remarkable/suspended.png`

## Design Guidelines

### E-Ink Display Considerations
- Use high contrast designs (e-ink has 16-level grayscale)
- Keep designs simple and clean
- Avoid complex gradients (causes excessive dithering)
- Center logo with 150-200px margins for breathing room

### Creating the Suspend Screen

1. **In Figma:**
   - Create frame: 1404 × 1872 pixels
   - Center your square logo with appropriate margins
   - Export as PNG, grayscale mode, 72 DPI
   - Save as `suspended.png` in this directory

2. **Test diffusion dithering** (60-100%) if logo has gradients or photos

## Deployment

Deploy to device using the Makefile:

```bash
# Deploy suspend screen
make deploy-splash

# Or deploy both templates and splash screen
make deploy-all
```

## Notes

- **OS Updates:** Customizations in `/usr/share/remarkable/` are overwritten on OS updates
- **Backup:** Keep source files in this directory for easy re-deployment
- **Testing:** The suspend screen appears when the device goes to sleep (power button or auto-sleep)

## Resources

- [reMarkable Splash Screen Guide](https://remarkable.guide/guide/software/screens.html)
- [E-Ink Graphics Preparation](https://learn.adafruit.com/preparing-graphics-for-e-ink-displays)
