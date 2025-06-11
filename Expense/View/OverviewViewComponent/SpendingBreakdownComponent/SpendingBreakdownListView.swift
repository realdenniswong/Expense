//
//  SpendingBreakdownList.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//
import SwiftUI

struct SpendingBreakdownListView: View {
    
    let categorySpendings: [CategorySpending]
    
    init(categorySpendingTotals: [CategorySpending]) {
        self.categorySpendings = categorySpendingTotals
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVStack(spacing: 12) {
                ForEach(categorySpendings, id: \.category.rawValue) { categorySpending in
                    SpendingBreakdownRowView(categorySpending: categorySpending)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}
