import SwiftUI

/// Vue d’accueil simplifiée.  
/// Affiche le titre du jeu et quelques placeholders pour le futur tableau de bord.
struct HomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("MarIA Willy RPG")
                    .font(.largeTitle)
                    .bold()
                Text("Niveau \(appState.avatar.level) – XP \(appState.avatar.xp)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ProgressView(value: Double(appState.avatar.hpCurrent), total: Double(appState.avatar.hpMax)) {
                    Text("HP")
                }
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.horizontal)

                Spacer()
                Text("Cette vue sera développée pour afficher l’avatar, la fée MarIA, le boss hebdomadaire, et les badges.")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
            .padding()
            .navigationTitle("Accueil")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppState())
    }
}