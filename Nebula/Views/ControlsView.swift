import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var store: ArtStore
    @Binding var showControls: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(.white.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 8)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Mode selector
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Mode", systemImage: "paintpalette.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(ArtMode.allCases) { mode in
                                    ModeButton(mode: mode, isSelected: store.currentMode == mode) {
                                        withAnimation(.spring(response: 0.35)) {
                                            store.currentMode = mode
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                    
                    // Palette
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Palette", systemImage: "circle.hexagongrid.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ColorPalette.presets) { palette in
                                    PaletteButton(palette: palette, isSelected: store.currentPalette.name == palette.name) {
                                        withAnimation {
                                            store.currentPalette = palette
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Sli ders
                    VStack(spacing: 16) {
                        SliderRow(title: "Intensity", icon: "flame.fill", value: $store.intensity)
                        SliderRow(title: "Complexity", icon: "square.stack.3d.up.fill", value: $store.complexity)
                        SliderRow(title: "Speed", icon: "hare.fill", value: $store.speed)
                        SliderRow(title: "Density", icon: "circle.grid.3x3.fill", value: $store.particleCount, range: 30...300)
                    }
                    
                    // Actions
                    HStack(spacing: 12) {
                        ActionButton(title: store.isPlaying ? "Pause" : "Play", icon: store.isPlaying ? "pause.fill" : "play.fill") {
                            store.isPlaying.toggle()
                        }
                        
                        ActionButton(title: "Burst", icon: "sparkle") {
                            // Triggered via gesture mainly
                        }
                        
                        ActionButton(title: "Save", icon: "square.and.arrow.down.fill") {
                            store.saveCurrent(seed: UInt64.random(in: 0...UInt64.max))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .frame(maxHeight: 380)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.25), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.4), radius: 30, y: -10)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

struct ModeButton: View {
    let mode: ArtMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(mode.rawValue)
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .frame(width: 72, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.white.opacity(0.35) : .clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct PaletteButton: View {
    let palette: ColorPalette
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                HStack(spacing: 0) {
                    ForEach(0..<palette.colors.count, id: \.self) { i in
                        palette.colors[i]
                            .frame(width: 14, height: 28)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(isSelected ? 0.7 : 0.15), lineWidth: isSelected ? 2 : 1)
                )
                
                Text(palette.name)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
    }
}

struct SliderRow: View {
    let title: String
    let icon: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(String(format: "%.0f%%", (value - range.lowerBound) / (range.upperBound - range.lowerBound) * 100))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            
            Slider(value: $value, in: range)
                .tint(.white.opacity(0.8))
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.white.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
