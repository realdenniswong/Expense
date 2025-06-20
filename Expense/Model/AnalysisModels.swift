//
//  AnalysisModels.swift
//  Expense
//
//  Created by Dennis Wong on 16/6/2025.
//

import Foundation
import SwiftUI

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

// SIMPLIFIED: Time period enumeration with built-in configuration
enum TimePeriod: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    // MARK: - UI Configuration (replaces GoalPeriodConfig)
    
    var title: String {
        return "\(rawValue) Goals"
    }
    
    private var config: (icon: String, color: Color, desc: String) {
        switch self {
        case .daily:
            return ("target", .blue, "Enable daily spending goals to track frequent expenses like food and transportation.")
        case .weekly:
            return ("calendar.badge.clock", .orange, "Enable weekly spending goals to track moderate frequency expenses like shopping and entertainment.")
        case .monthly:
            return ("calendar", .green, "Enable monthly spending goals to track all expense categories, including bills and healthcare.")
        }
    }
    
    var iconName: String {
        return config.icon
    }
    
    var iconColor: Color {
        return config.color
    }
    
    var description: String {
        return config.desc
    }
    
    var categoriesFooter: String {
        return "Select which expense categories to track \(rawValue.lowercased()) spending goals for."
    }
    
    // MARK: - Period Multipliers for Goal Calculation
    
    var periodMultiplier: Double {
        switch self {
        case .daily: return 1.0 / 30.0    // Daily goal = monthly goal / 30
        case .weekly: return 1.0 / 4.0     // Weekly goal = monthly goal / 4
        case .monthly: return 1.0          // Monthly goal as-is
        }
    }
}
