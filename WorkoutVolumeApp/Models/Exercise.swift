import Foundation

struct SecondaryMuscle: Codable, Hashable {
    let muscle: MuscleGroup
    let volumeFactor: Double
}

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let primaryMuscle: MuscleGroup
    let secondaryMuscles: [SecondaryMuscle]
    
    init(name: String, primaryMuscle: MuscleGroup, secondaryMuscles: [(muscle: MuscleGroup, volumeFactor: Double)] = []) {
        self.id = UUID()
        self.name = name
        self.primaryMuscle = primaryMuscle
        self.secondaryMuscles = secondaryMuscles.map { SecondaryMuscle(muscle: $0.muscle, volumeFactor: $0.volumeFactor) }
    }
    
    // Returns volume contribution for a given muscle group per set
    func volumeContribution(for muscleGroup: MuscleGroup) -> Double {
        if primaryMuscle == muscleGroup {
            return 1.0
        }
        
        if let secondary = secondaryMuscles.first(where: { $0.muscle == muscleGroup }) {
            return secondary.volumeFactor
        }
        
        return 0.0
    }
}

// Extension to provide static pre-defined exercises
extension Exercise {
    static let all: [Exercise] = quadsExercises + glutesExercises + hamstringsExercises +
                                backExercises + chestExercises + shouldersExercises +
                                tricepsExercises + bicepsExercises + absExercises +
                                calvesExercises + trapsNeckExercises + forearmsExercises +
                                lowerBackExercises
    
    static let quadsExercises: [Exercise] = [
        Exercise(name: "Back Squat", primaryMuscle: .quads, secondaryMuscles: [(.glutes, 0.5), (.lowerBack, 0.5)]),
        Exercise(name: "Front Squat", primaryMuscle: .quads, secondaryMuscles: [(.glutes, 0.5), (.lowerBack, 0.5)]),
        Exercise(name: "Leg Press", primaryMuscle: .quads, secondaryMuscles: [(.glutes, 0.5)]),
        Exercise(name: "Lunges", primaryMuscle: .quads, secondaryMuscles: [(.glutes, 0.5)]),
        Exercise(name: "Step-Ups", primaryMuscle: .quads, secondaryMuscles: [(.glutes, 0.5)]),
        Exercise(name: "Leg Extensions", primaryMuscle: .quads)
    ]
    
    static let glutesExercises: [Exercise] = [
        Exercise(name: "Hip Thrusts", primaryMuscle: .glutes, secondaryMuscles: [(.hamstrings, 0.5)]),
        Exercise(name: "Bulgarian Split Squat", primaryMuscle: .glutes, secondaryMuscles: [(.quads, 0.5)]),
        Exercise(name: "Glute Bridge", primaryMuscle: .glutes, secondaryMuscles: [(.hamstrings, 0.5)]),
        Exercise(name: "Sumo Deadlift", primaryMuscle: .glutes, secondaryMuscles: [(.hamstrings, 0.5), (.lowerBack, 0.5)])
    ]
    
    static let hamstringsExercises: [Exercise] = [
        Exercise(name: "Romanian Deadlift (RDL)", primaryMuscle: .hamstrings, secondaryMuscles: [(.glutes, 0.5), (.lowerBack, 0.5)]),
        Exercise(name: "Good Mornings", primaryMuscle: .hamstrings, secondaryMuscles: [(.lowerBack, 0.5), (.glutes, 0.5)]),
        Exercise(name: "Hamstring Curls (Lying/Seated)", primaryMuscle: .hamstrings),
        Exercise(name: "Nordic Curls", primaryMuscle: .hamstrings)
    ]
    
    static let backExercises: [Exercise] = [
        Exercise(name: "Pull-Ups/Chin-Ups", primaryMuscle: .back, secondaryMuscles: [(.biceps, 0.5)]),
        Exercise(name: "Barbell Rows", primaryMuscle: .back, secondaryMuscles: [(.biceps, 0.5), (.lowerBack, 0.5)]),
        Exercise(name: "Lat Pulldowns", primaryMuscle: .back, secondaryMuscles: [(.biceps, 0.5)]),
        Exercise(name: "Seated Cable Rows", primaryMuscle: .back, secondaryMuscles: [(.biceps, 0.5)]),
        Exercise(name: "Deadlifts", primaryMuscle: .back, secondaryMuscles: [(.glutes, 0.5), (.hamstrings, 0.5), (.lowerBack, 0.5)])
    ]
    
    static let chestExercises: [Exercise] = [
        Exercise(name: "Flat Bench Press", primaryMuscle: .chest, secondaryMuscles: [(.triceps, 0.5), (.shoulders, 0.5)]),
        Exercise(name: "Incline Bench Press", primaryMuscle: .chest, secondaryMuscles: [(.shoulders, 0.5), (.triceps, 0.5)]),
        Exercise(name: "Decline Bench Press", primaryMuscle: .chest, secondaryMuscles: [(.triceps, 0.5)]),
        Exercise(name: "Dumbbell Flyes", primaryMuscle: .chest),
        Exercise(name: "Cable Crossovers", primaryMuscle: .chest),
        Exercise(name: "Push-Ups", primaryMuscle: .chest, secondaryMuscles: [(.triceps, 0.5), (.shoulders, 0.5)])
    ]
    
    static let shouldersExercises: [Exercise] = [
        Exercise(name: "Overhead Press (Barbell)", primaryMuscle: .shoulders, secondaryMuscles: [(.triceps, 0.5)]),
        Exercise(name: "Dumbbell Shoulder Press", primaryMuscle: .shoulders, secondaryMuscles: [(.triceps, 0.5)]),
        Exercise(name: "Lateral Raises", primaryMuscle: .shoulders),
        Exercise(name: "Front Raises", primaryMuscle: .shoulders),
        Exercise(name: "Rear Delt Flyes", primaryMuscle: .shoulders, secondaryMuscles: [(.back, 0.5)]),
        Exercise(name: "Arnold Press", primaryMuscle: .shoulders, secondaryMuscles: [(.triceps, 0.5)])
    ]
    
    static let tricepsExercises: [Exercise] = [
        Exercise(name: "Close-Grip Bench Press", primaryMuscle: .triceps, secondaryMuscles: [(.chest, 0.5)]),
        Exercise(name: "Overhead Triceps Extension", primaryMuscle: .triceps),
        Exercise(name: "Skull Crushers", primaryMuscle: .triceps),
        Exercise(name: "Dips (Chest Variation)", primaryMuscle: .triceps, secondaryMuscles: [(.chest, 0.5)]),
        Exercise(name: "Cable Tricep Pushdowns", primaryMuscle: .triceps)
    ]
    
    static let bicepsExercises: [Exercise] = [
        Exercise(name: "Barbell Curls", primaryMuscle: .biceps),
        Exercise(name: "Dumbbell Curls", primaryMuscle: .biceps),
        Exercise(name: "Hammer Curls", primaryMuscle: .biceps, secondaryMuscles: [(.forearms, 0.5)]),
        Exercise(name: "Preacher Curls", primaryMuscle: .biceps)
    ]
    
    static let absExercises: [Exercise] = [
        Exercise(name: "Crunches", primaryMuscle: .abs),
        Exercise(name: "Plank", primaryMuscle: .abs, secondaryMuscles: [(.lowerBack, 0.5)]),
        Exercise(name: "Hanging Leg Raises", primaryMuscle: .abs),
        Exercise(name: "Cable Crunches", primaryMuscle: .abs)
    ]
    
    static let calvesExercises: [Exercise] = [
        Exercise(name: "Standing Calf Raise", primaryMuscle: .calves),
        Exercise(name: "Seated Calf Raise", primaryMuscle: .calves),
        Exercise(name: "Donkey Calf Raise", primaryMuscle: .calves)
    ]
    
    static let trapsNeckExercises: [Exercise] = [
        Exercise(name: "Barbell Shrugs", primaryMuscle: .trapsNeck),
        Exercise(name: "Dumbbell Shrugs", primaryMuscle: .trapsNeck),
        Exercise(name: "Face Pulls", primaryMuscle: .trapsNeck, secondaryMuscles: [(.shoulders, 0.5)]),
        Exercise(name: "Rack Pulls", primaryMuscle: .trapsNeck, secondaryMuscles: [(.lowerBack, 0.5), (.glutes, 0.5)])
    ]
    
    static let forearmsExercises: [Exercise] = [
        Exercise(name: "Wrist Curls", primaryMuscle: .forearms),
        Exercise(name: "Reverse Curls", primaryMuscle: .forearms, secondaryMuscles: [(.biceps, 0.5)]),
        Exercise(name: "Farmer's Walks", primaryMuscle: .forearms, secondaryMuscles: [(.trapsNeck, 0.5)])
    ]
    
    static let lowerBackExercises: [Exercise] = [
        Exercise(name: "Deadlifts", primaryMuscle: .lowerBack, secondaryMuscles: [(.glutes, 0.5), (.hamstrings, 0.5)]),
        Exercise(name: "Hyperextensions", primaryMuscle: .lowerBack, secondaryMuscles: [(.glutes, 0.5), (.hamstrings, 0.5)]),
        Exercise(name: "Good Mornings", primaryMuscle: .lowerBack, secondaryMuscles: [(.hamstrings, 0.5), (.glutes, 0.5)])
    ]
}
