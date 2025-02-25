import SwiftUI

struct PlanListView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    @State private var showingNewPlanSheet = false
    @State private var showingDeleteAlert = false
    @State private var planToDelete: UUID? = nil
    @State private var newPlanName = ""
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.workoutPlans.isEmpty {
                    Section {
                        Text("You don't have any workout plans yet. Create one to get started!")
                            .foregroundColor(.secondary)
                            .padding(.vertical)
                    }
                } else {
                    Section(header: Text("Your Workout Plans")) {
                        ForEach(viewModel.workoutPlans) { plan in
                            WorkoutPlanRow(plan: plan, isSelected: plan.id == viewModel.selectedPlan?.id) {
                                viewModel.selectPlan(id: plan.id)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    planToDelete = plan.id
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Workout Plans")
            .navigationBarItems(
                trailing: Button(action: {
                    showingNewPlanSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            )
            .sheet(isPresented: $showingNewPlanSheet) {
                NewPlanSheet(isPresented: $showingNewPlanSheet, viewModel: viewModel)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Plan"),
                    message: Text("Are you sure you want to delete this workout plan? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let id = planToDelete {
                            viewModel.deletePlan(id: id)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct WorkoutPlanRow: View {
    let plan: WorkoutPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.headline)
                    Text("\(plan.days.count) day plan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NewPlanSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: WorkoutPlanViewModel
    @State private var planName = ""
    @State private var frequency = 4
    @State private var showingPreferencesQuestions = false
    @State private var userPreferences: UserPreferences?
    
    private let dataStore = DataStore()
    private let onboardingViewModel: OnboardingViewModel
    
    init(isPresented: Binding<Bool>, viewModel: WorkoutPlanViewModel) {
        self._isPresented = isPresented
        self.viewModel = viewModel
        self.onboardingViewModel = OnboardingViewModel(dataStore: dataStore)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !showingPreferencesQuestions {
                    // First screen - plan name
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Create New Workout Plan")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        TextField("Plan Name", text: $planName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Picker("Days per week", selection: $frequency) {
                            ForEach(1...7, id: \.self) { days in
                                Text("\(days) days").tag(days)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        Button(action: {
                            showingPreferencesQuestions = true
                            userPreferences = UserPreferences(
                                name: dataStore.userPreferences.name,
                                email: dataStore.userPreferences.email,
                                frequency: frequency
                            )
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(planName.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(planName.isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                } else {
                    // Training preferences questions
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Training Preferences")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top)
                            
                            if let preferences = userPreferences {
                                // Show preference configuration UI similar to TrainingPreferencesView
                                Text("You're creating a \(preferences.frequency)-day plan.")
                                    .font(.headline)
                                
                                // Let's keep it simpler for creating a new plan
                                VStack(alignment: .leading) {
                                    Text("Select your weak points (muscle groups you want to emphasize)")
                                        .font(.headline)
                                    
                                    MuscleGroupSelectionView(
                                        selectedGroups: Binding(
                                            get: { preferences.weakPoints },
                                            set: { _ in }
                                        )
                                    )
                                }
                                .padding(.bottom)
                                
                                Button(action: {
                                    let newPlan = viewModel.createNewPlan(
                                        name: planName,
                                        userPreferences: preferences
                                    )
                                    isPresented = false
                                }) {
                                    Text("Create Plan")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.vertical)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: showingPreferencesQuestions ?
                    Button("Back") {
                        showingPreferencesQuestions = false
                    } : nil
            )
        }
    }
}