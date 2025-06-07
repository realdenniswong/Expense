//
//  ExpenseStore.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

class ExpenseManager: ObservableObject {
    
    @Published var expenses: [Expense] = []
    
    private let userDefaults = UserDefaults.standard
    private let expensesKey = "SavedExpenses"
    
    init() {
        loadExpenses()
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    
    /// - description: Group expenses by date
    var groupedExpenses: [(String, [Expense])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let grouped = Dictionary(grouping: expenses) { expense in
            dateFormatter.string(from: expense.date)
        }
        
        // Sort by date (most recent first)
        return grouped.sorted { first, second in
            let firstDate = expenses.first { dateFormatter.string(from: $0.date) == first.key }?.date ?? Date.distantPast
            let secondDate = expenses.first { dateFormatter.string(from: $0.date) == second.key }?.date ?? Date.distantPast
            return firstDate > secondDate
        }
    }
    
    private func loadExpenses() {
        if let data = userDefaults.data(forKey: expensesKey),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
    }
    
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            userDefaults.set(encoded, forKey: expensesKey)
        }
    }
    
    func addExpense(_ expense: Expense) {
        // Find the highest order number and add 1
        let maxOrder = expenses.map(\.order).max() ?? -1
        
        // Create the expense with the next order number
        var newExpense = expense
        newExpense.order = maxOrder + 1
        
        expenses.append(newExpense)
        saveExpenses()
    }
    
    func updateExpense(_ updatedExpense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            expenses[index] = updatedExpense
            saveExpenses()
        }
    }
    
    func deleteExpenses(_ expense: Expense) {
        if let originalIndex = expenses.firstIndex(where: {
            $0.id == expense.id
        }){
            expenses.remove(atOffsets: IndexSet([originalIndex]))
            saveExpenses()
        }
    }
    
    func moveExpenses(in dateString: String, from source: IndexSet, to destination: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // Filter and sort expenses for the selected date
        var expensesForDate = expenses
            .filter { dateFormatter.string(from: $0.date) == dateString }
            .sorted { $0.order < $1.order }
        
        // Perform the move on the filtered list
        expensesForDate.move(fromOffsets: source, toOffset: destination)
        
        // Update order values in the filtered list
        for (index, var expense) in expensesForDate.enumerated() {
            expense.order = index
            
            if let originalIndex = expenses.firstIndex(where: { $0.id == expense.id }) {
                expenses[originalIndex] = expense
            }
        }
        
        // Re-sort the main list by updated order
        expenses.sort { $0.order < $1.order }
        
        saveExpenses()
    }
}
