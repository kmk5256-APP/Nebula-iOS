import SwiftUI

@main
struct NebulaApp: App {
    @StateObject private var artStore = ArtStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(artStore)
                .preferredColorScheme(.dark)
        }
    }
}
