//
//  PickerView.swift
//  Expense
//
//  Created by Dennis Wong on 14/6/2025.
//
import SwiftUI

// Generic reusable picker view
struct PickerView<T: CaseIterable & RawRepresentable & Hashable>: View where T.RawValue == String {
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
                    
                    // Show checkmark for selected item
                    if item == selectedItem {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .font(.body.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// Specific implementations using the generic picker
struct CategoryPickerView: View {
    @Binding var selectedCategory: ExpenseCategory
    
    var body: some View {
        PickerView(
            selectedItem: $selectedCategory,
            title: "Category",
            iconProvider: { $0.icon },
            colorProvider: { $0.color }
        )
    }
}

struct PaymentPickerView: View {
    @Binding var paymentMethod: PaymentMethod
    
    var body: some View {
        PickerView(
            selectedItem: $paymentMethod,
            title: "Payment Method",
            iconProvider: { $0.icon },
            colorProvider: { $0.color }
        )
    }
}
