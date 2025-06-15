//
//  AdaptiveSpendingSummaryView.swift
//  Expense
//
//  Created by Dennis Wong on [Current Date].
//

import SwiftUI

struct SpendingSummaryView: View {
    let expenseAnalyzer: ExpenseAnalyzer
    let selectedPeriod: TimePeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Main period - always on top
            MainPeriodView(
                title: mainPeriodTitle,
                amount: mainPeriodAmount,
                isSelected: true
            )
            
            Divider()
            
            // Secondary periods - bottom row
            HStack(spacing: 24) {
                SecondaryPeriodView(
                    title: leftPeriodTitle,
                    amount: leftPeriodAmount
                )
                
                Spacer()
                
                SecondaryPeriodView(
                    title: rightPeriodTitle,
                    amount: rightPeriodAmount
                )
            }
        }
        .cardBackground()
        .padding(.top, 8)
    }
    
    // MARK: - Computed Properties
    
    private var mainPeriodTitle: String {
        switch selectedPeriod {
        case .daily: return expenseAnalyzer.dailyDisplayName
        case .weekly: return expenseAnalyzer.weeklyDisplayName
        case .monthly: return expenseAnalyzer.monthlyDisplayName
        }
    }
    
    private var mainPeriodAmount: Int {
        switch selectedPeriod {
        case .daily: return expenseAnalyzer.todayAmount
        case .weekly: return expenseAnalyzer.thisWeekAmount
        case .monthly: return expenseAnalyzer.thisMonthAmount
        }
    }
    
    private var leftPeriodTitle: String {
        switch selectedPeriod {
        case .daily: return expenseAnalyzer.weeklyDisplayName
        case .weekly: return expenseAnalyzer.dailyDisplayName
        case .monthly: return expenseAnalyzer.dailyDisplayName
        }
    }
    
    private var leftPeriodAmount: Int {
        switch selectedPeriod {
        case .daily: return expenseAnalyzer.thisWeekAmount
        case .weekly: return expenseAnalyzer.todayAmount
        case .monthly: return expenseAnalyzer.todayAmount
        }
    }
    
    private var rightPeriodTitle: String {
        switch selectedPeriod {
        case .daily: return expenseAnalyzer.monthlyDisplayName
        case .weekly: return expenseAnalyzer.monthlyDisplayName
        case .monthly: return expenseAnalyzer.weeklyDisplayName
        }
    }
    
    private var rightPeriodAmount: Int {
        switch selectedPeriod {
        case .daily: return expenseAnalyzer.thisMonthAmount
        case .weekly: return expenseAnalyzer.thisMonthAmount
        case .monthly: return expenseAnalyzer.thisWeekAmount
        }
    }
}

// MARK: - Main Period View (Top, Large)
struct MainPeriodView: View {
    let title: String
    let amount: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .blue : .secondary)
            
            Text(amount.currencyString(symbol: "HK$"))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()
        }
    }
}

// MARK: - Secondary Period View (Bottom, Smaller)
struct SecondaryPeriodView: View {
    let title: String
    let amount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(amount.currencyString(symbol: "HK$"))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()
        }
    }
}
