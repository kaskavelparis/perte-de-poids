import SwiftUI

/// Type of report to display (route at 14 h or battle at 23 h).
public enum ReportType {
    case route
    case battle
}

/// View displaying a summary of the day at 14 h (route) or 23 h (battle) with an option to save a snapshot.
struct ReportView: View {
    @EnvironmentObject var state: AppState
    /// Daily log used to populate the report.
    let log: DailyLog
    let type: ReportType
    var imageService: ImageService = FileImageService()
    
    @State private var showAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(type == .route ? "Rapport de Route" : "Rapport de Bataille")
                    .font(.title2)
                    .bold()
                if type == .route {
                    routeSection
                } else {
                    battleSection
                }
            }
            .padding()
        }
    }
    
    /// Section for the 14 h “Route” report.
    private var routeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Calories consommées le matin : \(log.totalKcal)")
            // Placeholder: remaining calories could be computed against a goal from settings
            Text("Calories restantes : …")
            Text("Progrès du chemin : \(state.journey.stepsToday)/\(state.journey.distanceToNext) pas")
            Text("Objectif du boss : \(state.boss.dailyObjective)")
        }
    }
    
    /// Section for the 23 h “Bataille” report.
    private var battleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total calories : \(log.totalKcal)")
            Text("Badge du jour : \(log.badgeDaily.rawValue)")
            Text("XP : \(state.avatar.xp) – HP : \(state.avatar.hpCurrent)/\(state.avatar.hpMax)")
            Text("Boss : \(Int(state.boss.hpPercent * 100)) % HP")
            let lootCount = state.avatar.inventory.weapons.count + state.avatar.inventory.shields.count + state.avatar.inventory.capes.count + state.avatar.inventory.artifacts.count
            Text("Butin : \(lootCount) objet(s)")
            Button("Enregistrer le rapport") {
                saveSnapshot()
            }
            .buttonStyle(.bordered)
            .padding(.top)
            .alert("Rapport sauvegardé", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    /// Captures a snapshot of the report and saves it to disk.
    private func saveSnapshot() {
        #if canImport(UIKit)
        do {
            let anyView = AnyView(self)
            _ = try imageService.saveReportSnapshot(view: anyView, date: log.date)
            showAlert = true
        } catch {
            print("Erreur lors de l'enregistrement du snapshot : \(error)")
        }
        #endif
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        let state = AppState()
        let log = DailyLog()
        return ReportView(log: log, type: .route)
            .environmentObject(state)
    }
}
