//
//  SummaryView.swift
//  Expense
//
//  Created by Dennis Wong on 9/6/2025.
//

import SwiftUI
import Charts

struct OverviewView: View {
    
    let expenses: [Expense]
    @State private var selectedPeriod: TimePeriod = .monthly
    
    init(expenses: [Expense]) {
        self.expenses = expenses
    }
    
    private var filteredExpenses: FilteredExpenses {
        FilteredExpenses(expenses: expenses, period: selectedPeriod)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Period Selector at the top
            VStack {
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            
            ScrollView {
                VStack(spacing: 24) {
                    // Always show spending summary (shows today, week, month regardless of filter)
                    SpendingSummaryView(filteredExpenses: filteredExpenses)
                    
                    // Period-aware goals
                    SpendingGoalView(filteredExpenses: filteredExpenses)
                    
                    // Trends based on selected period
                    SpendingTrendsView(expenses: expenses, selectedPeriod: selectedPeriod)
                    
                    CategoryAnalysisView(filteredExpenses: filteredExpenses)

                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}
