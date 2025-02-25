import Foundation

struct WorkoutPlan: Identifiable, Codable {
    let id: UUID
    var name: String
    var days: [WorkoutDay]
    var userPreferences: UserPreferences
    
    init(name: String, days: [WorkoutDay] = [], userPreferences: UserPreferences) {
        self.id = UUID()
        self.name = name
        self.days = days
        self.userPreferences = userPreferences
    }
    
    // Calculate total weekly volume for a specific muscle group
    func totalWeeklyVolume(for muscleGroup: MuscleGroup) -> Double {
        days.reduce(0) { result, day in
            return result + day.totalVolume(for: muscleGroup)
        }
    }
    
    // Check if volume is within recommended range for a muscle group
    func volumeStatus(for muscleGroup: MuscleGroup) -> VolumeStatus {
        let volume = totalWeeklyVolume(for: muscleGroup)
        let range = muscleGroup.recommendedVolumeRange
        
        if volume < Double(range.lowerBound) {
            return .under
        } else if volume > Double(range.upperBound) {
            return .over
        } else {
            return .optimal
        }
    }
}

enum VolumeStatus {
    case under
    case optimal
    case over
    
    var color: String {
        switch self {
        case .under:
            return "yellow"
        case .optimal:
            return "green"
        case .over:
            return "red"
        }
    }
    
    var description: String {
        switch self {
        case .under:
            return "Below recommended volume"
        case .optimal:
            return "Within recommended volume"
        case .over:
            return "Above recommended volume"
        }
    }
}