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
        /*
        TabView(selection: $selectedTab) {
            NavigationStack {
                ExpenseView(transactions: transactions, settings: settings)
                    .navigationTitle("Transactions")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: "banknote")
                Text("Transactions")
            }
            .tag(0)
            
            NavigationStack {
                OverviewView(transactions: transactions, settings: settings)
                    .navigationTitle("Overview")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: "chart.pie")
                Text("Overview")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView(settings: settings)
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
        }
         */
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
