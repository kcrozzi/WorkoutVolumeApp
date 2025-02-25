import SwiftUI

struct MainTabView: View {
    @StateObject private var dataStore = DataStore()
    @StateObject private var planViewModel: WorkoutPlanViewModel
    
    init() {
        let dataStore = DataStore()
        self._planViewModel = StateObject(wrappedValue: WorkoutPlanViewModel(dataStore: dataStore))
    }
    
    var body: some View {
        TabView {
            PlanListView(viewModel: planViewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Plans")
                }
            
            if planViewModel.selectedPlan != nil {
                WorkoutEditorView(viewModel: planViewModel)
                    .tabItem {
                        Image(systemName: "square.and.pencil")
                        Text("Edit")
                    }
                
                VolumeAnalysisView(viewModel: planViewModel)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Volume")
                    }
                
                ExportView(viewModel: planViewModel)
                    .tabItem {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export")
                    }
            }
            
            SettingsView(dataStore: dataStore)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(Color(UIColor(red: 0.1, green: 0.7, blue: 0.8, alpha: 1.0)))
        .preferredColorScheme(.dark)
    }
}