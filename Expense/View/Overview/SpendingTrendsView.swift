//
//  SpendingTrendView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//

import SwiftUI
import Charts

struct SpendingTrendsView: View {
    let transactionAnalyzer: TransactionAnalyzer
    
    private var transactions: [Transaction] {
        transactionAnalyzer.transactions
    }
    
    private var selectedPeriod: TimePeriod {
        transactionAnalyzer.period
    }
    
    private var selectedDate: Date {
        transactionAnalyzer.selectedDate
    }
    
    private var settings: Settings? {
        transactionAnalyzer.settings
    }
    
    private var trendData: [TrendData] {
        switch selectedPeriod {
        case .daily:
            return getDailyData()
        case .weekly:
            return getWeeklyData()
        case .monthly:
            return getMonthlyData()
        }
    }
    
    private func getDailyData() -> [TrendData] {
        let calendar = Calendar.current
        var days: [TrendData] = []
        
        // Show 7 days ending with selected date
        for i in 0..<7 {
            let dayDate = calendar.date(byAdding: .day, value: -(6-i), to: selectedDate) ?? selectedDate
            let dayStart = calendar.startOfDay(for: dayDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            
            let dayTransactions = transactions.filter { transaction in
                transaction.date >= dayStart && transaction.date < dayEnd
            }
            
            // Filter by enabled categories if settings are available
            let filteredTransactions: [Transaction]
            if let settings = settings {
                let enabledCategories = Set(settings.enabledCategories(for: .daily))
                filteredTransactions = dayTransactions.filter { enabledCategories.contains($0.category) }
            } else {
                filteredTransactions = dayTransactions
            }
            
            let totalAmount = filteredTransactions.reduce(Money.zero) { $0 + $1.amount }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let dayLabel = formatter.string(from: dayDate)
            
            days.append(TrendData(
                startDate: dayStart,
                endDate: dayEnd,
                amount: totalAmount.cents,
                label: dayLabel
            ))
        }
        
        return days
    }
    
    private func getWeeklyData() -> [TrendData] {
        let calendar = Calendar.current
        var weeks: [TrendData] = []
        
        // Get the week containing selectedDate, then go back 4 more weeks
        guard let selectedWeekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        
        for i in 0..<5 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -(4-i), to: selectedWeekInterval.start) else {
                continue
            }
            
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekStart) else {
                continue
            }
            
            let weekTransactions = transactions.filter { transaction in
                transaction.date >= weekInterval.start && transaction.date < weekInterval.end
            }
            
            // Filter by enabled categories if settings are available
            let filteredTransactions: [Transaction]
            if let settings = settings {
                let enabledCategories = Set(settings.enabledCategories(for: .weekly))
                filteredTransactions = weekTransactions.filter { enabledCategories.contains($0.category) }
            } else {
                filteredTransactions = weekTransactions
            }
            
            let totalAmount = filteredTransactions.reduce(Money.zero) { $0 + $1.amount }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let weekLabel = formatter.string(from: weekInterval.start)
            
            weeks.append(TrendData(
                startDate: weekInterval.start,
                endDate: weekInterval.end,
                amount: totalAmount.cents,
                label: weekLabel
            ))
        }
        
        return weeks
    }
    
    private func getMonthlyData() -> [TrendData] {
        let calendar = Calendar.current
        var months: [TrendData] = []
        
        // Get the month containing selectedDate, then go back 5 more months
        guard let selectedMonthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
            return []
        }
        
        for i in 0..<6 {
            guard let monthStart = calendar.date(byAdding: .month, value: -(5-i), to: selectedMonthInterval.start) else {
                continue
            }
            
            guard let monthInterval = calendar.dateInterval(of: .month, for: monthStart) else {
                continue
            }
            
            let monthTransactions = transactions.filter { transaction in
                transaction.date >= monthInterval.start && transaction.date < monthInterval.end
            }
            
            // Filter by enabled categories if settings are available
            let filteredTransactions: [Transaction]
            if let settings = settings {
                let enabledCategories = Set(settings.enabledCategories(for: .monthly))
                filteredTransactions = monthTransactions.filter { enabledCategories.contains($0.category) }
            } else {
                filteredTransactions = monthTransactions
            }
            
            let totalAmount = filteredTransactions.reduce(Money.zero) { $0 + $1.amount }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let monthLabel = formatter.string(from: monthStart)
            
            months.append(TrendData(
                startDate: monthInterval.start,
                endDate: monthInterval.end,
                amount: totalAmount.cents,
                label: monthLabel
            ))
        }
        
        return months
    }
    
    private var averageSpending: Money {
        let nonZeroPeriods = trendData.filter { $0.amount > 0 }
        guard !nonZeroPeriods.isEmpty else { return .zero }
        let total = nonZeroPeriods.reduce(0) { $0 + $1.amount }
        return Money(cents: total / nonZeroPeriods.count)
    }
    
    private var trendComparison: (percentage: Int, isIncrease: Bool) {
        guard trendData.count >= 2 else { return (0, false) }
        
        let currentPeriod = trendData.last?.amount ?? 0
        let previousPeriod = trendData[trendData.count - 2].amount
        
        guard previousPeriod > 0 else { return (0, false) }
        
        let change = Double(currentPeriod - previousPeriod) / Double(previousPeriod) * 100
        return (Int(abs(change)), change > 0)
    }
    
    private var periodCount: String {
        switch selectedPeriod {
        case .daily: return "Last 7 days" + (!transactionAnalyzer.periodDisplayName.isEmpty ? " (to \(transactionAnalyzer.periodDisplayName))" : "")
        case .weekly: return "Last 5 weeks" + (!transactionAnalyzer.periodDisplayName.isEmpty ? " (to \(transactionAnalyzer.periodDisplayName))" : "")
        case .monthly: return "Last 6 months" + (!transactionAnalyzer.periodDisplayName.isEmpty ? " (to \(transactionAnalyzer.periodDisplayName))" : "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spending Trends")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(periodCount)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Avg: \(averageSpending.formatted)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text(trendComparison.isIncrease ? "▲" : "▼")
                            .font(.caption)
                            .foregroundColor(trendComparison.isIncrease ? .red : .green)
                        
                        Text("\(trendComparison.percentage)%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(trendComparison.isIncrease ? .red : .green)
                    }
                }
            }
            
            // Chart
            Chart(trendData, id: \.startDate) { trend in
                BarMark(
                    x: .value("Period", trend.label),
                    y: .value("Amount", trend.amount/100)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(6)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedPeriod)
            .animation(.easeInOut(duration: 0.3), value: selectedDate)
        }
        .cardBackground()
    }
}
