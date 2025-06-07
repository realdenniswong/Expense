//
//  Expense.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//


import SwiftUI

struct Expense: Identifiable, Codable {
    let id: UUID
    var description: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var order: Int // New property for ordering within the same date
    var method: PaymentMethod
    
    
    var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


