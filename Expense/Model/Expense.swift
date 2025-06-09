//
//  Expense.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI
import SwiftData

@Model
class Expense {
    var id: UUID
    var expenseDescription: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var order: Int
    var method: PaymentMethod
    
    init(id: UUID = UUID(), description: String, amount: Double, category: ExpenseCategory, date: Date, order: Int, method: PaymentMethod) {
        self.id = id
        self.expenseDescription = description
        self.amount = amount
        self.category = category
        self.date = date
        self.order = order
        self.method = method
    }
    
    var formattedAmount: String {
        return String(format: "HK$%.2f", amount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    
    // Computed property to maintain compatibility with existing code
    var description: String {
        get { expenseDescription }
        set { expenseDescription = newValue }
    }
}

