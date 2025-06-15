//
//  View.swift
//  Expense
//
//  Created by Dennis Wong on 15/6/2025.
//

// Convenience initializers for common use cases
extension AmountDisplayView {
    static func large(_ amountInCents: Int) -> AmountDisplayView {
        AmountDisplayView(amountInCents: amountInCents, style: .large)
    }
    
    static func medium(_ amountInCents: Int) -> AmountDisplayView {
        AmountDisplayView(amountInCents: amountInCents, style: .medium)
    }
    
    static func small(_ amountInCents: Int) -> AmountDisplayView {
        AmountDisplayView(amountInCents: amountInCents, style: .small)
    }
    
    static func compact(_ amountInCents: Int) -> AmountDisplayView {
        AmountDisplayView(amountInCents: amountInCents, style: .compact)
    }
}
