//
//  CategoryAnalysisView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI

struct CategoryAnalysisView: View {
    
    enum ChartMode: String, CaseIterable, Identifiable {
        case category
        case paymentMethod
        
        var id: String { rawValue }
    }
    
    @State private var selectedChartMode: ChartMode = .category
    @State private var showAllCategoryBreakdown = false
    @State private var showAllPaymentMethodBreakdown = false
    
    let transactionAnalyzer: TransactionAnalyzer
    
    private var customCategorySpendingTotals: [CategorySpending] {
        let categoryTotals = Dictionary(grouping: transactionAnalyzer.customFilteredTransactions, by: { $0.category })
            .mapValues { transactions in
                transactions.reduce(Money.zero) { $0 + $1.amount }.cents
            }
        let filteredCategoryTotals = categoryTotals.filter { _, amount in amount > 0 }
        let totalAmount = filteredCategoryTotals.values.reduce(0, +)
        return filteredCategoryTotals.map { categoryTotal in
            CategorySpending(
                category: categoryTotal.key,
                amountInCent: categoryTotal.value,
                percentage: totalAmount > 0 ?
                    Int(round((Double(categoryTotal.value) / Double(totalAmount)) * 100)) : 0
            )
        }
        .sorted { $0.amountInCent > $1.amountInCent }
    }
    
    private var customPaymentMethodSpendingTotals: [PaymentMethodSpending] {
        let paymentMethodTotals = Dictionary(grouping: transactionAnalyzer.customFilteredTransactions, by: { $0.paymentMethod })
            .mapValues { transactions in
                transactions.reduce(Money.zero) { $0 + $1.amount }.cents
            }
        let filteredPaymentMethodTotals = paymentMethodTotals.filter { _, amount in amount > 0 }
        let totalAmount = filteredPaymentMethodTotals.values.reduce(0, +)
        return filteredPaymentMethodTotals.map { paymentMethodTotal in
            PaymentMethodSpending(
                paymentMethod: paymentMethodTotal.key,
                amountInCent: paymentMethodTotal.value,
                percentage: totalAmount > 0 ?
                    Int(round((Double(paymentMethodTotal.value) / Double(totalAmount)) * 100)) : 0
            )
        }
        .sorted { $0.amountInCent > $1.amountInCent }
    }
    
    var body: some View {
        let categorySpendingTotals = customCategorySpendingTotals
        let paymentMethodSpendingTotals = customPaymentMethodSpendingTotals
        
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Spending Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(transactionAnalyzer.periodDisplayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Picker("Select Chart Type", selection: $selectedChartMode) {
                Text("Category").tag(ChartMode.category)
                Text("Payment Method").tag(ChartMode.paymentMethod)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if(selectedChartMode == ChartMode.category){
                
                // Chart
                CategoryChartView(
                    categorySpendingTotals: categorySpendingTotals,
                    period: transactionAnalyzer.period
                )
                
                // Breakdown section
                if !categorySpendingTotals.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        LazyVStack(spacing: 12) {
                            ForEach((showAllCategoryBreakdown || categorySpendingTotals.count <= 3) ? categorySpendingTotals : Array(categorySpendingTotals.prefix(3)), id: \.category.rawValue) { categorySpending in
                                CategoryBreakdownRow(categorySpending: categorySpending)
                            }
                            if categorySpendingTotals.count > 3 {
                                Button(action: { showAllCategoryBreakdown.toggle() }) {
                                    Text(showAllCategoryBreakdown ? "Show Less" : "Show All")
                                        .font(.callout)
                                        .foregroundStyle(Color.accentColor)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                                .transaction { $0.disablesAnimations = true }
                            }
                        }
                    }
                }
            } else{
                // Chart
                PaymentMethodChartView(
                    paymentMethodSpendingTotals: paymentMethodSpendingTotals,
                    period: transactionAnalyzer.period
                )
                
                // Breakdown section
                if !paymentMethodSpendingTotals.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        LazyVStack(spacing: 12) {
                            ForEach((showAllPaymentMethodBreakdown || paymentMethodSpendingTotals.count <= 3) ? paymentMethodSpendingTotals : Array(paymentMethodSpendingTotals.prefix(3)), id: \.paymentMethod.rawValue) { paymentMethodSpending in
                                PaymentMethodBreakdownRow(paymentMethodSpending: paymentMethodSpending)
                            }
                            if paymentMethodSpendingTotals.count > 3 {
                                Button(action: { showAllPaymentMethodBreakdown.toggle() }) {
                                    Text(showAllPaymentMethodBreakdown ? "Show Less" : "Show All")
                                        .font(.callout)
                                        .foregroundStyle(Color.accentColor)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                                .transaction { $0.disablesAnimations = true }
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct CategoryBreakdownRow: View {
    let categorySpending: CategorySpending
    
    var body: some View {
        HStack {
            CategoryIcon(category: categorySpending.category)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(categorySpending.category.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(categorySpending.percentage)% of total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Use Money type directly instead of deprecated Int extension
            Text(Money(cents: categorySpending.amountInCent).formatted)
                .font(.headline)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

struct PaymentMethodBreakdownRow: View {
    let paymentMethodSpending: PaymentMethodSpending
    
    var body: some View {
        HStack {
            PaymentMethodIcon(paymentMethod: paymentMethodSpending.paymentMethod)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(paymentMethodSpending.paymentMethod.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(paymentMethodSpending.percentage)% of total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Use Money type directly instead of deprecated Int extension
            Text(Money(cents: paymentMethodSpending.amountInCent).formatted)
                .font(.headline)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

