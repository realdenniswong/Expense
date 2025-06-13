//
//  SettingsView.swift
//  Expense
//
//  Created by Dennis Wong on 13/6/2025.
//

import SwiftUI

struct SettingsView: View {
    // Spending Goal toggles for each period
    @State private var showDailyGoals = true
    @State private var showWeeklyGoals = true
    @State private var showMonthlyGoals = true
    
    // Spending Goal category toggles for each period
    @State private var dailyGoalCategories: [ExpenseCategory: Bool] = [
        .foodDrink: true,
        .transportation: true,
        .shopping: false,
        .entertainment: true,
        .billsUtilities: false,
        .healthcare: false,
        .other: false
    ]
    
    @State private var weeklyGoalCategories: [ExpenseCategory: Bool] = [
        .foodDrink: true,
        .transportation: true,
        .shopping: true,
        .entertainment: true,
        .billsUtilities: false,
        .healthcare: true,
        .other: false
    ]
    
    @State private var monthlyGoalCategories: [ExpenseCategory: Bool] = [
        .foodDrink: true,
        .transportation: true,
        .shopping: true,
        .entertainment: true,
        .billsUtilities: true,
        .healthcare: true,
        .other: true
    ]
    
    // Other settings
    @State private var enableNotifications = true
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Spending Goals Section
                Section {
                    NavigationLink(destination: DailyGoalsSettingsView(
                        showDailyGoals: $showDailyGoals,
                        dailyGoalCategories: $dailyGoalCategories
                    )) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Daily Goals")
                            
                            Spacer()
                            
                            if showDailyGoals {
                                Text("\(enabledCategoriesCount(dailyGoalCategories)) categories")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Off")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: WeeklyGoalsSettingsView(
                        showWeeklyGoals: $showWeeklyGoals,
                        weeklyGoalCategories: $weeklyGoalCategories
                    )) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text("Weekly Goals")
                            
                            Spacer()
                            
                            if showWeeklyGoals {
                                Text("\(enabledCategoriesCount(weeklyGoalCategories)) categories")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Off")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: MonthlyGoalsSettingsView(
                        showMonthlyGoals: $showMonthlyGoals,
                        monthlyGoalCategories: $monthlyGoalCategories
                    )) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Monthly Goals")
                            
                            Spacer()
                            
                            if showMonthlyGoals {
                                Text("\(enabledCategoriesCount(monthlyGoalCategories)) categories")
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
                
                // MARK: - Notifications Section
                Section {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Budget Alerts")
                        
                        Spacer()
                        
                        Toggle("", isOn: $enableNotifications)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get notified when you're approaching or exceeding your spending goals.")
                }
                
                // MARK: - About Section
                Section {
                    HStack {
                        Text("Version")
                        
                        Spacer()
                        
                        Text("1.0.0")
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
    
    private func enabledCategoriesCount(_ categories: [ExpenseCategory: Bool]) -> Int {
        categories.values.filter { $0 }.count
    }
}
