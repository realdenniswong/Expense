//
//  FormatCurrency.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//

import SwiftUI

extension Int {
    // Without currency symbol
    var currencyString: String {
        let dollars = self / 100
        let cents = self % 100
        return String(format: "%d.%02d", dollars, cents)
    }
    
    // With custom currency symbol
    func currencyString(symbol: String) -> String {
        let dollars = self / 100
        let cents = self % 100
        return String(format: "%@%d.%02d", symbol, dollars, cents)
    }
}

extension Date {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: self)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
