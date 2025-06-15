//
//  AnalysisModels.swift
//  Expense
//
//  Created by Dennis Wong on 16/6/2025.
//

import Foundation

// Category spending analysis
struct CategorySpending {
    let category: ExpenseCategory
    let amountInCent: Int
    let percentage: Int
}

// Trend analysis data
struct TrendData {
    let startDate: Date
    let endDate: Date
    let amount: Int
    let label: String
}

// Spending goal tracking
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

// Time period enumeration
enum TimePeriod: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}
