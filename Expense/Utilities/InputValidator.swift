//
//  InputValidator.swift
//  Expense
//
//  Created by Dennis Wong on 21/6/2025.
//


struct InputValidator {
    static func sanitizeAmountInput(_ value: String) -> String {
        let filtered = value.filter { $0.isNumber || $0 == "." }
        let components = filtered.split(separator: ".", omittingEmptySubsequences: false)
        
        if components.count > 2 {
            return String(components[0]) + "." + String(components[1])
        } else if components.count == 2 {
            let integerPart = String(components[0])
            let decimalPart = String(components[1].prefix(2))
            return integerPart + "." + decimalPart
        }
        return filtered
    }
}
