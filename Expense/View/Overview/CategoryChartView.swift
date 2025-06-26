//
//  CategoryChartView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI
import Charts

struct CategoryChartView: View {
    let categorySpendingTotals: [CategorySpending]
    let period: TimePeriod
    
    var body: some View {
        if categorySpendingTotals.isEmpty {
            EmptyChartView(period: period)
                .padding(.horizontal, 20)
        } else {
            Chart(categorySpendingTotals, id: \.category.rawValue) { element in
                SectorMark(
                    angle: .value("Amount", element.amountInCent)
                )
                .foregroundStyle(element.category.color)
                .opacity(0.8)
            }
            .chartStyle(.pie)
            .padding(.horizontal, 10)
            .animation(.easeInOut(duration: 0.3), value: period)
        }
    }
}

struct PaymentMethodChartView: View {
    let paymentMethodSpendingTotals: [PaymentMethodSpending]
    let period: TimePeriod
    
    var body: some View {
        if paymentMethodSpendingTotals.isEmpty {
            EmptyChartView(period: period)
                .padding(.horizontal, 20)
        } else {
            Chart(paymentMethodSpendingTotals, id: \.paymentMethod.rawValue) { element in
                SectorMark(
                    angle: .value("Amount", element.amountInCent)
                )
                .foregroundStyle(element.paymentMethod.color)
                .opacity(0.8)
            }
            .chartStyle(.pie)
            .padding(.horizontal, 10)
            .animation(.easeInOut(duration: 0.3), value: period)
        }
    }
}
