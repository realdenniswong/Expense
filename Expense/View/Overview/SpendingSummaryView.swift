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
    let settings: Settings
    
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
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.top, 8)
    }
    
    // MARK: - Computed display name properties
    
    private var dailyDisplayName: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: transactionAnalyzer.selectedDate)
    }
    
    private var weeklyDisplayName: String {
        let calendar = Calendar.current
        let weekday = settings.weeklyStartDay
        let startOfWeek = calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: transactionAnalyzer.selectedDate) - weekday + 7) % 7, to: calendar.startOfDay(for: transactionAnalyzer.selectedDate)) ?? transactionAnalyzer.selectedDate
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    private var monthlyDisplayName: String {
        let calendar = Calendar.current
        let startOfMonth = calendar.monthlySummaryStart(for: transactionAnalyzer.selectedDate, startDay: settings.monthlyStartDay)
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth).flatMap { calendar.date(byAdding: .day, value: -1, to: $0) } ?? startOfMonth
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: startOfMonth)
    }
    
    // MARK: - Computed Money amount properties
    
    private var dailyAmount: Money {
        transactionAnalyzer.customDayAmount(startHour: settings.dailyStartHour)
    }
    
    private var weeklyAmount: Money {
        transactionAnalyzer.customWeekAmount(startDay: settings.weeklyStartDay)
    }
    
    private var monthlyAmount: Money {
        transactionAnalyzer.customMonthAmount(monthOffset: 0, startDay: settings.monthlyStartDay)
    }
    
    // MARK: - Main & Secondary Period Titles and Amounts
    
    private var mainPeriodTitle: String {
        switch selectedPeriod {
        case .daily:
            return dailyDisplayName
        case .weekly:
            return weeklyDisplayName
        case .monthly:
            return monthlyDisplayName
        }
    }
    
    private var mainPeriodAmount: Money {
        switch selectedPeriod {
        case .daily:
            return dailyAmount
        case .weekly:
            return weeklyAmount
        case .monthly:
            return monthlyAmount
        }
    }
    
    private var leftPeriodTitle: String {
        switch selectedPeriod {
        case .daily:
            return weeklyDisplayName
        case .weekly:
            return dailyDisplayName
        case .monthly:
            return monthlyDisplayName
        }
    }
    
    private var leftPeriodAmount: Money {
        switch selectedPeriod {
        case .daily:
            return weeklyAmount
        case .weekly:
            return dailyAmount
        case .monthly:
            return dailyAmount
        }
    }
    
    private var rightPeriodTitle: String {
        switch selectedPeriod {
        case .daily:
            return monthlyDisplayName
        case .weekly:
            return monthlyDisplayName
        case .monthly:
            return weeklyDisplayName
        }
    }
    
    private var rightPeriodAmount: Money {
        switch selectedPeriod {
        case .daily:
            return monthlyAmount
        case .weekly:
            return monthlyAmount
        case .monthly:
            return weeklyAmount
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

// MARK: - Calendar Extension for monthlySummaryStart

extension Calendar {
    /// Returns the start date of a monthly summary period based on a reference date and a custom monthly start day.
    /// Clamps the start day to the number of days in the month.
    /// - Parameters:
    ///   - referenceDate: The date from which to calculate the monthly summary start.
    ///   - startDay: The day of month which the monthly summary should start (1...31).
    /// - Returns: The start date of the monthly summary period.
    func monthlySummaryStart(for referenceDate: Date, startDay: Int) -> Date {
        let components = dateComponents([.year, .month], from: referenceDate)
        guard let year = components.year, let month = components.month else {
            return referenceDate
        }
        
        // Determine the number of days in the month
        let range = self.range(of: Calendar.Component.day, in: Calendar.Component.month, for: referenceDate)
        let daysInMonth = range?.count ?? 30
        
        // Clamp the start day to be within the valid range for the month
        let clampedStartDay = min(max(startDay, 1), daysInMonth)
        
        var startComponents = DateComponents(year: year, month: month, day: clampedStartDay)
        
        guard let startDate = self.date(from: startComponents) else {
            return referenceDate
        }
        
        // If the start date is in the future relative to the reference date,
        // shift to the previous month start date.
        if startDate > referenceDate {
            // Calculate previous month
            var previousMonthComponents = DateComponents(year: year, month: month - 1)
            if previousMonthComponents.month == 0 {
                previousMonthComponents.month = 12
                previousMonthComponents.year = year - 1
            }
            let prevMonthDate = self.date(from: previousMonthComponents) ?? referenceDate
            
            let prevRange = self.range(of: Calendar.Component.day, in: Calendar.Component.month, for: prevMonthDate)
            let prevDaysInMonth = prevRange?.count ?? 30
            
            let clampedPrevStartDay = min(max(startDay, 1), prevDaysInMonth)
            
            var prevStartComponents = DateComponents(year: previousMonthComponents.year, month: previousMonthComponents.month, day: clampedPrevStartDay)
            
            return self.date(from: prevStartComponents) ?? referenceDate
        }
        
        return startDate
    }
}
