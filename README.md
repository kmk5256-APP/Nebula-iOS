# Nebula — Generative Art Studio for iOS

**A stunning native iOS app for creating living cosmic and abstract graphics.**

Built entirely with **SwiftUI** and the powerful `Canvas` API. No external dependencies. Pure graphic inspiration.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4+-purple)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Concept

Nebula is a digital art playground that turns your iPhone or iPad into a living canvas of generative beauty. Inspired by nebulae, auroras, sacred geometry, and organic forms, it invites you to **touch, drag, and burst** energy across the screen while real-time parameters reshape the entire visual universe.

This is not a static drawing app. Everything breathes. Everything reacts.

---

## Features

### Five Living Modes
| Mode | Description |
|------|-------------|
| **Particles** | Swirling cosmic dust, glowing star cores, and soft luminous trails |
| **Flow Field** | Elegant vector fields that guide particles along invisible currents |
| **Organic** | Soft, breathing cellular blobs and liquid forms |
| **Geometry** | Rotating sacred polygons and crystalline lattices |
| **Aurora** | Ethereal northern-light ribbons that dance across the sky |

### Deep Real-time Controls
- **Intensity** — brightness and energy of the forms
- **Complexity** — density of detail and structure
- **Speed** — how fast the simulation evolves
- **Density** — number of particles / elements

### Beautiful Palettes
Six carefully crafted color stories:
- Nebula • Aurora • Sunset • Void • Ember • Crystal

### Interaction
- **Drag** anywhere → emit particles and energy
- **Double-tap** → cosmic burst
- **Triple-tap** → hide/show the entire control panel for pure immersion
- **Save** creations to a personal Gallery

---

## Screenshots (Conceptual)

The entire experience is designed in a dark, cinematic aesthetic with glassmorphism controls, vibrant gradients, soft glows, and depth. The canvas fills the full screen with a subtle vignette for maximum visual impact.

---

## Requirements

- Xcode 16 or later
- iOS 17.0+ / iPadOS 17.0+
- Swift 5.9+

---

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/kmk5256-APP/Nebula-iOS.git
   cd Nebula-iOS
   ```

2. Open `Nebula.xcodeproj` in Xcode.

3. Select your target device or simulator.

4. Press **⌘R** to build and run.

> **Note**: You may need to set your own Development Team in the Signing & Capabilities tab.

---

## Project Structure

```
Nebula/
├── NebulaApp.swift          # App entry point
├── ContentView.swift        # Main container + info sheet
├── Models/
│   └── ArtMode.swift        # Modes, palettes, saved art model
├── Views/
│   ├── ParticleCanvas.swift # The living generative engine (Canvas + simulation)
│   ├── ControlsView.swift   # Glassmorphic control panel
│   └── GalleryView.swift    # Saved creations grid
├── Services/
│   └── ArtStore.swift       # State management + persistence
└── Assets.xcassets/
```

---

## Technical Highlights

- **Pure SwiftUI Canvas** rendering at 60 fps
- Custom particle system with soft glow, life cycles, and mode-specific physics
- Value-noise based flow fields
- Procedural organic shapes and rotating geometry
- Ultra-thin material glass controls with continuous corner radius
- Dark-mode first, cinematic presentation
- Zero third-party dependencies

---

## Roadmap Ideas

- Export high-resolution images / Live Photos
- Shareable seeds so friends can recreate the exact same art
- Metal compute shaders for even denser particle systems
- Apple Pencil support for precise energy painting
- Widget that shows a live mini-nebula on the Home Screen

---

## License

MIT License. Feel free to build upon Nebula, learn from it, or use pieces in your own creative tools.

---

**Made with imagination and SwiftUI**  
*Ai2Life Technologies • Pennsylvania*
