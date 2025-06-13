//
//  SelectionView.swift
//  Expense
//
//  Created by Dennis Wong on 14/6/2025.
//
import SwiftUI

// Generic reusable selection view
struct SelectionView<T: CaseIterable & RawRepresentable & Hashable>: View where T.RawValue == String {
    @Binding var selectedItem: T
    @Environment(\.dismiss) var dismiss
    let title: String
    let iconProvider: (T) -> Image
    let colorProvider: (T) -> Color
    
    var body: some View {
        List(Array(T.allCases), id: \.self) { item in
            Button(action: {
                selectedItem = item
                dismiss()
            }) {
                HStack {
                    iconProvider(item)
                        .foregroundColor(colorProvider(item))
                        .frame(width: 20, height: 20)
                    Text(item.rawValue)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle(title)
    }
}

// Simplified CategorySelectionView
struct CategorySelectionView: View {
    @Binding var selectedCategory: ExpenseCategory
    
    var body: some View {
        SelectionView(
            selectedItem: $selectedCategory,
            title: "Select Category",
            iconProvider: { $0.icon },
            colorProvider: { $0.color }
        )
    }
}

// Simplified PaymentSelectionView
struct PaymentSelectionView: View {
    @Binding var paymentMethod: PaymentMethod
    
    var body: some View {
        SelectionView(
            selectedItem: $paymentMethod,
            title: "Select Payment Method",
            iconProvider: { $0.icon },
            colorProvider: { $0.color }
        )
    }
}
