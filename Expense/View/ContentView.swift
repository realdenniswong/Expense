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
                    OverviewView(expenses: expenses)
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
                    Text("Setting")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Spacer()
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
