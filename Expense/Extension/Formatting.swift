//
//  FormatCurrency.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//

import SwiftUI

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
