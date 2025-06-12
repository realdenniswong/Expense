//
//  SpendingGoal.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//

struct SpendingGoal {
    let category: ExpenseCategory
    let monthlyLimit: Int
    let currentSpending: Int
    
    var progressPercentage: Double {
        guard monthlyLimit > 0 else { return 0 }
        return min(Double(currentSpending) / Double(monthlyLimit), 1.0)
    }
    
    var isOverBudget: Bool {
        currentSpending > monthlyLimit
    }
    
    var remainingAmount: Int {
        monthlyLimit - currentSpending
    }
}
