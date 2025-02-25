import Foundation

struct WorkoutDay: Identifiable, Codable {
    let id: UUID
    var name: String
    var exercises: [WorkoutExercise]
    
    init(name: String, exercises: [WorkoutExercise] = []) {
        self.id = UUID()
        self.name = name
        self.exercises = exercises
    }
    
    // Calculate total volume contribution for a specific muscle group
    func totalVolume(for muscleGroup: MuscleGroup) -> Double {
        exercises.reduce(0) { result, exercise in
            let exerciseContribution = exercise.exercise.volumeContribution(for: muscleGroup) * Double(exercise.sets)
            return result + exerciseContribution
        }
    }
}

struct WorkoutExercise: Identifiable, Codable, Hashable {
    let id: UUID
    let exercise: Exercise
    var sets: Int
    
    init(exercise: Exercise, sets: Int = 3) {
        self.id = UUID()
        self.exercise = exercise
        self.sets = sets
    }
    
    // Custom equality for Hashable
    static func == (lhs: WorkoutExercise, rhs: WorkoutExercise) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Custom hash for Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}