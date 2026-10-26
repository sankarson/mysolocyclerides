import SwiftUI

@main
struct MySoloCycleRidesApp: App {
    init() {
        // Photobook pages are large; keep them on disk so revisits are instant.
        URLCache.shared = URLCache(memoryCapacity: 128 << 20, diskCapacity: 1 << 30)
    }

    var body: some Scene {
        WindowGroup {
            LibraryView()
        }
    }
}
