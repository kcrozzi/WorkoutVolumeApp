import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showingNextScreen = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Workout Volume App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("Let's set up your profile")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(spacing: 16) {
                    TextField("Your Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Your Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.updateProfile(name: name, email: email)
                    showingNextScreen = true
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationDestination(isPresented: $showingNextScreen) {
                TrainingPreferencesView(viewModel: viewModel)
            }
            .onAppear {
                name = viewModel.userPreferences.name
                email = viewModel.userPreferences.email
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
    
    private var isFormValid: Bool {
        return !name.isEmpty && !email.isEmpty && isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}