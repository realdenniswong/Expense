//
//  View.swift
//  Expense
//
//  Created by Dennis Wong on 15/6/2025.
//

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
