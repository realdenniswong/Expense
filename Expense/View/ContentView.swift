//
//  ContentView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                VStack {
                    ExpensesView()
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
                    Text("Overview")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Spacer()
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
