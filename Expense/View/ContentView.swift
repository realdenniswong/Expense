//
//  ContentView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var selectedTab = 0
    @Query private var settingsArray: [Settings]
    @Environment(\.modelContext) private var modelContext
    
    // Get the single settings object, or create one if none exists
    private var settings: Settings {
        if let existingSettings = settingsArray.first {
            return existingSettings
        } else {
            // Create the single settings object with fixed ID
            let newSettings = Settings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                VStack {
                    ExpenseView(expenses: expenses)
                }
                .navigationTitle("Expense")
                .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: "banknote")
                Text("Expense")
            }
            .tag(0)
            
            // Browse Tab
            NavigationStack {
                VStack {
                    OverviewView(expenses: expenses, settings: settings)
                }
                .navigationTitle("Overview")
                .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: "chart.pie")
                Text("Overview")
            }
            .tag(1)
            
            // Library Tab
            NavigationStack {
                VStack {
                    SettingsView(settings: settings)
                }
                .navigationTitle("Setting")
                .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Setting")
            }
            .tag(2)
        }
    }
}

// #Preview {
//    ContentView()
// }
