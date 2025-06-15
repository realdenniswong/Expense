//
//  AdaptiveSpendingSummaryView.swift
//  Expense
//
//  Created by Dennis Wong on [Current Date].
//

import SwiftUI

struct SpendingSummaryView: View {
    let transactionAnalyzer: TransactionAnalyzer
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
        case .daily: return transactionAnalyzer.dailyDisplayName
        case .weekly: return transactionAnalyzer.weeklyDisplayName
        case .monthly: return transactionAnalyzer.monthlyDisplayName
        }
    }
    
    private var mainPeriodAmount: Money {
        switch selectedPeriod {
        case .daily: return transactionAnalyzer.todayAmount
        case .weekly: return transactionAnalyzer.thisWeekAmount
        case .monthly: return transactionAnalyzer.thisMonthAmount
        }
    }
    
    private var leftPeriodTitle: String {
        switch selectedPeriod {
        case .daily: return transactionAnalyzer.weeklyDisplayName
        case .weekly: return transactionAnalyzer.dailyDisplayName
        case .monthly: return transactionAnalyzer.dailyDisplayName
        }
    }
    
    private var leftPeriodAmount: Money {
        switch selectedPeriod {
        case .daily: return transactionAnalyzer.thisWeekAmount
        case .weekly: return transactionAnalyzer.todayAmount
        case .monthly: return transactionAnalyzer.todayAmount
        }
    }
    
    private var rightPeriodTitle: String {
        switch selectedPeriod {
        case .daily: return transactionAnalyzer.monthlyDisplayName
        case .weekly: return transactionAnalyzer.monthlyDisplayName
        case .monthly: return transactionAnalyzer.weeklyDisplayName
        }
    }
    
    private var rightPeriodAmount: Money {
        switch selectedPeriod {
        case .daily: return transactionAnalyzer.thisMonthAmount
        case .weekly: return transactionAnalyzer.thisMonthAmount
        case .monthly: return transactionAnalyzer.thisWeekAmount
        }
    }
}

// MARK: - Updated Period Views (Use Money type)
struct MainPeriodView: View {
    let title: String
    let amount: Money
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .blue : .secondary)
            
            Text(amount.formatted)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()
        }
    }
}

struct SecondaryPeriodView: View {
    let title: String
    let amount: Money
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(amount.formatted)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()
        }
    }
}
