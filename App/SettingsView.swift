import SwiftUI

/// Settings screen allowing the user to view storage usage and export/import the state.
struct SettingsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var usedMB: Double = 0
    @State private var quotaMB: Int = 0
    
    var body: some View {
        Form {
            Section(header: Text("Stockage")) {
                Text("Utilisé : \(usedMB, specifier: "%.2f") Mo / Quota : \(quotaMB) Mo")
                    .onAppear {
                        Task {
                            let usage = await viewModel.storageUsage()
                            usedMB = usage.usedMB
                            quotaMB = usage.quotaMB
                        }
                    }
                Stepper(value: Binding(
                    get: { viewModel.state.settings.storageQuotaMB },
                    set: { newValue in
                        viewModel.state.settings.storageQuotaMB = newValue
                        quotaMB = newValue
                        // Note : pour que le service prenne en compte le nouveau quota, il faudrait recréer l'instance de StorageService.
                    }
                ), in: 25...500, step: 25) {
                    Text("Quota : \(viewModel.state.settings.storageQuotaMB) Mo")
                }
                Button("Rafraîchir l’estimation") {
                    Task {
                        let usage = await viewModel.storageUsage()
                        usedMB = usage.usedMB
                        quotaMB = usage.quotaMB
                    }
                }
            }
            Section(header: Text("Export / Import")) {
                Button("Exporter en JSON") {
                    Task { await viewModel.exportStateJSON() }
                }
                Button("Exporter en YAML") {
                    Task { await viewModel.exportStateYAML() }
                }
                // À faire : importer depuis un fichier ou collé depuis le presse‑papier.
                Text("Importation à venir…")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Réglages")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AppViewModel()
        return NavigationView {
            SettingsView()
                .environmentObject(vm)
        }
    }
}
