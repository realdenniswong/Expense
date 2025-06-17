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
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Goal Amounts")
                            
                            Spacer()
                        }
                    }
                    
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
}
