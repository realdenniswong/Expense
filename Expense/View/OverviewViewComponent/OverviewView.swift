//
//  OverviewView.swift
//  Expense
//
//  Created by Dennis Wong on 9/6/2025.
//

import SwiftUI
import Charts

struct OverviewView: View {
    
    let expenses: [Expense]
    let settings: Settings
    @State private var selectedPeriod: TimePeriod = .daily
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    init(expenses: [Expense], settings: Settings) {
        self.expenses = expenses
        self.settings = settings
    }
    
    private var expenseAnalyzer: ExpenseAnalyzer {
        ExpenseAnalyzer(expenses: expenses, period: selectedPeriod, selectedDate: selectedDate, settings: settings)
    }
    
    private var dateDisplayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: selectedDate)
    }
    
    private var canGoBack: Bool {
        // Allow going back in time
        return true
    }
    
    private var canGoForward: Bool {
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .daily:
            return !calendar.isDate(selectedDate, inSameDayAs: Date())
        case .weekly:
            guard let currentWeek = calendar.dateInterval(of: .weekOfYear, for: Date()),
                  let selectedWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                return false
            }
            return selectedWeek.start < currentWeek.start
        case .monthly:
            return !calendar.isDate(selectedDate, equalTo: Date(), toGranularity: .month)
        }
    }
    
    private func goToPreviousPeriod() {
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .daily:
            selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        case .weekly:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
        case .monthly:
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func goToNextPeriod() {
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .daily:
            selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        case .weekly:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
        case .monthly:
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Period Selector with Date Navigation (side by side)
            HStack(spacing: 16) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))
            
            ScrollView {
                VStack(spacing: 24) {
                    SpendingSummaryView(expenseAnalyzer: expenseAnalyzer)
                    
                    // Only show SpendingGoalView if settings allow it
                    if settings.shouldShowGoals(for: selectedPeriod) {
                        SpendingGoalView(expenseAnalyzer: expenseAnalyzer, settings: settings)
                    }
                    
                    SpendingTrendsView(expenseAnalyzer: expenseAnalyzer)
                    CategoryAnalysisView(expenseAnalyzer: expenseAnalyzer)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                selectDateButton
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate, selectedPeriod: selectedPeriod)
        }
    }
    
    private var selectDateButton: some View {
        Button(action: {
            showingDatePicker = true
        }) {
            Image(systemName: "calendar")
                .font(.title2)
                .fontWeight(.medium)
        }
    }
    
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let selectedPeriod: TimePeriod
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
