import SwiftUI

struct CreatePlanView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var planName: String = ""
    @State private var showingMainApp = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Your Workout Plan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("Give your plan a name to get started")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            TextField("Plan Name (e.g., 'Summer Bulk 2025')", text: $planName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Frequency reminder
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                
                Text("Based on your preferences, this will be a \(viewModel.userPreferences.frequency)-day workout plan.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                viewModel.createNewPlan(name: planName.isEmpty ? "My Workout Plan" : planName)
                showingMainApp = true
            }) {
                Text("Create Plan")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationDestination(isPresented: $showingMainApp) {
            MainTabView()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
        }
        .navigationTitle("Create Plan")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}