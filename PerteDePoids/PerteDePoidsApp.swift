import SwiftUI

/// Point d’entrée de l’application.  
/// Cette structure définit la scène principale et instancie l’état partagé de l’application.
@main
struct PerteDePoidsApp: App {
    /// L’état global de l’application. Dans une implémentation complète, il sera injecté via un ``StorageService``.
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
        }
    }
}