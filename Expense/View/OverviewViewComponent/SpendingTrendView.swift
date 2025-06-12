//
//  SpendingTrendView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//

import SwiftUI
import Charts

struct SpendingTrendsView: View {
    let expenses: [Expense]
    let selectedPeriod: TimePeriod
    
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
        let now = Date()
        var days: [TrendData] = []
        
        for i in 0..<7 {
            let dayDate = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            let dayStart = calendar.startOfDay(for: dayDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            
            let dayExpenses = expenses.filter { expense in
                expense.date >= dayStart && expense.date < dayEnd
            }
            
            let totalAmount = dayExpenses.reduce(0) { $0 + $1.amountInCents }
            
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
        
        return days.reversed()
    }
    
    private func getWeeklyData() -> [TrendData] {
        let calendar = Calendar.current
        let now = Date()
        var weeks: [TrendData] = []
        
        for i in 0..<5 {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .weekOfYear, value: -i, to: now) ?? now)?.start ?? now
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? now
            
            let weekExpenses = expenses.filter { expense in
                expense.date >= weekStart && expense.date <= weekEnd
            }
            
            let totalAmount = weekExpenses.reduce(0) { $0 + $1.amountInCents }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let weekLabel = formatter.string(from: weekStart)
            
            weeks.append(TrendData(
                startDate: weekStart,
                endDate: weekEnd,
                amount: totalAmount,
                label: weekLabel
            ))
        }
        
        return weeks.reversed()
    }
    
    private func getMonthlyData() -> [TrendData] {
        let calendar = Calendar.current
        let now = Date()
        var months: [TrendData] = []
        
        for i in 0..<6 {
            let monthDate = calendar.date(byAdding: .month, value: -i, to: now) ?? now
            let monthStart = calendar.dateInterval(of: .month, for: monthDate)?.start ?? now
            let monthEnd = calendar.dateInterval(of: .month, for: monthDate)?.end ?? now
            
            let monthExpenses = expenses.filter { expense in
                expense.date >= monthStart && expense.date < monthEnd
            }
            
            let totalAmount = monthExpenses.reduce(0) { $0 + $1.amountInCents }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let monthLabel = formatter.string(from: monthDate)
            
            months.append(TrendData(
                startDate: monthStart,
                endDate: monthEnd,
                amount: totalAmount,
                label: monthLabel
            ))
        }
        
        return months.reversed()
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
        case .daily: return "Last 7 days"
        case .weekly: return "Last 5 weeks"
        case .monthly: return "Last 6 months"
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
                    y: .value("Amount", trend.amount)
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
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}
