//
//  PeriosAnalyzer.swift
//  Expense
//
//  Created by Dennis Wong on 16/6/2025.
//

import Foundation

struct PeriodAnalyzer {
    let transactions: [Transaction]
    let period: TimePeriod
    let selectedDate: Date
    let settings: Settings?
    
    var currentPeriodTransactions: [Transaction] {
        let range = dateRange(for: period, date: selectedDate)
        return transactions.filter { range.contains($0.date) }
    }
    
    var totalAmount: Money {
        currentPeriodTransactions
            .map(\.amount)
            .reduce(.zero, +)
    }
    
    var spendingByCategory: [CategorySpending] {
        let grouped = Dictionary(grouping: currentPeriodTransactions, by: \.category)
        let total = totalAmount.cents
        
        return grouped.compactMap { category, transactions in
            let amount = transactions.map(\.amount.cents).reduce(0, +)
            guard amount > 0 else { return nil }
            
            return CategorySpending(
                category: category,
                amountInCent: amount,
                percentage: total > 0 ? Int(round(Double(amount) / Double(total) * 100)) : 0
            )
        }.sorted { $0.amountInCent > $1.amountInCent }
    }
    
    private func dateRange(for period: TimePeriod, date: Date) -> DateInterval {
        let calendar = Calendar.current
        
        switch period {
        case .daily:
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return DateInterval(start: start, end: end)
            
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: date)!
            
        case .monthly:
            return calendar.dateInterval(of: .month, for: date)!
        }
    }
}
