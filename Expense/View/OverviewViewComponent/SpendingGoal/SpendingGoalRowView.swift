
//
//  Untitled.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI

struct SpendingGoalRowView: View {
    let goal: SpendingGoal
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    CategoryIconView(category: goal.category, size: 32, iconSize: 14)
                    
                    Text(goal.category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(goal.currentSpending.currencyString(symbol: "HK$"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(goal.isOverBudget ? .red : .primary)
                    
                    if goal.isOverBudget {
                        Text("Over by \((-goal.remainingAmount).currencyString(symbol: "HK$"))")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("\(goal.remainingAmount.currencyString(symbol: "HK$")) left")
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
