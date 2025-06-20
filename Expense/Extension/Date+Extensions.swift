//
//  FormatCurrency.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//

import Foundation

extension Date {
    // Existing extensions (keep these)
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return Self.timeFormatter.string(from: self)
    }
    
    // New unified formatters to reduce repetition
    var mediumDateString: String {
        Self.mediumDateFormatter.string(from: self)
    }
    
    var shortDateString: String {
        Self.shortDateFormatter.string(from: self)
    }
    
    private static let mediumDateFormatter = makeFormatter(dateStyle: .medium)
    private static let shortDateFormatter = makeFormatter(dateStyle: .short)
    private static let timeFormatter = makeFormatter(dateStyle: .none, timeStyle: .short, format: "hh:mm a")
    
    private static func makeFormatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style = .none, format: String? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        if let format = format {
            formatter.dateFormat = format
        }
        return formatter
    }
}
