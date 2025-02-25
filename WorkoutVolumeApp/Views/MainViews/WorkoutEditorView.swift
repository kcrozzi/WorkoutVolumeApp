import SwiftUI

struct WorkoutEditorView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if let plan = viewModel.selectedPlan {
                    List {
                        Section(header: Text("Workout Days")) {
                            ForEach(plan.days) { day in
                                NavigationLink(destination: DayEditorView(viewModel: viewModel, day: day)) {
                                    HStack {
                                        Text(day.name)
                                        
                                        Spacer()
                                        
                                        Text("\(day.exercises.count) exercises")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle(plan.name)
                } else {
                    VStack {
                        Text("No workout plan selected")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Please select a plan from the Plans tab")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .navigationTitle("Workout Editor")
                }
            }
        }
    }
}

struct DayEditorView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    let day: WorkoutDay
    @State private var showingAddExercise = false
    @State private var showingDeleteAlert = false
    @State private var exerciseToDelete: UUID? = nil
    
    var body: some View {
        List {
            if day.exercises.isEmpty {
                Section {
                    Text("No exercises added yet. Tap the + button to add your first exercise.")
                        .foregroundColor(.secondary)
                        .padding(.vertical)
                }
            } else {
                Section(header: Text("Exercises")) {
                    ForEach(day.exercises) { exercise in
                        ExerciseRow(
                            exercise: exercise,
                            onSetsChanged: { newSets in
                                viewModel.updateExerciseSets(
                                    dayId: day.id,
                                    exerciseId: exercise.id,
                                    sets: newSets
                                )
                            },
                            onDelete: {
                                exerciseToDelete = exercise.id
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(day.name)
        .navigationBarItems(
            trailing: Button(action: {
                showingAddExercise = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            }
        )
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView(isPresented: $showingAddExercise, viewModel: viewModel, dayId: day.id)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Remove Exercise"),
                message: Text("Are you sure you want to remove this exercise?"),
                primaryButton: .destructive(Text("Remove")) {
                    if let id = exerciseToDelete {
                        viewModel.removeExercise(dayId: day.id, exerciseId: id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ExerciseRow: View {
    let exercise: WorkoutExercise
    let onSetsChanged: (Int) -> Void
    let onDelete: () -> Void
    @State private var sets: String
    
    init(exercise: WorkoutExercise, onSetsChanged: @escaping (Int) -> Void, onDelete: @escaping () -> Void) {
        self.exercise = exercise
        self.onSetsChanged = onSetsChanged
        self.onDelete = onDelete
        self._sets = State(initialValue: String(exercise.sets))
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exercise.name)
                    .font(.headline)
                
                Text("Primary: \(exercise.exercise.primaryMuscle.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !exercise.exercise.secondaryMuscles.isEmpty {
                    Text("Secondary: \(secondaryMusclesText)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack {
                Text("Sets:")
                    .font(.subheadline)
                
                TextField("", text: $sets)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 40)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                    .onChange(of: sets) { newValue in
                        if let newSets = Int(newValue), newSets > 0 {
                            onSetsChanged(newSets)
                        }
                    }
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(.leading, 8)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var secondaryMusclesText: String {
        exercise.exercise.secondaryMuscles
            .map { "\($0.muscle.rawValue)" }
            .joined(separator: ", ")
    }
}

struct AddExerciseView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: WorkoutPlanViewModel
    let dayId: UUID
    @State private var searchText = ""
    @State private var selectedCategory: MuscleGroup?
    @State private var selectedExercise: Exercise?
    @State private var sets: Int = 3
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and filter
                VStack {
                    TextField("Search exercises", text: $searchText)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    // Muscle group filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            MuscleGroupFilterButton(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(MuscleGroup.allCases) { muscleGroup in
                                MuscleGroupFilterButton(
                                    title: muscleGroup.rawValue,
                                    isSelected: selectedCategory == muscleGroup,
                                    action: {
                                        selectedCategory = muscleGroup
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
                
                // Exercise list
                List {
                    ForEach(filteredExercises) { exercise in
                        Button(action: {
                            selectedExercise = exercise
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.headline)
                                    
                                    Text("Primary: \(exercise.primaryMuscle.rawValue)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if !exercise.secondaryMuscles.isEmpty {
                                        Text("Secondary: \(secondaryMusclesText(for: exercise))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if selectedExercise == exercise {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
                
                // Sets selection and add button
                if selectedExercise != nil {
                    VStack {
                        HStack {
                            Text("Sets:")
                            
                            Stepper("\(sets)", value: $sets, in: 1...10)
                                .frame(width: 100)
                        }
                        .padding()
                        
                        Button(action: {
                            if let exercise = selectedExercise {
                                viewModel.addExerciseToDay(dayId: dayId, exercise: exercise, sets: sets)
                                isPresented = false
                            }
                        }) {
                            Text("Add Exercise")
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
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
            )
        }
    }
    
    private var filteredExercises: [Exercise] {
        var exercises = Exercise.all
        
        // Filter by category
        if let category = selectedCategory {
            exercises = exercises.filter { $0.primaryMuscle == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            exercises = exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return exercises
    }
    
    private func secondaryMusclesText(for exercise: Exercise) -> String {
        exercise.secondaryMuscles
            .map { "\($0.muscle.rawValue)" }
            .joined(separator: ", ")
    }
}

struct MuscleGroupFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
    }
}