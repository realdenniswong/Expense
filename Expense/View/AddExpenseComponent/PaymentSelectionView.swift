//
//  PaymentSelectionView.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI

struct PaymentSelectionView: View {
    @Binding var paymentMethod: PaymentMethod
    @Environment(\.dismiss) var dismiss // To dismiss the current view after selection
    
    var body: some View {
        List(PaymentMethod.allCases, id: \.self) { method in
            Button(action: {
                paymentMethod = method
                dismiss()
            }) {
                HStack {
                    method.icon
                        .foregroundColor(method.color)
                        .frame(width: 20, height: 20)
                    Text(method.rawValue)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle()) // Removes button styling
        }
        .navigationTitle("Select Payment Method")
    }
}
