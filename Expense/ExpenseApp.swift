//
//  ExpenseApp.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

@main
struct ExpenseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Expense.self)
    }
}
