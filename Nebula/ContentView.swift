import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ArtStore
    @State private var showGallery = false
    @State private var showInfo = false
    @State private var controlsOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Living canvas
            ParticleCanvas()
                .ignoresSafeArea()
            
            // Top bar
            VStack {
                HStack {
                    // Logo / Title
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: store.currentPalette.colors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Nebula")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    // Gallery button
                    Button {
                        showGallery = true
                    } label: {
                        Image(systemName: "rectangle.stack.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    
                    // Info
                    Button {
                        showInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                Spacer()
                
                // Bottom controls (collapsible)
                if store.showControls {
                    ControlsView(showControls: $store.showControls)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Minimal toggle
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            store.showControls = true
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(color: .black.opacity(0.3), radius: 10)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .statusBarHidden(true)
        .sheet(isPresented: $showGallery) {
            GalleryView()
                .environmentObject(store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showInfo) {
            InfoView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onTapGesture(count: 3) {
            withAnimation {
                store.showControls.toggle()
            }
        }
    }
}

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Hero
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .pink, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Nebula")
                                .font(.largeTitle.weight(.bold))
                                .foregroundStyle(.white)
                            
                            Text("Generative Art Studio")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        
                        Group {
                            featureRow(icon: "hand.draw", title: "Touch to Create", text: "Drag anywhere on the canvas to emit particles and energy. Double-tap for a cosmic burst.")
                            
                            featureRow(icon: "paintpalette", title: "Five Living Modes", text: "Particles, Flow Fields, Organic forms, Sacred Geometry, and Aurora — each reacts differently to your gestures and settings.")
                            
                            featureRow(icon: "slider.horizontal.3", title: "Deep Control", text: "Tune intensity, complexity, speed and density in real time. Switch palettes for instant mood shifts.")
                            
                            featureRow(icon: "square.and.arrow.down", title: "Save & Revisit", text: "Capture your favorite moments in the Gallery. Triple-tap the canvas to hide/show controls for pure immersion.")
                        }
                        
                        Text("Built with pure SwiftUI • Metal-free Canvas rendering\nDesigned for graphic inspiration & calm creativity")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.35))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    private func featureRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.cyan)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ArtStore())
}
