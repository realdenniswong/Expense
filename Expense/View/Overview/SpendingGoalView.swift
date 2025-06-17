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
    
    private var categories: [ExpenseCategory] {
        settings.enabledCategories(for: transactionAnalyzer.period)
    }
    
    private var multiplier: Double {
        transactionAnalyzer.period.periodMultiplier
    }
    
    private var periodLabel: String {
        switch transactionAnalyzer.period {
        case .daily: return "Daily Goals"
        case .weekly: return "Weekly Goals"
        case .monthly: return "Monthly Goals"
        }
    }
    
    private var spending: [ExpenseCategory: Money] {
        Dictionary(grouping: transactionAnalyzer.filteredTransactions, by: \.category)
            .mapValues { transactions in
                transactions.reduce(.zero) { $0 + $1.amount }
            }
    }
    
    private var goals: [SpendingGoal] {
        categories.compactMap { category in
            let goalAmount = settings.goalAmount(for: category)
            let adjustedLimit = Int(Double(goalAmount) * multiplier)
            let currentSpending = spending[category]?.cents ?? 0
            
            return SpendingGoal(
                category: category,
                monthlyLimit: adjustedLimit,
                currentSpending: currentSpending
            )
        }.sorted { $0.progressPercentage > $1.progressPercentage }
    }
    
    private var totalBudget: Money {
        let sum = categories.map { settings.goalAmount(for: $0) }.reduce(0, +)
        return Money(cents: Int(Double(sum) * multiplier))
    }
    
    private var totalSpent: Money {
        categories.reduce(.zero) { total, category in
            total + (spending[category] ?? .zero)
        }
    }
    
    private var progress: Double {
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
                        
                        Text("\(Int(progress * 100))% used")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(progress > 0.8 ? .red : .secondary)
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
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: progress > 1.0 ? .red : .blue))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
            }
            
            if !goals.isEmpty {
                Divider()
                
                LazyVStack(spacing: 12) {
                    ForEach(goals, id: \.category.rawValue) { goal in
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
