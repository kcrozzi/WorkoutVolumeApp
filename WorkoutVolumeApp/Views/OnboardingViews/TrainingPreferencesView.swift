import SwiftUI

struct TrainingPreferencesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var frequency: Int = 4
    @State private var weakPoints: [MuscleGroup] = []
    @State private var lesserPriority: [MuscleGroup] = []
    @State private var cannotTrain: [MuscleGroup] = []
    @State private var preferredVolume: Double = 50
    @State private var preferredIntensity: Double = 50
    @State private var showingPlanCreation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Training Preferences")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Frequency Selection
                VStack(alignment: .leading) {
                    Text("How many days per week would you like to train?")
                        .font(.headline)
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(1...7, id: \.self) { days in
                            Text("\(days) days").tag(days)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.bottom)
                
                // Weak Points
                VStack(alignment: .leading) {
                    Text("Select your weak points (muscle groups you want to emphasize)")
                        .font(.headline)
                    
                    MuscleGroupSelectionView(selectedGroups: $weakPoints)
                }
                .padding(.bottom)
                
                // Lesser Priority
                VStack(alignment: .leading) {
                    Text("Select muscle groups you care less about")
                        .font(.headline)
                    
                    MuscleGroupSelectionView(selectedGroups: $lesserPriority)
                }
                .padding(.bottom)
                
                // Cannot Train
                VStack(alignment: .leading) {
                    Text("Select muscle groups you cannot train (injury, equipment restrictions)")
                        .font(.headline)
                    
                    MuscleGroupSelectionView(selectedGroups: $cannotTrain)
                }
                .padding(.bottom)
                
                // Preferred Volume
                VStack(alignment: .leading) {
                    Text("Preferred Volume (1-100)")
                        .font(.headline)
                    
                    HStack {
                        Text("Low")
                        Slider(value: $preferredVolume, in: 1...100, step: 1)
                        Text("High")
                    }
                    
                    Text("Value: \(Int(preferredVolume))")
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
                
                // Preferred Intensity
                VStack(alignment: .leading) {
                    Text("Preferred Intensity (1-100)")
                        .font(.headline)
                    
                    HStack {
                        Text("Low")
                        Slider(value: $preferredIntensity, in: 1...100, step: 1)
                        Text("High")
                    }
                    
                    Text("Value: \(Int(preferredIntensity))")
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
                
                // Save Button
                Button(action: {
                    savePreferences()
                    showingPlanCreation = true
                }) {
                    Text("Save & Create Plan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.vertical)
                
                NavigationLink(
                    destination: CreatePlanView(viewModel: viewModel),
                    isActive: $showingPlanCreation,
                    label: { EmptyView() }
                )
            }
            .padding()
        }
        .onAppear {
            loadExistingPreferences()
        }
        .navigationTitle("Training Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
    
    private func loadExistingPreferences() {
        let preferences = viewModel.userPreferences
        frequency = preferences.frequency
        weakPoints = preferences.weakPoints
        lesserPriority = preferences.lesserPriority
        cannotTrain = preferences.cannotTrain
        preferredVolume = Double(preferences.preferredVolume)
        preferredIntensity = Double(preferences.preferredIntensity)
    }
    
    private func savePreferences() {
        viewModel.updateWorkoutPreferences(
            frequency: frequency,
            weakPoints: weakPoints,
            lesserPriority: lesserPriority,
            cannotTrain: cannotTrain,
            preferredVolume: Int(preferredVolume),
            preferredIntensity: Int(preferredIntensity)
        )
    }
}

struct MuscleGroupSelectionView: View {
    @Binding var selectedGroups: [MuscleGroup]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.flexible())], spacing: 10) {
                ForEach(MuscleGroup.allCases) { muscleGroup in
                    MuscleGroupTag(
                        title: muscleGroup.rawValue,
                        isSelected: selectedGroups.contains(muscleGroup),
                        action: {
                            if selectedGroups.contains(muscleGroup) {
                                selectedGroups.removeAll { $0 == muscleGroup }
                            } else {
                                selectedGroups.append(muscleGroup)
                            }
                        }
                    )
                }
            }
            .padding(.vertical, 5)
        }
    }
}

struct MuscleGroupTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
    }
}