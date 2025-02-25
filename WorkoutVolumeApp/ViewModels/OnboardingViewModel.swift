import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var userPreferences: UserPreferences
    private let dataStore: DataStore
    private var cancellables = Set<AnyCancellable>()
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        self.userPreferences = dataStore.userPreferences
        
        // Bind to dataStore's userPreferences
        dataStore.$userPreferences
            .sink { [weak self] preferences in
                self?.userPreferences = preferences
            }
            .store(in: &cancellables)
    }
    
    // Used for profile setup (personal details)
    func updateProfile(name: String, email: String) {
        var updatedPreferences = userPreferences
        updatedPreferences.name = name
        updatedPreferences.email = email
        dataStore.updateUserPreferences(updatedPreferences)
    }
    
    // Used for workout preferences (training questions)
    func updateWorkoutPreferences(
        frequency: Int,
        weakPoints: [MuscleGroup],
        lesserPriority: [MuscleGroup],
        cannotTrain: [MuscleGroup],
        preferredVolume: Int,
        preferredIntensity: Int
    ) {
        var updatedPreferences = userPreferences
        updatedPreferences.frequency = frequency
        updatedPreferences.weakPoints = weakPoints
        updatedPreferences.lesserPriority = lesserPriority
        updatedPreferences.cannotTrain = cannotTrain
        updatedPreferences.preferredVolume = preferredVolume
        updatedPreferences.preferredIntensity = preferredIntensity
        dataStore.updateUserPreferences(updatedPreferences)
    }
    
    // Check if onboarding is complete
    var isOnboardingComplete: Bool {
        return userPreferences.isProfileComplete
    }
    
    // Create a new workout plan with current preferences
    func createNewPlan(name: String) {
        _ = dataStore.createNewPlan(name: name, userPreferences: userPreferences)
    }
}