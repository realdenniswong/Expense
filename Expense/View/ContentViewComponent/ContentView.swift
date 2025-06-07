//
//  ContentView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var expenseStore = ExpenseStore()
    @State private var showingAddExpense = false
    @State private var editingExpense: Expense? = nil
    
    var body: some View {
        NavigationStack{
            VStack{
                SummaryView(totalExpenses: expenseManager.totalExpenses)
                TransactionListView(expenseManager: self.expenseManager, editingExpense: $editingExpense)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addExpenseButton
                }
            }
            // When creating a transaction
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(expenseStore: expenseStore)
            }
            // When editing a transaction
            .sheet(item: $editingExpense) { expense in
                // AddExpenseView(expenseStore: expenseStore, expenseToEdit: expense)
            }
        }
    }
    
    private var addExpenseButton: some View {
        Button(action: {
            showingAddExpense = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.medium)
        }
    }
}



#Preview {
    ContentView()
}
