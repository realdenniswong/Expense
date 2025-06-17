//
//  View+Extensions
//  Expense
//
//  Created by Dennis Wong on 15/6/2025.
//
import SwiftUI

extension AmountDisplayView {
    static func large(_ amount: Money) -> AmountDisplayView {
        AmountDisplayView(amount: amount, style: .large)
    }
    
    static func medium(_ amount: Money) -> AmountDisplayView {
        AmountDisplayView(amount: amount, style: .medium)
    }
    
    static func small(_ amount: Money) -> AmountDisplayView {
        AmountDisplayView(amount: amount, style: .small)
    }
    
    static func compact(_ amount: Money) -> AmountDisplayView {
        AmountDisplayView(amount: amount, style: .compact)
    }
}

extension View {
    func cardBackground(padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(16)
    }
}
