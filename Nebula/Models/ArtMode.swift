import SwiftUI

enum ArtMode: String, CaseIterable, Identifiable {
    case particles = "Particles"
    case flowField = "Flow Field"
    case organic = "Organic"
    case geometry = "Geometry"
    case aurora = "Aurora"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .particles: return "sparkles"
        case .flowField: return "wind"
        case .organic: return "leaf.fill"
        case .geometry: return "hexagon.fill"
        case .aurora: return "moon.stars.fill"
        }
    }
    
    var description: String {
        switch self {
        case .particles: return "Swirling cosmic dust & star bursts"
        case .flowField: return "Fluid vector fields & current lines"
        case .organic: return "Living blobs & cellular forms"
        case .geometry: return "Sacred geometry & crystalline structures"
        case .aurora: return "Northern lights & ethereal waves"
        }
    }
}

struct ColorPalette: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let colors: [Color]
    
    static let presets: [ColorPalette] = [
        ColorPalette(name: "Nebula", colors: [
            Color(red: 0.4, green: 0.1, blue: 0.8),
            Color(red: 0.9, green: 0.2, blue: 0.6),
            Color(red: 0.2, green: 0.6, blue: 1.0),
            Color(red: 1.0, green: 0.8, blue: 0.3)
        ]),
        ColorPalette(name: "Aurora", colors: [
            Color(red: 0.1, green: 0.9, blue: 0.6),
            Color(red: 0.2, green: 0.4, blue: 1.0),
            Color(red: 0.8, green: 0.2, blue: 0.9),
            Color(red: 0.0, green: 1.0, blue: 0.8)
        ]),
        ColorPalette(name: "Sunset", colors: [
            Color(red: 1.0, green: 0.3, blue: 0.2),
            Color(red: 1.0, green: 0.6, blue: 0.1),
            Color(red: 0.9, green: 0.2, blue: 0.5),
            Color(red: 0.4, green: 0.1, blue: 0.6)
        ]),
        ColorPalette(name: "Void", colors: [
            Color(red: 0.1, green: 0.8, blue: 0.9),
            Color(red: 0.6, green: 0.1, blue: 0.9),
            Color(red: 0.2, green: 0.3, blue: 0.8),
            Color(red: 0.9, green: 0.9, blue: 1.0)
        ]),
        ColorPalette(name: "Ember", colors: [
            Color(red: 1.0, green: 0.4, blue: 0.1),
            Color(red: 0.9, green: 0.1, blue: 0.2),
            Color(red: 1.0, green: 0.7, blue: 0.2),
            Color(red: 0.5, green: 0.0, blue: 0.1)
        ]),
        ColorPalette(name: "Crystal", colors: [
            Color(red: 0.6, green: 0.9, blue: 1.0),
            Color(red: 0.8, green: 0.6, blue: 1.0),
            Color(red: 1.0, green: 0.7, blue: 0.9),
            Color(red: 0.4, green: 0.8, blue: 0.9)
        ])
    ]
}

struct SavedArt: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mode: String
    let paletteName: String
    // In a real app we'd store the image data or seed
    let seed: UInt64
}
