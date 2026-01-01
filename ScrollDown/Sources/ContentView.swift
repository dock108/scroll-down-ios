import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appConfig: AppConfig
    
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppConfig.shared)
}

