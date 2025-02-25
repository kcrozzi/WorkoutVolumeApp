import Foundation
import Combine

class DataStore: ObservableObject {
    @Published var userPreferences: UserPreferences
    @Published var workoutPlans: [WorkoutPlan]
    @Published var selectedPlanId: UUID?
    
    private let userPreferencesKey = "userPreferences"
    private let workoutPlansKey = "workoutPlans"
    private let selectedPlanIdKey = "selectedPlanId"
    
    init() {
        // Load user preferences from UserDefaults or use default
        if let savedUserPreferencesData = UserDefaults.standard.data(forKey: userPreferencesKey),
           let savedUserPreferences = try? JSONDecoder().decode(UserPreferences.self, from: savedUserPreferencesData) {
            self.userPreferences = savedUserPreferences
        } else {
            self.userPreferences = UserPreferences()
        }
        
        // Load workout plans from UserDefaults or use empty array
        if let savedWorkoutPlansData = UserDefaults.standard.data(forKey: workoutPlansKey),
           let savedWorkoutPlans = try? JSONDecoder().decode([WorkoutPlan].self, from: savedWorkoutPlansData) {
            self.workoutPlans = savedWorkoutPlans
        } else {
            self.workoutPlans = []
        }
        
        // Load selected plan ID if available
        if let savedSelectedPlanIdData = UserDefaults.standard.data(forKey: selectedPlanIdKey),
           let savedSelectedPlanId = try? JSONDecoder().decode(UUID.self, from: savedSelectedPlanIdData) {
            self.selectedPlanId = savedSelectedPlanId
        } else {
            self.selectedPlanId = nil
        }
        
        // Save changes to UserDefaults whenever data changes
        setupSaving()
    }
    
    private func setupSaving() {
        // Save user preferences whenever they change
        $userPreferences
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] preferences in
                guard let self = self else { return }
                if let encoded = try? JSONEncoder().encode(preferences) {
                    UserDefaults.standard.set(encoded, forKey: self.userPreferencesKey)
                }
            }
            .store(in: &cancellables)
        
        // Save workout plans whenever they change
        $workoutPlans
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] plans in
                guard let self = self else { return }
                if let encoded = try? JSONEncoder().encode(plans) {
                    UserDefaults.standard.set(encoded, forKey: self.workoutPlansKey)
                }
            }
            .store(in: &cancellables)
        
        // Save selected plan ID whenever it changes
        $selectedPlanId
            .sink { [weak self] id in
                guard let self = self else { return }
                if let id = id, let encoded = try? JSONEncoder().encode(id) {
                    UserDefaults.standard.set(encoded, forKey: self.selectedPlanIdKey)
                } else {
                    UserDefaults.standard.removeObject(forKey: self.selectedPlanIdKey)
                }
            }
            .store(in: &cancellables)
    }
    
    // Keep track of cancellables for Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - User Preferences Methods
    
    func updateUserPreferences(_ preferences: UserPreferences) {
        userPreferences = preferences
    }
    
    // MARK: - Workout Plan Methods
    
    var selectedPlan: WorkoutPlan? {
        guard let id = selectedPlanId else { return nil }
        return workoutPlans.first { $0.id == id }
    }
    
    func selectPlan(id: UUID) {
        selectedPlanId = id
    }
    
    func createNewPlan(name: String, userPreferences: UserPreferences) -> WorkoutPlan {
        // Create empty days based on frequency
        var days: [WorkoutDay] = []
        for i in 1...userPreferences.frequency {
            days.append(WorkoutDay(name: "Day \(i)"))
        }
        
        // Create the plan
        let plan = WorkoutPlan(name: name, days: days, userPreferences: userPreferences)
        
        // Add it to workout plans and select it
        workoutPlans.append(plan)
        selectedPlanId = plan.id
        
        return plan
    }
    
    func updatePlan(_ updatedPlan: WorkoutPlan) {
        if let index = workoutPlans.firstIndex(where: { $0.id == updatedPlan.id }) {
            workoutPlans[index] = updatedPlan
        }
    }
    
    func deletePlan(id: UUID) {
        workoutPlans.removeAll { $0.id == id }
        if selectedPlanId == id {
            selectedPlanId = workoutPlans.first?.id
        }
    }
    
    // MARK: - Workout Day Methods
    
    func addExerciseToDay(planId: UUID, dayId: UUID, exercise: Exercise, sets: Int) {
        guard let planIndex = workoutPlans.firstIndex(where: { $0.id == planId }),
              let dayIndex = workoutPlans[planIndex].days.firstIndex(where: { $0.id == dayId }) else {
            return
        }
        
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: sets)
        workoutPlans[planIndex].days[dayIndex].exercises.append(workoutExercise)
    }
    
    func updateExerciseSets(planId: UUID, dayId: UUID, exerciseId: UUID, sets: Int) {
        guard let planIndex = workoutPlans.firstIndex(where: { $0.id == planId }),
              let dayIndex = workoutPlans[planIndex].days.firstIndex(where: { $0.id == dayId }),
              let exerciseIndex = workoutPlans[planIndex].days[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        workoutPlans[planIndex].days[dayIndex].exercises[exerciseIndex].sets = sets
    }
    
    func removeExercise(planId: UUID, dayId: UUID, exerciseId: UUID) {
        guard let planIndex = workoutPlans.firstIndex(where: { $0.id == planId }),
              let dayIndex = workoutPlans[planIndex].days.firstIndex(where: { $0.id == dayId }) else {
            return
        }
        
        workoutPlans[planIndex].days[dayIndex].exercises.removeAll { $0.id == exerciseId }
    }
    
    // MARK: - Export Methods
    
    func exportPlanAsCSV(plan: WorkoutPlan) -> String {
        var csv = "Workout Plan: \(plan.name)\n"
        csv += "Frequency: \(plan.userPreferences.frequency) days per week\n\n"
        
        // Add each day and its exercises
        for day in plan.days {
            csv += "\(day.name)\n"
            csv += "Exercise,Sets\n"
            
            for exercise in day.exercises {
                csv += "\(exercise.exercise.name),\(exercise.sets)\n"
            }
            csv += "\n"
        }
        
        // Add volume summary
        csv += "Weekly Volume Summary\n"
        csv += "Muscle Group,Total Volume,Recommended Range,Status\n"
        
        for muscleGroup in MuscleGroup.allCases {
            let volume = plan.totalWeeklyVolume(for: muscleGroup)
            let range = muscleGroup.recommendedVolumeRange
            let status = plan.volumeStatus(for: muscleGroup)
            
            csv += "\(muscleGroup.rawValue),\(volume),\(range.lowerBound)-\(range.upperBound),\(status.description)\n"
        }
        
        return csv
    }
}