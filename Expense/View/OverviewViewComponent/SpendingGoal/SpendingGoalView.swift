//
//  SpendingGoalView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI

struct SpendingGoalView: View {
    
    let expenseAnalyzer: ExpenseAnalyzer
    let settings: Settings
    
    @State private var goals: [ExpenseCategory: Int] = [
        .foodDrink: 150000, // HK$1500
        .transportation: 80000, // HK$800
        .shopping: 100000, // HK$1000
        .entertainment: 60000, // HK$600
        .billsUtilities: 200000, // HK$2000
        .healthcare: 50000, // HK$500
        .other: 30000 // HK$300
    ]
    
    // Get only the categories enabled for the current period
    private var enabledCategories: [ExpenseCategory] {
        settings.enabledCategories(for: expenseAnalyzer.period)
    }
    
    private var periodMultiplier: Double {
        switch expenseAnalyzer.period {
        case .daily: return 1.0 / 30.0 // Daily goal = monthly goal / 30
        case .weekly: return 1.0 / 4.0  // Weekly goal = monthly goal / 4
        case .monthly: return 1.0       // Monthly goal as-is
        }
    }
    
    private var periodLabel: String {
        switch expenseAnalyzer.period {
        case .daily: return "Daily Goals"
        case .weekly: return "Weekly Goals"
        case .monthly: return "Monthly Goals"
        }
    }
    
    private var currentSpending: [ExpenseCategory: Int] {
        return Dictionary(grouping: expenseAnalyzer.filteredExpenses, by: { $0.category })
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amountInCents }
            }
    }
    
    private var spendingGoals: [SpendingGoal] {
        return enabledCategories.compactMap { category in
            guard let goalAmount = goals[category] else { return nil }
            
            let adjustedLimit = Int(Double(goalAmount) * periodMultiplier)
            let currentSpending = self.currentSpending[category] ?? 0
            return SpendingGoal(
                category: category,
                monthlyLimit: adjustedLimit,
                currentSpending: currentSpending
            )
        }.sorted { $0.progressPercentage > $1.progressPercentage }
    }
    
    private var totalBudget: Int {
        enabledCategories.compactMap { goals[$0] }
            .reduce(0, +)
            .let { Int(Double($0) * periodMultiplier) }
    }
    
    private var totalSpent: Int {
        enabledCategories.reduce(0) { total, category in
            total + (currentSpending[category] ?? 0)
        }
    }
    
    private var overallProgress: Double {
        guard totalBudget > 0 else { return 0 }
        return min(Double(totalSpent) / Double(totalBudget), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(periodLabel)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(expenseAnalyzer.periodDisplayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    

                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("\(Int(overallProgress * 100))% used")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(overallProgress > 0.8 ? .red : .secondary)
                    }
                    

                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(totalSpent.currencyString(symbol: "HK$"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("of")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(totalBudget.currencyString(symbol: "HK$"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: overallProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: overallProgress > 1.0 ? .red : .blue))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
            }
            
            if !spendingGoals.isEmpty {
                Divider()
                
                LazyVStack(spacing: 12) {
                    ForEach(spendingGoals, id: \.category.rawValue) { goal in
                        SpendingGoalRowView(goal: goal)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .animation(.easeInOut(duration: 0.3), value: expenseAnalyzer.period)
    }
}

// Extension to help with functional programming
extension Int {
    func `let`<T>(_ transform: (Int) -> T) -> T {
        return transform(self)
    }
}
