//
//  CategorySelectionView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//
import SwiftUI

struct CategorySelectionView: View {
    @Binding var selectedCategory: ExpenseCategory
    @Environment(\.dismiss) var dismiss // To dismiss the current view after selection
    
    var body: some View {
        List(ExpenseCategory.allCases, id: \.self) { category in
            Button(action: {
                selectedCategory = category
                dismiss()
            }) {
                HStack {
                    category.icon
                        .foregroundColor(category.color)
                        .frame(width: 20, height: 20)
                    Text(category.rawValue)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle()) // Removes button styling
        }
        .navigationTitle("Select Category")
    }
}
