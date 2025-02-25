import SwiftUI
import UniformTypeIdentifiers

struct ExportView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @State private var exportType: ExportType = .csv
    
    enum ExportType {
        case csv
        case pdf
        
        var fileExtension: String {
            switch self {
            case .csv: return "csv"
            case .pdf: return "pdf"
            }
        }
        
        var iconName: String {
            switch self {
            case .csv: return "doc.text"
            case .pdf: return "doc.richtext"
            }
        }
        
        var description: String {
            switch self {
            case .csv: return "CSV (Spreadsheet)"
            case .pdf: return "PDF (Document)"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if let plan = viewModel.selectedPlan {
                    VStack(spacing: 20) {
                        Text("Export your workout plan to share or print")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                        
                        Spacer()
                        
                        // Export type selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Export Format")
                                .font(.headline)
                            
                            ForEach([ExportType.csv, ExportType.pdf], id: \.self) { type in
                                Button(action: {
                                    exportType = type
                                }) {
                                    HStack {
                                        Image(systemName: type.iconName)
                                            .foregroundColor(.blue)
                                            .frame(width: 30)
                                        
                                        VStack(alignment: .leading) {
                                            Text(type.description)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                            
                                            Text("Export as .\(type.fileExtension) file")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if exportType == type {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Preview of export
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Export Preview")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Plan:")
                                        .fontWeight(.bold)
                                    Text(plan.name)
                                }
                                
                                HStack {
                                    Text("Days:")
                                        .fontWeight(.bold)
                                    Text("\(plan.days.count)")
                                }
                                
                                HStack {
                                    Text("Exercises:")
                                        .fontWeight(.bold)
                                    Text("\(totalExerciseCount(in: plan))")
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Export button
                        Button(action: {
                            exportPlan()
                        }) {
                            Text("Export Workout Plan")
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
                    .navigationTitle("Export Plan")
                    .sheet(isPresented: $showingShareSheet) {
                        if let url = exportURL {
                            ShareSheet(activityItems: [url])
                        }
                    }
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
                    .navigationTitle("Export Plan")
                }
            }
        }
    }
    
    private func totalExerciseCount(in plan: WorkoutPlan) -> Int {
        plan.days.reduce(0) { count, day in
            count + day.exercises.count
        }
    }
    
    private func exportPlan() {
        switch exportType {
        case .csv:
            if let url = viewModel.exportCSV() {
                exportURL = url
                showingShareSheet = true
            }
        case .pdf:
            if let pdfData = viewModel.generatePDFData() {
                // Save PDF to a temporary file
                let fileName = "\(viewModel.selectedPlan?.name ?? "Workout_Plan").pdf"
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                
                do {
                    try pdfData.write(to: url)
                    exportURL = url
                    showingShareSheet = true
                } catch {
                    print("Error saving PDF: \(error)")
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}