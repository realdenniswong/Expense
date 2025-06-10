//
//  SummaryView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct TotalExpensesView: View {
    @Environment(\.colorScheme) private var colorScheme
    let totalExpenses: Double
    
    private var cardBackground: Color {
        colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : Color(.systemBackground)
    }
    
    // Dynamic padding that matches system behavior across devices
    private var horizontalPadding: CGFloat {
        // iPhone 15/16 Pro uses larger padding than smaller devices
        UIScreen.main.bounds.width > 400 ? 20 : 16
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Expenses")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", totalExpenses))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        // Use dynamic padding that matches insetGrouped lists across devices
        // .padding(.horizontal, horizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}
