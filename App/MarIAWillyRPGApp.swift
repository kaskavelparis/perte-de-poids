import SwiftUI

/// Entry point for the MarIA Willy RPG application.
@main
struct MarIAWillyRPGApp: App {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}
