import SwiftUI
import Combine

@MainActor
class ArtStore: ObservableObject {
    @Published var savedArts: [SavedArt] = []
    @Published var currentMode: ArtMode = .particles
    @Published var currentPalette: ColorPalette = ColorPalette.presets[0]
    @Published var intensity: Double = 0.7
    @Published var complexity: Double = 0.6
    @Published var speed: Double = 0.5
    @Published var particleCount: Double = 120
    @Published var isPlaying: Bool = true
    @Published var showControls: Bool = true
    
    private let saveKey = "nebula_saved_arts"
    
    init() {
        load()
    }
    
    func saveCurrent(seed: UInt64) {
        let art = SavedArt(
            id: UUID(),
            date: Date(),
            mode: currentMode.rawValue,
            paletteName: currentPalette.name,
            seed: seed
        )
        savedArts.insert(art, at: 0)
        persist()
    }
    
    func delete(_ art: SavedArt) {
        savedArts.removeAll { $0.id == art.id }
        persist()
    }
    
    private func persist() {
        if let data = try? JSONEncoder().encode(savedArts) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([SavedArt].self, from: data) {
            savedArts = decoded
        }
    }
}
