//
//  SpendingTrendView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//

import SwiftUI
import Charts

struct SpendingTrendsView: View {

    let expenseAnalyzer: ExpenseAnalyzer
    
    private var expenses: [Expense] {
        expenseAnalyzer.expenses
    }
    
    private var selectedPeriod: TimePeriod {
        expenseAnalyzer.period
    }
    
    private var selectedDate: Date {
        expenseAnalyzer.selectedDate
    }
    
    private var settings: Settings? {
        expenseAnalyzer.settings
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
            
            let dayExpenses = expenses.filter { expense in
                expense.date >= dayStart && expense.date < dayEnd
            }
            
            // Filter by enabled categories if settings are available
            let filteredExpenses: [Expense]
            if let settings = settings {
                let enabledCategories = Set(settings.enabledCategories(for: .daily))
                filteredExpenses = dayExpenses.filter { enabledCategories.contains($0.category) }
            } else {
                filteredExpenses = dayExpenses
            }
            
            let totalAmount = filteredExpenses.reduce(0) { $0 + $1.amountInCents }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let dayLabel = formatter.string(from: dayDate)
            
            days.append(TrendData(
                startDate: dayStart,
                endDate: dayEnd,
                amount: totalAmount,
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
            
            let weekExpenses = expenses.filter { expense in
                expense.date >= weekInterval.start && expense.date < weekInterval.end
            }
            
            // Filter by enabled categories if settings are available
            let filteredExpenses: [Expense]
            if let settings = settings {
                let enabledCategories = Set(settings.enabledCategories(for: .weekly))
                filteredExpenses = weekExpenses.filter { enabledCategories.contains($0.category) }
            } else {
                filteredExpenses = weekExpenses
            }
            
            let totalAmount = filteredExpenses.reduce(0) { $0 + $1.amountInCents }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let weekLabel = formatter.string(from: weekInterval.start)
            
            weeks.append(TrendData(
                startDate: weekInterval.start,
                endDate: weekInterval.end,
                amount: totalAmount,
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
            
            let monthExpenses = expenses.filter { expense in
                expense.date >= monthInterval.start && expense.date < monthInterval.end
            }
            
            // Filter by enabled categories if settings are available
            let filteredExpenses: [Expense]
            if let settings = settings {
                let enabledCategories = Set(settings.enabledCategories(for: .monthly))
                filteredExpenses = monthExpenses.filter { enabledCategories.contains($0.category) }
            } else {
                filteredExpenses = monthExpenses
            }
            
            let totalAmount = filteredExpenses.reduce(0) { $0 + $1.amountInCents }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let monthLabel = formatter.string(from: monthStart)
            
            months.append(TrendData(
                startDate: monthInterval.start,
                endDate: monthInterval.end,
                amount: totalAmount,
                label: monthLabel
            ))
        }
        
        return months
    }
    
    private var averageSpending: Int {
        let nonZeroPeriods = trendData.filter { $0.amount > 0 }
        guard !nonZeroPeriods.isEmpty else { return 0 }
        return nonZeroPeriods.reduce(0) { $0 + $1.amount } / nonZeroPeriods.count
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
        case .daily: return "Last 7 days" + (!expenseAnalyzer.periodDisplayName.isEmpty ? " (to \(expenseAnalyzer.periodDisplayName))" : "")
        case .weekly: return "Last 5 weeks" + (!expenseAnalyzer.periodDisplayName.isEmpty ? " (to \(expenseAnalyzer.periodDisplayName))" : "")
        case .monthly: return "Last 6 months" + (!expenseAnalyzer.periodDisplayName.isEmpty ? " (to \(expenseAnalyzer.periodDisplayName))" : "")
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
                    Text("Avg: \(averageSpending.currencyString(symbol: "HK$"))")
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
