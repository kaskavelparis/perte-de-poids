import SwiftUI

/// Root view displayed when the application launches.
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("MarIA Willy RPG")
                    .font(.title)
                    .padding()
                // Additional UI will be added in later iterations.
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AppViewModel()
        return ContentView()
            .environmentObject(vm)
    }
}
