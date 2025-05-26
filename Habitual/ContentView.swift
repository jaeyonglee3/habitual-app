import SwiftUI

struct WelcomeScreen: View {
    var body: some View {
        ZStack {
            Color(red: 17/255, green: 74/255, blue: 18/255) // Set background color
                .ignoresSafeArea()

            Text("Welcome to Habitual!")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

struct Habit: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var dailyGoal: Int
    var dailyCompletionCount: Int = 0
    var weeklyProgress: [Bool] = Array(repeating: false, count: 7) // Array to track weekly progress
}

class HabitData: ObservableObject {
    @Published var habits: [Habit] = [
        // Sample habits for initial testing
        Habit(name: "Drink Water", description: "8 glasses a day", dailyGoal: 8),
        Habit(name: "Exercise", description: "30 minutes workout", dailyGoal: 1)
    ]
}

struct ContentView: View {
    @State private var showWelcomeScreen = true
    @ObservedObject var habitData = HabitData()
    
    var body: some View {
        ZStack { // Use ZStack to overlay the welcome screen
            NavigationView {
                List {
                    ForEach(habitData.habits.indices, id: \.self) { index in
                        NavigationLink(destination: HabitView(habit: $habitData.habits[index])) {
                            HabitRow(habit: $habitData.habits[index]) // Pass the binding here
                        }
                    }
                }
                .navigationTitle("Habitual")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddHabitView(habits: $habitData.habits)) {
                            Image(systemName: "plus")
                                .foregroundColor(Color(red: 17/255, green: 74/255, blue: 18/255)) // Set color
                                .font(.system(size: 22)) // Adjust size as needed
                        }
                    }
                }
            }
            .environmentObject(habitData)

            if showWelcomeScreen {
                WelcomeScreen().transition(.opacity)  // Your custom welcome screen view
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Delay for 2 seconds
                showWelcomeScreen = false
            }
        }
       
    }
}

// Placeholder views for now
struct HabitRow: View {
    @Binding var habit: Habit

    var body: some View {
        VStack(alignment: .leading) { // Changed to VStack
            Text(habit.name)
                .font(.title)
                .foregroundColor(Color(red: 17/255, green: 74/255, blue: 18/255))
            Text(habit.description)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true) // Allow description to wrap
            HStack {
                ProgressView(value: Float(habit.dailyCompletionCount), total: Float(habit.dailyGoal))
                    .accentColor(Color(red: 17/255, green: 74/255, blue: 18/255)) // Set accent color
                    .frame(width: 250)
            }

            HStack {
                ForEach(0..<7) { dayIndex in
                    ZStack {
                        Button(action: {
                            habit.weeklyProgress[dayIndex].toggle()
                        }) {
                            Image(systemName: habit.weeklyProgress[dayIndex] ? "checkmark.square.fill" : "square")
                                .font(.system(size: 27)) // Increase the font size of the image
                        }
                        Text(Calendar.current.shortWeekdaySymbols[dayIndex].prefix(1))
                            .font(.caption2)
                            .foregroundColor(habit.weeklyProgress[dayIndex] ? .white : .black)
                    }
                }
            }
            .padding(.top, 8) // Add some space above the checkboxes
        }
        .foregroundColor(habit.isCompletedForToday ? .green : .primary)
        .frame(minHeight: 80) // Set a minimum height for the row
        .padding(.vertical, 4) // Add vertical padding to the row
    }
}

extension Habit {
    var isCompletedForToday: Bool {
        let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        return weeklyProgress[todayIndex]
    }
}

struct HabitView: View {
    @Binding var habit: Habit
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var habitData: HabitData
    
    var body: some View {
        VStack {
            Text(habit.name)
                .font(.title)
            Text(habit.description)
                .font(.subheadline)
                .padding(.bottom, 8)
            Text("Daily Repitition Goal: \(habit.dailyGoal)")
                .font(.headline)
                .foregroundColor(Color(red: 36/255, green: 157/255, blue: 38/255))
            HStack {
                ProgressView(value: Float(habit.dailyCompletionCount), total: Float(habit.dailyGoal))
                    .accentColor(Color(red: 17/255, green: 74/255, blue: 18/255))
                    .frame(width: 250)
                Text("\(habit.dailyCompletionCount)/\(habit.dailyGoal)")
            }
            .padding(.bottom)

            HStack {
                ForEach(0..<7) { dayIndex in
                    Text(Calendar.current.shortWeekdaySymbols[dayIndex]) // Display day of the week abbreviation
                        .frame(maxWidth: .infinity) // Equal spacing for day abbreviations
                }
            }
            HStack {
                ForEach(0..<7) { dayIndex in
                    Button(action: {
                        habit.weeklyProgress[dayIndex].toggle()
                    }) {
                        Image(systemName: habit.weeklyProgress[dayIndex] ? "checkmark.square.fill" : "square")
                    }
                    .frame(maxWidth: .infinity) // Equal spacing for checkboxes
                }
            }
            Spacer()
            
            HStack { // "Mark as Done" and "Edit"
                Button(action: {
                    let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
                    if habit.weeklyProgress[todayIndex] {
                        // If already marked as done, do nothing or you can add logic to undo
                    } else {
                        habit.dailyCompletionCount = habit.dailyGoal
                        habit.weeklyProgress[todayIndex] = true
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(red: 17/255, green: 74/255, blue: 18/255))
                        Text("Mark as Done for Today")
                            .foregroundColor(Color(red: 27/255, green: 115/255, blue: 28/255))
                    }
                }
                .buttonStyle(.bordered) // Add button style
                .padding(.trailing) // Add some space between buttons

                NavigationLink(destination: EditHabitView(habit: $habit)) {
                    HStack {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(red: 17/255, green: 74/255, blue: 18/255))
                        Text("Edit Habit")
                            .foregroundColor(Color(red: 27/255, green: 115/255, blue: 28/255))
                    }
                }
                .buttonStyle(.bordered) // Add button style
            }
            .padding(.bottom) // Add space below the HStack

            HStack { // "Completed Once" and "Reset"
                Button(action: {
                    habit.dailyCompletionCount += 1
                    if habit.dailyCompletionCount >= habit.dailyGoal {
                        let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
                        habit.weeklyProgress[todayIndex] = true
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(red: 17/255, green: 74/255, blue: 18/255))
                        Text("Completed Once")
                            .foregroundColor(Color(red: 27/255, green: 115/255, blue: 28/255))
                    }
                }
                .buttonStyle(.bordered) // Add button style
                .padding(.trailing) // Add some space between buttons

                Button(action: {
                    let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
                    habit.dailyCompletionCount = 0
                    habit.weeklyProgress[todayIndex] = false
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(red: 17/255, green: 74/255, blue: 18/255))
                        Text("Reset Daily Progress")
                            .foregroundColor(Color(red: 27/255, green: 115/255, blue: 28/255))
                    }
                }
                .buttonStyle(.bordered) // Add button style
            }

            // "Delete Habit" button
            Button(action: {
                if let index = habitData.habits.firstIndex(where: { $0.id == habit.id }) {
                    habitData.habits.remove(at: index)
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.red) // Make the icon red
                    Text("Delete Habit")
                        .foregroundColor(.red) // Make the text red
                }
            }
            .padding(.top)
        }
        .padding()
        .padding(.bottom, 260)
    }
}

struct AddHabitView: View {
    @Binding var habits: [Habit] // Binding to update the habits array in ContentView
    @Environment(\.presentationMode) var presentationMode

    @State private var habitName: String = ""
    @State private var habitDescription: String = ""
    @State private var dailyGoal: Int = 1 // Default daily goal

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Name", text: $habitName)
                    TextField("Description", text: $habitDescription)
                    Stepper("Daily Goal: \(dailyGoal)", value: $dailyGoal, in: 1...100)
                }

                Button(action: {
                    let newHabit = Habit(name: habitName, description: habitDescription, dailyGoal: dailyGoal)
                    habits.append(newHabit)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                }
            }
            .navigationTitle("New Habit")
        }
    }
}

struct EditHabitView: View {
    @Binding var habit: Habit
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var habitName: String
    @State private var habitDescription: String
    @State private var dailyGoal: Int // Add this line

    init(habit: Binding<Habit>) {
        self._habit = habit
        self._habitName = State(initialValue: habit.wrappedValue.name)
        self._habitDescription = State(initialValue: habit.wrappedValue.description)
        self._dailyGoal = State(initialValue: habit.wrappedValue.dailyGoal) // Add this line
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Name", text: $habitName)
                    TextField("Description", text: $habitDescription)
                    Stepper("Daily Goal: \(dailyGoal)", value: $dailyGoal, in: 1...100) // Add this line
                }

                Button(action: {
                    habit.name = habitName
                    habit.description = habitDescription
                    habit.dailyGoal = dailyGoal // Add this line
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Changes")
                }
            }
            .navigationTitle("Edit Habit")
        }
    }
}

#Preview {
    ContentView()
}
