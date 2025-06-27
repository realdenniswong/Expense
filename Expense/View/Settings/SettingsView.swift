//
//  SettingsView.swift
//  Expense
//
//  Created by Dennis Wong on 13/6/2025.
//

import SwiftUI

struct SettingsView: View {
    @Bindable var settings: Settings
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Spending Goals Section
                Section {
                    NavigationLink(destination: SpendingLimitView(settings: settings)) {
                        HStack {
                            Text("Goal Amounts")
                            
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: DailyGoalsSettingsView(settings: settings)) {
                        HStack {
                            Text("Daily Goals")
                            
                            Spacer()
                            
                            if settings.showDailyGoals {
                                Text("\(settings.enabledCategoriesCount(for: .daily)) categories")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Off")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: WeeklyGoalsSettingsView(settings: settings)) {
                        HStack {
                            Text("Weekly Goals")
                            
                            Spacer()
                            
                            if settings.showWeeklyGoals {
                                Text("\(settings.enabledCategoriesCount(for: .weekly)) categories")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Off")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: MonthlyGoalsSettingsView(settings: settings)) {
                        HStack {
                            Text("Monthly Goals")
                            
                            Spacer()
                            
                            if settings.showMonthlyGoals {
                                Text("\(settings.enabledCategoriesCount(for: .monthly)) categories")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Off")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Spending Goals")
                } footer: {
                    Text("Configure which spending goals to display for each time period.")
                }
                
                // MARK: - Summary Start Settings Section
                Section {
                    NavigationLink {
                        DailyStartHourPicker(selection: $settings.dailyStartHour)
                    } label: {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Daily summary starts at")
                                Text(String(format: "%02d:00", settings.dailyStartHour))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink {
                        WeeklyStartDayPicker(selection: $settings.weeklyStartDay)
                    } label: {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Weekly summary starts on")
                                Text(weekdayName(for: settings.weeklyStartDay))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink {
                        MonthlyStartDayPicker(selection: $settings.monthlyStartDay)
                    } label: {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Monthly summary starts on")
                                Text(monthlyStartDayDescription(for: settings.monthlyStartDay))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                } header: {
                    Text("Daily summary starts at")
                } footer: {
                    Text("Customize the start of your day, week, and month for summaries.")
                }
                
                // MARK: - Data Section
                Section {
                    NavigationLink(destination: DataExportView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Export Data")
                            
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: DataImportView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Import Data")
                            
                            Spacer()
                        }
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("Export your expense data for backup or import data from other sources.")
                }
                
                // MARK: - About Section
                Section {
                    HStack {
                        Text("Version")
                        
                        Spacer()
                        
                        Text("2.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                } header: {
                    Text("About")
                } footer: {
                    Text("Made by Dennis Wong")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func weekdayName(for day: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.weekdaySymbols[day % 7]
    }
    
    private func monthlyStartDayDescription(for day: Int) -> String {
        func ordinalSuffix(_ number: Int) -> String {
            let ones = number % 10
            let tens = (number / 10) % 10
            
            if tens == 1 {
                return "th"
            }
            
            switch ones {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
        
        return "\(day)\(ordinalSuffix(day)) day of the month"
    }
    
    private struct WeeklyStartDayPicker: View {
        @Binding var selection: Int
        
        var body: some View {
            Form {
                Picker("Start day for weekly summary", selection: $selection) {
                    ForEach(0..<7, id: \.self) { day in
                        Text(weekdayName(for: day)).tag(day)
                    }
                }
                .pickerStyle(.inline)
            }
            .navigationTitle("Start Day for Week")
        }
        
        private func weekdayName(for day: Int) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            return formatter.weekdaySymbols[day % 7]
        }
    }
    
    private struct MonthlyStartDayPicker: View {
        @Binding var selection: Int
        
        var body: some View {
            Form {
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(1...31, id: \.self) { day in
                            Button(action: { selection = day }) {
                                Text("\(day)")
                                    .frame(width: 44, height: 44)
                                    .background(selection == day ? Color.accentColor : Color.clear)
                                    .foregroundColor(selection == day ? .white : .primary)
                                    .clipShape(Circle())
                                    .font(selection == day ? .headline.bold() : .body)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    // .padding(.vertical)
                } header: {
                    Text("Tap to choose the day your monthly summary starts.")
                } footer: {
                    Text("If the selected day doesn't exist in a month, the last day of that month will be used.")
                }
            }
            .navigationTitle("Start Day for Month")
        }
    }
    
    private struct DailyStartHourPicker: View {
        @Binding var selection: Int
        @State private var tempDate: Date
        
        init(selection: Binding<Int>) {
            _selection = selection
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = selection.wrappedValue
            components.minute = 0
            _tempDate = State(initialValue: calendar.date(from: components) ?? Date())
        }
        
        var body: some View {
            Form {
                Section {
                    DatePicker("Start hour for daily summary", selection: $tempDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .onChange(of: tempDate) { newDate in
                            selection = Calendar.current.component(.hour, from: newDate)
                        }
                } header: {
                    Text("Set when your 'day' starts for daily summaries.")
                }
            }
            .navigationTitle("Start Hour")
            .onAppear {
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day], from: Date())
                components.hour = selection
                components.minute = 0
                tempDate = calendar.date(from: components) ?? Date()
            }
        }
    }
}

