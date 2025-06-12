//
//  PeriodAwareSpendingGoalsView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI

struct SpendingGoalView: View {
    let filteredExpenses: FilteredExpenses
    @State private var goals: [ExpenseCategory: Int] = [
        .foodDrink: 150000, // HK$1500
        .transportation: 80000, // HK$800
        .shopping: 100000, // HK$1000
        .entertainment: 60000, // HK$600
        .billsUtilities: 200000 // HK$2000
    ]
    
    private var periodMultiplier: Double {
        switch filteredExpenses.period {
        case .daily: return 1.0 / 30.0 // Daily goal = monthly goal / 30
        case .weekly: return 1.0 / 4.0  // Weekly goal = monthly goal / 4
        case .monthly: return 1.0       // Monthly goal as-is
        }
    }
    
    private var periodLabel: String {
        switch filteredExpenses.period {
        case .daily: return "Daily Goals"
        case .weekly: return "Weekly Goals"
        case .monthly: return "Monthly Goals"
        }
    }
    
    private var currentSpending: [ExpenseCategory: Int] {
        return Dictionary(grouping: filteredExpenses.filteredExpenses, by: { $0.category })
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amountInCents }
            }
    }
    
    private var spendingGoals: [SpendingGoal] {
        return goals.compactMap { goal in
            let adjustedLimit = Int(Double(goal.value) * periodMultiplier)
            let currentSpending = self.currentSpending[goal.key] ?? 0
            return SpendingGoal(
                category: goal.key,
                monthlyLimit: adjustedLimit,
                currentSpending: currentSpending
            )
        }.sorted { $0.progressPercentage > $1.progressPercentage }
    }
    
    private var totalBudget: Int {
        Int(Double(goals.values.reduce(0, +)) * periodMultiplier)
    }
    
    private var totalSpent: Int {
        currentSpending.values.reduce(0, +)
    }
    
    private var overallProgress: Double {
        guard totalBudget > 0 else { return 0 }
        return min(Double(totalSpent) / Double(totalBudget), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(periodLabel)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(Int(overallProgress * 100))% used")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(overallProgress > 0.8 ? .red : .secondary)
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
        .animation(.easeInOut(duration: 0.3), value: filteredExpenses.period)
    }
}
