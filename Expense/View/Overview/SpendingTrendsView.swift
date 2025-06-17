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
        case .weekly: return getTrendData(for: .weekOfYear, periods: 5)
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
                periodDate = calendar.date(byAdding: .day, value: -(periods-1-i), to: selectedDate) ?? selectedDate
                let start = calendar.startOfDay(for: periodDate)
                let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
                interval = DateInterval(start: start, end: end)
            case .weekOfYear:
                let selectedWeekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) ?? DateInterval(start: selectedDate, duration: 0)
                let weekStart = calendar.date(byAdding: .weekOfYear, value: -(periods-1-i), to: selectedWeekInterval.start) ?? selectedDate
                interval = calendar.dateInterval(of: .weekOfYear, for: weekStart) ?? DateInterval(start: weekStart, duration: 0)
            case .month:
                let selectedMonthInterval = calendar.dateInterval(of: .month, for: selectedDate) ?? DateInterval(start: selectedDate, duration: 0)
                let monthStart = calendar.date(byAdding: .month, value: -(periods-1-i), to: selectedMonthInterval.start) ?? selectedDate
                interval = calendar.dateInterval(of: .month, for: monthStart) ?? DateInterval(start: monthStart, duration: 0)
            default:
                continue
            }
            
            let periodTransactions = transactions.filter { interval.contains($0.date) }
            let enabledCategories = settings?.enabledCategories(for: selectedPeriod) ?? ExpenseCategory.allCases
            let filteredTransactions = periodTransactions.filter { enabledCategories.contains($0.category) }
            let totalAmount = filteredTransactions.reduce(Money.zero) { $0 + $1.amount }
            
            let formatter = DateFormatter()
            formatter.dateFormat = component == .month ? "MMM" : "MMM d"
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
        case .weekly: return "Last 5 weeks"
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
            .barChartStyle()
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
        case .daily: return tempAnalyzer.dailyDisplayName
        case .weekly: return tempAnalyzer.weeklyDisplayName
        case .monthly: return tempAnalyzer.monthlyDisplayName
        }
    }
}
