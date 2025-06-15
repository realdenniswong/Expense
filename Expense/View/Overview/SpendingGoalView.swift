//
//  SpendingGoalView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI

struct SpendingGoalView: View {
    let transactionAnalyzer: TransactionAnalyzer
    let settings: Settings
    
    // Get only the categories enabled for the current period
    private var enabledCategories: [ExpenseCategory] {
        settings.enabledCategories(for: transactionAnalyzer.period)
    }
    
    private var periodMultiplier: Double {
        switch transactionAnalyzer.period {
        case .daily: return 1.0 / 30.0 // Daily goal = monthly goal / 30
        case .weekly: return 1.0 / 4.0  // Weekly goal = monthly goal / 4
        case .monthly: return 1.0       // Monthly goal as-is
        }
    }
    
    private var periodLabel: String {
        switch transactionAnalyzer.period {
        case .daily: return "Daily Goals"
        case .weekly: return "Weekly Goals"
        case .monthly: return "Monthly Goals"
        }
    }
    
    private var currentSpending: [ExpenseCategory: Money] {
        return Dictionary(grouping: transactionAnalyzer.filteredTransactions, by: { $0.category })
            .mapValues { transactions in
                transactions.reduce(Money.zero) { $0 + $1.amount }
            }
    }
    
    private var spendingGoals: [SpendingGoal] {
        return enabledCategories.compactMap { category in
            let goalAmount = settings.goalAmount(for: category)
            
            let adjustedLimit = Int(Double(goalAmount) * periodMultiplier)
            let currentSpending = self.currentSpending[category]?.cents ?? 0
            return SpendingGoal(
                category: category,
                monthlyLimit: adjustedLimit,
                currentSpending: currentSpending
            )
        }.sorted { $0.progressPercentage > $1.progressPercentage }
    }
    
    private var totalBudget: Money {
        let sum = enabledCategories.map { settings.goalAmount(for: $0) }.reduce(0, +)
        return Money(cents: Int(Double(sum) * periodMultiplier))
    }
    
    private var totalSpent: Money {
        let total = enabledCategories.reduce(Money.zero) { total, category in
            total + (currentSpending[category] ?? Money.zero)
        }
        return total
    }
    
    private var overallProgress: Double {
        guard totalBudget.cents > 0 else { return 0 }
        return min(Double(totalSpent.cents) / Double(totalBudget.cents), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(periodLabel)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(transactionAnalyzer.periodDisplayName)
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
                        Text(totalSpent.formatted)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("of")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(totalBudget.formatted)
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
                        SpendingGoalRow(goal: goal)
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
        .animation(.easeInOut(duration: 0.3), value: transactionAnalyzer.period)
    }
}

struct SpendingGoalRow: View {
    let goal: SpendingGoal
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    CategoryIcon(category: goal.category, size: 32, iconSize: 14)
                    
                    Text(goal.category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(Money(cents: goal.currentSpending).formatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(goal.isOverBudget ? .red : .primary)
                    
                    if goal.isOverBudget {
                        Text("Over by \(Money(cents: -goal.remainingAmount).formatted)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("\(Money(cents: goal.remainingAmount).formatted) left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            ProgressView(value: goal.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(
                    tint: goal.isOverBudget ? .red : (goal.progressPercentage > 0.8 ? .orange : goal.category.color)
                ))
                .scaleEffect(x: 1, y: 1.2, anchor: .center)
        }
        .padding(.vertical, 4)
    }
}
