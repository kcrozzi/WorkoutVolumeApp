import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable, Codable {
    case quads = "Quads"
    case glutes = "Glutes"
    case hamstrings = "Hamstrings"
    case back = "Back"
    case chest = "Chest"
    case shoulders = "Shoulders"
    case triceps = "Triceps"
    case biceps = "Biceps"
    case abs = "Abs"
    case calves = "Calves"
    case trapsNeck = "Traps/Neck"
    case forearms = "Forearms"
    case lowerBack = "Lower Back"
    
    var id: String { rawValue }
    
    var recommendedVolumeRange: ClosedRange<Int> {
        switch self {
        case .quads: return 12...20
        case .glutes: return 10...20
        case .hamstrings: return 10...15
        case .back: return 15...20
        case .chest: return 10...20
        case .shoulders: return 12...20
        case .triceps: return 10...15
        case .biceps: return 10...15
        case .abs: return 8...15
        case .calves: return 15...20
        case .trapsNeck: return 10...15
        case .forearms: return 8...12
        case .lowerBack: return 6...10
        }
    }
    
    var recommendedFrequency: String {
        switch self {
        case .quads, .glutes, .back, .chest, .shoulders, .biceps, .trapsNeck, .forearms:
            return "2-3x per week"
        case .hamstrings, .triceps, .lowerBack:
            return "1-2x per week"
        case .abs, .calves:
            return "2-4x per week"
        }
    }
    
    var recommendedIntensity: String {
        switch self {
        case .quads, .glutes, .back, .chest, .triceps, .biceps, .trapsNeck, .forearms, .lowerBack:
            return "Moderate to high (RPE 7-9)"
        case .hamstrings, .calves:
            return "High (RPE 8-9)"
        case .shoulders:
            return "Varies (RPE 6-8 for lateral/rear, 8-9 for front)"
        case .abs:
            return "Moderate (RPE 6-8)"
        }
    }
}