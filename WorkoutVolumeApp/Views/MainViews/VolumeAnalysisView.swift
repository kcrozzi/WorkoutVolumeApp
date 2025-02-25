import SwiftUI
import Charts

struct VolumeAnalysisView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if let plan = viewModel.selectedPlan {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Volume chart
                            VStack(alignment: .leading) {
                                Text("Weekly Volume Per Muscle Group")
                                    .font(.headline)
                                    .padding(.bottom, 4)
                                
                                VolumeBarChart(viewModel: viewModel)
                                    .frame(height: 300)
                                    .padding(.bottom)
                            }
                            .padding(.horizontal)
                            
                            // Volume breakdown table
                            VStack(alignment: .leading) {
                                Text("Volume Breakdown")
                                    .font(.headline)
                                    .padding(.bottom, 4)
                                
                                VolumeBreakdownList(viewModel: viewModel)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .navigationTitle("\(plan.name) Analysis")
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
                    .navigationTitle("Volume Analysis")
                }
            }
        }
    }
}

struct VolumeBarChart: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        Chart {
            ForEach(viewModel.weeklyVolumeData(), id: \.muscleGroup.id) { data in
                BarMark(
                    x: .value("Muscle Group", data.muscleGroup.rawValue),
                    y: .value("Volume", data.volume)
                )
                .foregroundStyle(barColor(for: data.status))
                .annotation(position: .top) {
                    Text("\(Int(data.volume))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ForEach(viewModel.weeklyVolumeData(), id: \.muscleGroup.id) { data in
                let lowerBound = Double(data.muscleGroup.recommendedVolumeRange.lowerBound)
                
                RuleMark(y: .value("Min", lowerBound))
                    .foregroundStyle(Color.yellow)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .leading) {
                        Text("\(Int(lowerBound))")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
            }
            
            ForEach(viewModel.weeklyVolumeData(), id: \.muscleGroup.id) { data in
                let upperBound = Double(data.muscleGroup.recommendedVolumeRange.upperBound)
                
                RuleMark(y: .value("Max", upperBound))
                    .foregroundStyle(Color.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .trailing) {
                        Text("\(Int(upperBound))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned) {
                AxisValueLabel()
                    .font(.caption)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
    
    private func barColor(for status: VolumeStatus) -> Color {
        switch status {
        case .under:
            return Color.yellow
        case .optimal:
            return Color.green
        case .over:
            return Color.red
        }
    }
}

struct VolumeBreakdownList: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Text("Muscle Group")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: 120, alignment: .leading)
                
                Text("Current")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: 60, alignment: .center)
                
                Text("Target Range")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: 100, alignment: .center)
                
                Text("Status")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Data rows
            ForEach(viewModel.weeklyVolumeData(), id: \.muscleGroup.id) { data in
                VolumeBreakdownRow(
                    muscleGroup: data.muscleGroup.rawValue,
                    currentVolume: data.volume,
                    targetRange: "\(data.muscleGroup.recommendedVolumeRange.lowerBound)-\(data.muscleGroup.recommendedVolumeRange.upperBound)",
                    status: data.status
                )
            }
        }
    }
}

struct VolumeBreakdownRow: View {
    let muscleGroup: String
    let currentVolume: Double
    let targetRange: String
    let status: VolumeStatus
    
    var body: some View {
        HStack {
            Text(muscleGroup)
                .font(.subheadline)
                .frame(width: 120, alignment: .leading)
            
            Text(String(format: "%.1f", currentVolume))
                .font(.subheadline)
                .frame(width: 60, alignment: .center)
            
            Text(targetRange)
                .font(.subheadline)
                .frame(width: 100, alignment: .center)
            
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                
                Text(status.description)
                    .font(.subheadline)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .under:
            return Color.yellow
        case .optimal:
            return Color.green
        case .over:
            return Color.red
        }
    }
}