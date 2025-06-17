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
        return formatter.string(from: self)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    // New unified formatters to reduce repetition
    var mediumDateString: String {
        Self.mediumDateFormatter.string(from: self)
    }
    
    var shortDateString: String {
        Self.shortDateFormatter.string(from: self)
    }
    
    // Static formatters (created once, reused)
    private static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
