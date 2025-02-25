import Foundation
import Combine
import SwiftUI
import UniformTypeIdentifiers

class WorkoutPlanViewModel: ObservableObject {
    @Published var workoutPlans: [WorkoutPlan] = []
    @Published var selectedPlan: WorkoutPlan?
    private let dataStore: DataStore
    private var cancellables = Set<AnyCancellable>()
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        
        // Bind to dataStore's workoutPlans
        dataStore.$workoutPlans
            .sink { [weak self] plans in
                self?.workoutPlans = plans
            }
            .store(in: &cancellables)
        
        // Bind to selectedPlan changes
        Publishers.CombineLatest(dataStore.$workoutPlans, dataStore.$selectedPlanId)
            .map { plans, selectedId -> WorkoutPlan? in
                guard let id = selectedId else { return nil }
                return plans.first { $0.id == id }
            }
            .sink { [weak self] plan in
                self?.selectedPlan = plan
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Plan Management
    
    func selectPlan(id: UUID) {
        dataStore.selectPlan(id: id)
    }
    
    func createNewPlan(name: String, userPreferences: UserPreferences) -> WorkoutPlan {
        return dataStore.createNewPlan(name: name, userPreferences: userPreferences)
    }
    
    func deletePlan(id: UUID) {
        dataStore.deletePlan(id: id)
    }
    
    // MARK: - Exercise Management
    
    func addExerciseToDay(dayId: UUID, exercise: Exercise, sets: Int) {
        guard let planId = selectedPlan?.id else { return }
        dataStore.addExerciseToDay(planId: planId, dayId: dayId, exercise: exercise, sets: sets)
    }
    
    func updateExerciseSets(dayId: UUID, exerciseId: UUID, sets: Int) {
        guard let planId = selectedPlan?.id else { return }
        dataStore.updateExerciseSets(planId: planId, dayId: dayId, exerciseId: exerciseId, sets: sets)
    }
    
    func removeExercise(dayId: UUID, exerciseId: UUID) {
        guard let planId = selectedPlan?.id else { return }
        dataStore.removeExercise(planId: planId, dayId: dayId, exerciseId: exerciseId)
    }
    
    // MARK: - Volume Calculation
    
    func weeklyVolumeData() -> [(muscleGroup: MuscleGroup, volume: Double, status: VolumeStatus)] {
        guard let plan = selectedPlan else { return [] }
        
        return MuscleGroup.allCases.map { muscleGroup in
            let volume = plan.totalWeeklyVolume(for: muscleGroup)
            let status = plan.volumeStatus(for: muscleGroup)
            return (muscleGroup: muscleGroup, volume: volume, status: status)
        }.sorted { $0.muscleGroup.rawValue < $1.muscleGroup.rawValue }
    }
    
    // MARK: - Export
    
    func exportPlanAsCSV() -> String {
        guard let plan = selectedPlan else { return "" }
        return dataStore.exportPlanAsCSV(plan: plan)
    }
    
    #if os(iOS)
    func exportCSV() -> URL? {
        guard let plan = selectedPlan else { return nil }
        
        let csvString = dataStore.exportPlanAsCSV(plan: plan)
        let fileName = "\(plan.name.replacingOccurrences(of: " ", with: "_")).csv"
        
        // Get the documents directory URL
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Write to the file
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing CSV to file: \(error)")
            return nil
        }
    }
    
    func generatePDFData() -> Data? {
        guard let plan = selectedPlan else { return nil }
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Workout Volume App",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: plan.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont
            ]
            let titleString = "Workout Plan: \(plan.name)"
            let titleStringSize = titleString.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: (pageWidth - titleStringSize.width) / 2.0,
                                  y: 36,
                                  width: titleStringSize.width,
                                  height: titleStringSize.height)
            titleString.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Add days and exercises
            let contentFont = UIFont.systemFont(ofSize: 12.0)
            let boldFont = UIFont.boldSystemFont(ofSize: 14.0)
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: contentFont
            ]
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: boldFont
            ]
            
            var yPosition: CGFloat = 72
            
            // Frequency
            let frequencyString = "Frequency: \(plan.userPreferences.frequency) days per week"
            let frequencyRect = CGRect(x: 72, y: yPosition, width: pageWidth - 144, height: 20)
            frequencyString.draw(in: frequencyRect, withAttributes: normalAttributes)
            yPosition += 30
            
            // Draw each day
            for day in plan.days {
                // Day title
                let dayTitleString = day.name
                let dayTitleRect = CGRect(x: 72, y: yPosition, width: pageWidth - 144, height: 20)
                dayTitleString.draw(in: dayTitleRect, withAttributes: headerAttributes)
                yPosition += 20
                
                // Draw header for exercises
                let exerciseHeaderString = "Exercise"
                let setsHeaderString = "Sets"
                let exerciseHeaderRect = CGRect(x: 72, y: yPosition, width: 200, height: 20)
                let setsHeaderRect = CGRect(x: 280, y: yPosition, width: 100, height: 20)
                exerciseHeaderString.draw(in: exerciseHeaderRect, withAttributes: headerAttributes)
                setsHeaderString.draw(in: setsHeaderRect, withAttributes: headerAttributes)
                yPosition += 20
                
                // Draw exercises
                for exercise in day.exercises {
                    let exerciseString = exercise.exercise.name
                    let setsString = "\(exercise.sets)"
                    
                    let exerciseRect = CGRect(x: 72, y: yPosition, width: 200, height: 20)
                    let setsRect = CGRect(x: 280, y: yPosition, width: 100, height: 20)
                    
                    exerciseString.draw(in: exerciseRect, withAttributes: normalAttributes)
                    setsString.draw(in: setsRect, withAttributes: normalAttributes)
                    
                    yPosition += 20
                    
                    // Check if we need a new page
                    if yPosition > pageHeight - 72 {
                        context.beginPage()
                        yPosition = 36
                    }
                }
                
                yPosition += 20
                
                // Check if we need a new page
                if yPosition > pageHeight - 72 {
                    context.beginPage()
                    yPosition = 36
                }
            }
            
            // Draw volume summary
            context.beginPage()
            
            let summaryTitleString = "Weekly Volume Summary"
            let summaryTitleRect = CGRect(x: (pageWidth - summaryTitleString.size(withAttributes: headerAttributes).width) / 2.0,
                                         y: 36,
                                         width: summaryTitleString.size(withAttributes: headerAttributes).width,
                                         height: 20)
            summaryTitleString.draw(in: summaryTitleRect, withAttributes: headerAttributes)
            
            yPosition = 72
            
            // Draw header for summary
            let muscleHeaderString = "Muscle Group"
            let volumeHeaderString = "Current Volume"
            let recommendedHeaderString = "Recommended Range"
            let statusHeaderString = "Status"
            
            let muscleHeaderRect = CGRect(x: 72, y: yPosition, width: 120, height: 20)
            let volumeHeaderRect = CGRect(x: 200, y: yPosition, width: 100, height: 20)
            let recommendedHeaderRect = CGRect(x: 310, y: yPosition, width: 120, height: 20)
            let statusHeaderRect = CGRect(x: 440, y: yPosition, width: 100, height: 20)
            
            muscleHeaderString.draw(in: muscleHeaderRect, withAttributes: headerAttributes)
            volumeHeaderString.draw(in: volumeHeaderRect, withAttributes: headerAttributes)
            recommendedHeaderString.draw(in: recommendedHeaderRect, withAttributes: headerAttributes)
            statusHeaderString.draw(in: statusHeaderRect, withAttributes: headerAttributes)
            
            yPosition += 20
            
            // Draw volume data
            for muscleGroup in MuscleGroup.allCases {
                let volume = plan.totalWeeklyVolume(for: muscleGroup)
                let range = muscleGroup.recommendedVolumeRange
                let status = plan.volumeStatus(for: muscleGroup)
                
                let statusColorAttributes: [NSAttributedString.Key: Any] = [
                    .font: contentFont,
                    .foregroundColor: status == .optimal ? UIColor.systemGreen : 
                                     status == .under ? UIColor.systemYellow : UIColor.systemRed
                ]
                
                let muscleString = muscleGroup.rawValue
                let volumeString = String(format: "%.1f", volume)
                let recommendedString = "\(range.lowerBound)-\(range.upperBound)"
                let statusString = status.description
                
                let muscleRect = CGRect(x: 72, y: yPosition, width: 120, height: 20)
                let volumeRect = CGRect(x: 200, y: yPosition, width: 100, height: 20)
                let recommendedRect = CGRect(x: 310, y: yPosition, width: 120, height: 20)
                let statusRect = CGRect(x: 440, y: yPosition, width: 150, height: 20)
                
                muscleString.draw(in: muscleRect, withAttributes: normalAttributes)
                volumeString.draw(in: volumeRect, withAttributes: normalAttributes)
                recommendedString.draw(in: recommendedRect, withAttributes: normalAttributes)
                statusString.draw(in: statusRect, withAttributes: statusColorAttributes)
                
                yPosition += 20
            }
        }
        
        return data
    }
    #endif
}