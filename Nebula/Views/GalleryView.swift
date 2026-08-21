import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var store: ArtStore
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.02, blue: 0.12),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if store.savedArts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.3))
                        Text("No creations yet")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Create something beautiful in the Studio\nand tap Save to keep it here.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.35))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(store.savedArts) { art in
                                ArtCard(art: art)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            store.delete(art)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }
}

struct ArtCard: View {
    let art: SavedArt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder visual based on mode
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: paletteColors(for: art.paletteName),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: iconForMode(art.mode))
                            .font(.system(size: 32))
                            .foregroundStyle(.white.opacity(0.7))
                    )
                
                // Decorative particles
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(0.4))
                        .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
                        .offset(
                            x: CGFloat.random(in: -50...50),
                            y: CGFloat.random(in: -40...40)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(art.mode)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(art.paletteName + " • " + art.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 4)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.06))
        )
    }
    
    private func iconForMode(_ mode: String) -> String {
        ArtMode.allCases.first { $0.rawValue == mode }?.icon ?? "sparkles"
    }
    
    private func paletteColors(for name: String) -> [Color] {
        ColorPalette.presets.first { $0.name == name }?.colors ?? ColorPalette.presets[0].colors
    }
}
