import SwiftUI

@main
struct WorkoutVolumeApp: App {
    @StateObject private var dataStore = DataStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        Group {
            if dataStore.userPreferences.isProfileComplete {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject var dataStore: DataStore
    @StateObject private var viewModel: OnboardingViewModel
    
    init() {
        let dataStore = DataStore()
        self._viewModel = StateObject(wrappedValue: OnboardingViewModel(dataStore: dataStore))
    }
    
    var body: some View {
        ProfileSetupView(viewModel: viewModel)
    }
}
