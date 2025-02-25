import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataStore: DataStore
    @State private var showingPreferencesSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("User Information")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(dataStore.userPreferences.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(dataStore.userPreferences.email)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Edit User Information") {
                        showingPreferencesSheet = true
                    }
                }
                
                Section(header: Text("Training Preferences")) {
                    HStack {
                        Text("Preferred Training Days")
                        Spacer()
                        Text("\(dataStore.userPreferences.frequency) days/week")
                            .foregroundColor(.secondary)
                    }
                    
                    if !dataStore.userPreferences.weakPoints.isEmpty {
                        NavigationLink(destination: ListMuscleGroupsView(title: "Weak Points", muscleGroups: dataStore.userPreferences.weakPoints)) {
                            Text("Weak Points")
                        }
                    }
                    
                    if !dataStore.userPreferences.lesserPriority.isEmpty {
                        NavigationLink(destination: ListMuscleGroupsView(title: "Lesser Priority", muscleGroups: dataStore.userPreferences.lesserPriority)) {
                            Text("Lesser Priority Areas")
                        }
                    }
                    
                    if !dataStore.userPreferences.cannotTrain.isEmpty {
                        NavigationLink(destination: ListMuscleGroupsView(title: "Cannot Train", muscleGroups: dataStore.userPreferences.cannotTrain)) {
                            Text("Cannot Train")
                        }
                    }
                    
                    HStack {
                        Text("Preferred Volume")
                        Spacer()
                        Text("\(dataStore.userPreferences.preferredVolume)/100")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Preferred Intensity")
                        Spacer()
                        Text("\(dataStore.userPreferences.preferredIntensity)/100")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Edit Training Preferences") {
                        showingPreferencesSheet = true
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0 (Beta)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPreferencesSheet) {
                EditPreferencesSheet(dataStore: dataStore, isPresented: $showingPreferencesSheet)
            }
        }
    }
}

struct ListMuscleGroupsView: View {
    let title: String
    let muscleGroups: [MuscleGroup]
    
    var body: some View {
        List {
            ForEach(muscleGroups) { muscleGroup in
                Text(muscleGroup.rawValue)
            }
        }
        .navigationTitle(title)
    }
}

struct EditPreferencesSheet: View {
    @ObservedObject var dataStore: DataStore
    @Binding var isPresented: Bool
    
    // User info
    @State private var name: String = ""
    @State private var email: String = ""
    
    // Training preferences
    @State private var frequency: Int = 4
    @State private var weakPoints: [MuscleGroup] = []
    @State private var lesserPriority: [MuscleGroup] = []
    @State private var cannotTrain: [MuscleGroup] = []
    @State private var preferredVolume: Double = 50
    @State private var preferredIntensity: Double = 50
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Training Preferences")) {
                    Picker("Days per week", selection: $frequency) {
                        ForEach(1...7, id: \.self) { days in
                            Text("\(days) days").tag(days)
                        }
                    }
                    
                    NavigationLink(destination: MuscleGroupSelectionList(title: "Weak Points", selectedGroups: $weakPoints)) {
                        Text("Weak Points")
                    }
                    
                    NavigationLink(destination: MuscleGroupSelectionList(title: "Lesser Priority", selectedGroups: $lesserPriority)) {
                        Text("Lesser Priority Areas")
                    }
                    
                    NavigationLink(destination: MuscleGroupSelectionList(title: "Cannot Train", selectedGroups: $cannotTrain)) {
                        Text("Cannot Train")
                    }
                    
                    VStack {
                        Text("Preferred Volume: \(Int(preferredVolume))")
                        Slider(value: $preferredVolume, in: 1...100, step: 1)
                    }
                    
                    VStack {
                        Text("Preferred Intensity: \(Int(preferredIntensity))")
                        Slider(value: $preferredIntensity, in: 1...100, step: 1)
                    }
                }
            }
            .navigationTitle("Edit Preferences")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    savePreferences()
                    isPresented = false
                }
            )
            .onAppear {
                loadPreferences()
            }
        }
    }
    
    private func loadPreferences() {
        let preferences = dataStore.userPreferences
        name = preferences.name
        email = preferences.email
        frequency = preferences.frequency
        weakPoints = preferences.weakPoints
        lesserPriority = preferences.lesserPriority
        cannotTrain = preferences.cannotTrain
        preferredVolume = Double(preferences.preferredVolume)
        preferredIntensity = Double(preferences.preferredIntensity)
    }
    
    private func savePreferences() {
        var updatedPreferences = dataStore.userPreferences
        updatedPreferences.name = name
        updatedPreferences.email = email
        updatedPreferences.frequency = frequency
        updatedPreferences.weakPoints = weakPoints
        updatedPreferences.lesserPriority = lesserPriority
        updatedPreferences.cannotTrain = cannotTrain
        updatedPreferences.preferredVolume = Int(preferredVolume)
        updatedPreferences.preferredIntensity = Int(preferredIntensity)
        
        dataStore.updateUserPreferences(updatedPreferences)
    }
}

struct MuscleGroupSelectionList: View {
    let title: String
    @Binding var selectedGroups: [MuscleGroup]
    
    var body: some View {
        List {
            ForEach(MuscleGroup.allCases) { muscleGroup in
                Button(action: {
                    toggleMuscleGroup(muscleGroup)
                }) {
                    HStack {
                        Text(muscleGroup.rawValue)
                        Spacer()
                        if selectedGroups.contains(muscleGroup) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
    }
    
    private func toggleMuscleGroup(_ muscleGroup: MuscleGroup) {
        if selectedGroups.contains(muscleGroup) {
            selectedGroups.removeAll { $0 == muscleGroup }
        } else {
            selectedGroups.append(muscleGroup)
        }
    }
}