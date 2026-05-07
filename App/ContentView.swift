import SwiftUI

/// Root view displayed when the application launches.
struct ContentView: View {
    private let minecraftHighlights: [(icon: String, title: String, description: String)] = [
        ("cube.fill", "Exploration", "Transforme tes objectifs du jour en quêtes façon survie."),
        ("hammer.fill", "Récolte", "Gagne des récompenses quand tu journalises repas et activité."),
        ("shield.lefthalf.filled", "Boss", "Prépare ton avatar avant le rapport de bataille du soir.")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroSection
                    highlightsSection
                }
                .padding()
            }
            .navigationTitle("Accueil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MarIA Willy RPG")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Mode Minecraft")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.green)
            Text("Construis ta progression bloc par bloc : chaque repas analysé, chaque pas et chaque rapport quotidien renforcent ton aventure.")
                .foregroundColor(.secondary)
            Label("Objectif du jour : miner de bonnes habitudes", systemImage: "sparkles")
                .font(.subheadline)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.9), Color.brown.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .foregroundColor(.white)
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Univers du jour")
                .font(.headline)
            ForEach(minecraftHighlights, id: \.title) { highlight in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: highlight.icon)
                        .font(.title2)
                        .foregroundColor(.green)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(highlight.title)
                            .font(.headline)
                        Text(highlight.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AppViewModel()
        return ContentView()
            .environmentObject(vm)
    }
}
