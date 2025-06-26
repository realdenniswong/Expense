//
//  PaymentMethodIcon.swift
//  Expense
//
//  Created by Dennis Wong on 26/6/2025.
//
import SwiftUI

struct PaymentMethodIcon: View {
    let paymentMethod: PaymentMethod
    let size: CGFloat
    let iconSize: CGFloat
    
    init(paymentMethod: PaymentMethod, size: CGFloat = 40, iconSize: CGFloat = 16) {
        self.paymentMethod = paymentMethod
        self.size = size
        self.iconSize = iconSize
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(paymentMethod.color.opacity(0.15))
                .frame(width: size, height: size)
            
            paymentMethod.icon
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(paymentMethod.color)
        }
    }
}
