//
//  AmountDisplayView.swift
//  Expense
//
//  Created by Dennis Wong on 15/6/2025.
//
import SwiftUI

struct AmountDisplayView: View {
    let amount: Money
    let style: AmountStyle
    
    enum AmountStyle {
        case large      // For main displays
        case medium     // For list items
        case small      // For secondary info
        case compact    // For tight spaces
        
        var font: Font {
            switch self {
            case .large: return .system(size: 24, weight: .bold, design: .rounded)
            case .medium: return .headline.weight(.semibold)
            case .small: return .subheadline.weight(.medium)
            case .compact: return .caption.weight(.medium)
            }
        }
    }
    
    init(amount: Money, style: AmountStyle = .medium) {
        self.amount = amount
        self.style = style
    }
    
    var body: some View {
        Text(amount.formatted)
            .font(style.font)
            .monospacedDigit()
    }
}
