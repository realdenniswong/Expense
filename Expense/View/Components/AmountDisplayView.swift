//
//  AmountDisplayView.swift
//  Expense
//
//  Created by Dennis Wong on 15/6/2025.
//
import SwiftUI

struct AmountDisplayView: View {
    let amountInCents: Int
    let style: AmountStyle
    let symbol: String
    
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
    
    init(amountInCents: Int, style: AmountStyle = .medium, symbol: String = "HK$") {
        self.amountInCents = amountInCents
        self.style = style
        self.symbol = symbol
    }
    
    var body: some View {
        Text(amountInCents.currencyString(symbol: symbol))
            .font(style.font)
            .monospacedDigit()
    }
}
