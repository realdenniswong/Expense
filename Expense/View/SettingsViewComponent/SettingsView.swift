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
                    NavigationLink(destination: DailyGoalsSettingsView(settings: settings)) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
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
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
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
                            Image(systemName: "calendar")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
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
                
                // MARK: - Notifications Section
                Section {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Budget Alerts")
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.enableNotifications)
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
}
