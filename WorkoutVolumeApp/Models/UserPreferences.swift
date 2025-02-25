import Foundation

struct UserPreferences: Codable {
    var name: String
    var email: String
    var frequency: Int // Days per week
    var weakPoints: [MuscleGroup]
    var lesserPriority: [MuscleGroup]
    var cannotTrain: [MuscleGroup]
    var preferredVolume: Int // 1-100 scale
    var preferredIntensity: Int // 1-100 scale
    
    init(
        name: String = "",
        email: String = "",
        frequency: Int = 4,
        weakPoints: [MuscleGroup] = [],
        lesserPriority: [MuscleGroup] = [],
        cannotTrain: [MuscleGroup] = [],
        preferredVolume: Int = 50,
        preferredIntensity: Int = 50
    ) {
        self.name = name
        self.email = email
        self.frequency = frequency
        self.weakPoints = weakPoints
        self.lesserPriority = lesserPriority
        self.cannotTrain = cannotTrain
        self.preferredVolume = preferredVolume
        self.preferredIntensity = preferredIntensity
    }
    
    // Check if a user has completed their profile
    var isProfileComplete: Bool {
        return !name.isEmpty && !email.isEmpty
    }
    
    // Check if workout preferences (not personal info) are complete
    var arePreferencesComplete: Bool {
        return frequency > 0
    }
}