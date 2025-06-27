//
//  OverviewView.swift
//  Expense
//
//  Created by Dennis Wong on 9/6/2025.
//

import SwiftUI
import Charts

struct OverviewView: View {
    let transactions: [Transaction]
    let settings: Settings
    @State private var selectedPeriod: TimePeriod = .daily
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    init(transactions: [Transaction], settings: Settings) {
        self.transactions = transactions
        self.settings = settings
    }
    
    private var transactionAnalyzer: TransactionAnalyzer {
        TransactionAnalyzer(transactions: transactions, period: selectedPeriod, selectedDate: selectedDate, settings: settings)
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Period Selector
            HStack(spacing: 16) {
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
                    SpendingSummaryView(transactionAnalyzer: transactionAnalyzer, selectedPeriod: selectedPeriod, settings: settings)
                    
                    if settings.shouldShowGoals(for: selectedPeriod) {
                        SpendingGoalView(transactionAnalyzer: transactionAnalyzer, settings: settings)
                    }
                    
                    SpendingTrendsView(transactionAnalyzer: transactionAnalyzer)
                    CategoryAnalysisView(transactionAnalyzer: transactionAnalyzer)
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
                .font(.system(size: 18))
                .fontWeight(.medium)
                .frame(width: 24, height: 24)
        }
    }
}
