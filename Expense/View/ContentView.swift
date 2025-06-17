//
//  ContentView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var selectedTab = 0
    @Query private var settingsArray: [Settings]
    @Environment(\.modelContext) private var modelContext
    
    private var settings: Settings {
        if let existingSettings = settingsArray.first {
            return existingSettings
        } else {
            let newSettings = Settings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }
    }
    var body: some View {
        TabView {
            Tab("Expenses", systemImage: "banknote") {
                NavigationStack {
                    ExpenseView(transactions: transactions, settings: settings)
                        .navigationTitle("Transactions")
                        .navigationBarTitleDisplayMode(.large)
                }
            }
            Tab("Overview", systemImage: "chart.pie") {
                NavigationStack {
                    OverviewView(transactions: transactions, settings: settings)
                        .navigationTitle("Overview")
                        .navigationBarTitleDisplayMode(.large)
                }
            }
            Tab("Settings", systemImage: "gear") {
                NavigationStack {
                    SettingsView(settings: settings)
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.large)
                }
            }
        }
    }
}
