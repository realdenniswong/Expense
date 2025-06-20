//
//  SelectionSheet.swift
//  Expense
//
//  Created by Dennis Wong on 21/6/2025.
//

import SwiftUI

struct PaymentMethodSelectionSheet: View {
    let selectedMethod: PaymentMethod
    let onSelect: (PaymentMethod) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    SelectionRow(
                        icon: method.icon,
                        iconColor: method.color,
                        title: method.rawValue,
                        isSelected: method == selectedMethod
                    ) {
                        onSelect(method)
                    }
                }
            }
            .navigationTitle("Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct CategorySelectionSheet: View {
    let selectedCategory: ExpenseCategory
    let onSelect: (ExpenseCategory) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    SelectionRow(
                        icon: category.icon,
                        iconColor: category.color,
                        title: category.rawValue,
                        isSelected: category == selectedCategory
                    ) {
                        onSelect(category)
                    }
                }
            }
            .navigationTitle("Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct SelectionRow: View {
    let icon: Image
    let iconColor: Color
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            icon
                .frame(width: 20)
                .foregroundColor(iconColor)
            Text(title)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}
