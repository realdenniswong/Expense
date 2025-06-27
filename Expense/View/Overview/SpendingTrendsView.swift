//
//  SpendingTrendsView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//

import SwiftUI
import Charts

struct SpendingTrendsView: View {
    let transactionAnalyzer: TransactionAnalyzer
    @State private var selectedLabel: String? = nil
    
    private var transactions: [Transaction] { transactionAnalyzer.transactions }
    private var selectedPeriod: TimePeriod { transactionAnalyzer.period }
    private var selectedDate: Date { transactionAnalyzer.selectedDate }
    private var settings: Settings? { transactionAnalyzer.settings }
    
    private var trendData: [TrendData] {
        switch selectedPeriod {
        case .daily: return getTrendData(for: .day, periods: 7)
        case .weekly: return getTrendData(for: .weekOfYear, periods: 6)
        case .monthly: return getTrendData(for: .month, periods: 6)
        }
    }
    
    // SIMPLIFIED: Single method instead of 3 separate ones
    private func getTrendData(for component: Calendar.Component, periods: Int) -> [TrendData] {
        let calendar = Calendar.current
        var results: [TrendData] = []
        
        for i in 0..<periods {
            let periodDate: Date
            let interval: DateInterval
            
            switch component {
            case .day:
                // Use settings.dailyStartHour if available
                if let settings = settings {
                    // For each day, compute start date with day offset and hour offset
                    // Calculate the day offset from selectedDate, stepping back
                    let dayOffset = -(periods - 1 - i)
                    // Get the start of selectedDate day at dailyStartHour
                    let baseDate = calendar.startOfDay(for: selectedDate)
                    let baseWithStartHour = calendar.date(byAdding: .hour, value: settings.dailyStartHour, to: baseDate) ?? baseDate
                    // Shift by dayOffset days
                    periodDate = calendar.date(byAdding: .day, value: dayOffset, to: baseWithStartHour) ?? baseWithStartHour
                    
                    // The interval runs from periodDate to periodDate + 1 day
                    let start = periodDate
                    let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
                    interval = DateInterval(start: start, end: end)
                } else {
                    periodDate = calendar.date(byAdding: .day, value: -(periods-1-i), to: selectedDate) ?? selectedDate
                    let start = calendar.startOfDay(for: periodDate)
                    let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
                    interval = DateInterval(start: start, end: end)
                }
            case .weekOfYear:
                if let settings = settings {
                    // Use settings.weeklyStartDay (0=Sunday, 1=Monday, ... 6=Saturday)
                    // We find the week start date for the selectedDate adjusted by weeklyStartDay,
                    // then shift weeks backwards by periods-1-i
                    
                    // Find current week start aligned to weeklyStartDay
                    let weekday = calendar.component(.weekday, from: selectedDate) - 1 // convert to 0-based Sunday=0
                    let diffToStartDay = (weekday - settings.weeklyStartDay + 7) % 7
                    let currentWeekStart = calendar.date(byAdding: .day, value: -diffToStartDay, to: calendar.startOfDay(for: selectedDate)) ?? selectedDate
                    
                    // Shift back by (periods-1-i) weeks
                    let weekStart = calendar.date(byAdding: .weekOfYear, value: -(periods-1-i), to: currentWeekStart) ?? currentWeekStart
                    
                    // Week interval is from weekStart to weekStart + 7 days
                    interval = DateInterval(start: weekStart, end: calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart)
                    periodDate = weekStart
                } else {
                    let selectedWeekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) ?? DateInterval(start: selectedDate, duration: 0)
                    let weekStart = calendar.date(byAdding: .weekOfYear, value: -(periods-1-i), to: selectedWeekInterval.start) ?? selectedDate
                    interval = calendar.dateInterval(of: .weekOfYear, for: weekStart) ?? DateInterval(start: weekStart, duration: 0)
                    periodDate = weekStart
                }
            case .month:
                if let settings = settings {
                    // Use settings.monthlyStartDay (1...31) to define month start
                    // Use monthlySummaryStart helper if available for correct alignment
                    // For each month offset, compute the start date
                    // monthlySummaryStart(date: Date, startDay: Int, calendar: Calendar) -> Date
                    func monthlySummaryStart(_ date: Date, startDay: Int, calendar: Calendar) -> Date {
                        // Find the start of the month containing date
                        let components = calendar.dateComponents([.year, .month], from: date)
                        let firstOfMonth = calendar.date(from: components) ?? date
                        
                        if startDay <= 1 {
                            return firstOfMonth
                        }
                        
                        var startComponents = DateComponents()
                        startComponents.year = components.year
                        startComponents.month = components.month
                        startComponents.day = startDay
                        
                        if let startDayDate = calendar.date(from: startComponents) {
                            if startDayDate <= date {
                                return startDayDate
                            } else {
                                return calendar.date(byAdding: .month, value: -1, to: startDayDate) ?? startDayDate
                            }
                        }
                        return firstOfMonth
                    }
                    
                    // Calculate the adjusted monthStart using monthlySummaryStart, shifted by months
                    let baseMonthStart = monthlySummaryStart(selectedDate, startDay: settings.monthlyStartDay, calendar: calendar)
                    guard let monthStart = calendar.date(byAdding: .month, value: -(periods-1-i), to: baseMonthStart) else {
                        periodDate = selectedDate
                        interval = DateInterval(start: selectedDate, duration: 0)
                        break
                    }
                    
                    let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
                    interval = DateInterval(start: monthStart, end: nextMonthStart)
                    periodDate = monthStart
                } else {
                    let selectedMonthInterval = calendar.dateInterval(of: .month, for: selectedDate) ?? DateInterval(start: selectedDate, duration: 0)
                    let monthStart = calendar.date(byAdding: .month, value: -(periods-1-i), to: selectedMonthInterval.start) ?? selectedDate
                    interval = calendar.dateInterval(of: .month, for: monthStart) ?? DateInterval(start: monthStart, duration: 0)
                    periodDate = monthStart
                }
            default:
                continue
            }
            
            let periodTransactions = transactions.filter { interval.contains($0.date) }
            // Removed filtering by enabledCategories so we sum all categories regardless of settings
            let filteredTransactions = periodTransactions
            let totalAmount = filteredTransactions.reduce(Money.zero) { $0 + $1.amount }
            
            let formatter = DateFormatter()
            if component == .month {
                formatter.dateFormat = "MMM d"
            } else if component == .day {
                formatter.dateFormat = "d/M"
            } else {
                formatter.dateFormat = "MMM d"
            }
            let label = formatter.string(from: interval.start)
            
            results.append(TrendData(
                startDate: interval.start,
                endDate: interval.end,
                amount: totalAmount.cents,
                label: label
            ))
        }
        
        return results
    }
    
    // Uses customFilteredTransactions for user-defined boundaries
    func getCustomTrendData(for category: ExpenseCategory, periods: [DateInterval]) -> [Money] {
        let transactions = transactionAnalyzer.customFilteredTransactions
        return periods.map { period in
            transactions
                .filter { $0.category == category && period.contains($0.date) }
                .reduce(Money.zero) { $0 + $1.amount }
        }
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
        case .daily: return "Last 7 days"
        case .weekly: return "Last 6 weeks"
        case .monthly: return "Last 6 months"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                    if let selectedLabel = selectedLabel,
                       let selectedTrend = trendData.first(where: { $0.label == selectedLabel }) {
                        Text(Money(cents: selectedTrend.amount).formatted)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text(getDetailedPeriodName(for: selectedTrend))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    } else {
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
            }
            
            Chart(trendData, id: \.startDate) { trend in
                BarMark(
                    x: .value("Period", trend.label),
                    y: .value("Amount", trend.amount/100)
                )
                .foregroundStyle(
                    selectedLabel == trend.label ?
                    Color.blue : Color.blue.opacity(0.7)
                )
                .cornerRadius(6)
            }
            .chartStyle(.bar)
            .chartXSelection(value: $selectedLabel)
            .animation(.easeInOut(duration: 0.3), value: selectedPeriod)
            .animation(.easeInOut(duration: 0.3), value: selectedDate)
            .animation(.easeInOut(duration: 0.2), value: selectedLabel)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .onTapGesture {
            selectedLabel = nil
        }
    }
    
    private func getDetailedPeriodName(for trend: TrendData) -> String {
        let tempAnalyzer = TransactionAnalyzer(
            transactions: transactions,
            period: selectedPeriod,
            selectedDate: trend.startDate,
            settings: settings
        )
        
        switch selectedPeriod {
        case .daily:
            if let settings = settings {
                let calendar = Calendar.current
                
                // startDate is already aligned to dailyStartHour
                let start = trend.startDate
                
                // end is start + 1 day - 1 minute
                guard let endFull = calendar.date(byAdding: .day, value: 1, to: start) else {
                    return tempAnalyzer.dailyDisplayName
                }
                // Subtract 1 minute
                let end = calendar.date(byAdding: .minute, value: -1, to: endFull) ?? endFull
                
                let formatter = DateFormatter()
                formatter.dateFormat = "d/M H:mm"
                
                return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
            } else {
                return tempAnalyzer.dailyDisplayName
            }
        case .weekly:
            // Show custom week range label based on settings.weeklyStartDay
            let calendar = Calendar.current
            guard let settings = settings else {
                return tempAnalyzer.weeklyDisplayName
            }
            // weeklyStartDay: 0=Sunday ... 6=Saturday
            
            // Calculate custom week start aligned to weeklyStartDay
            let weekday = calendar.component(.weekday, from: trend.startDate) - 1
            let diffToStartDay = (weekday - settings.weeklyStartDay + 7) % 7
            let weekStart = calendar.date(byAdding: .day, value: -diffToStartDay, to: calendar.startOfDay(for: trend.startDate)) ?? trend.startDate
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d/M/yyyy"
            
            return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
        case .monthly:
            guard let settings = settings else {
                return tempAnalyzer.monthlyDisplayName
            }
            let calendar = Calendar.current
            
            // Helper function for monthlySummaryStart
            func monthlySummaryStart(_ date: Date, startDay: Int, calendar: Calendar) -> Date {
                let components = calendar.dateComponents([.year, .month], from: date)
                let firstOfMonth = calendar.date(from: components) ?? date
                
                if startDay <= 1 {
                    return firstOfMonth
                }
                
                var startComponents = DateComponents()
                startComponents.year = components.year
                startComponents.month = components.month
                startComponents.day = startDay
                
                if let startDayDate = calendar.date(from: startComponents) {
                    if startDayDate <= date {
                        return startDayDate
                    } else {
                        return calendar.date(byAdding: .month, value: -1, to: startDayDate) ?? startDayDate
                    }
                }
                return firstOfMonth
            }
            
            let start = monthlySummaryStart(trend.startDate, startDay: settings.monthlyStartDay, calendar: calendar)
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: start) ?? start
            // End is one day before nextMonth start
            let end = calendar.date(byAdding: .day, value: -1, to: nextMonth) ?? nextMonth
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d/M/yyyy"
            
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
}

