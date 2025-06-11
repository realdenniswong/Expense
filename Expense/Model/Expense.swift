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
    var amountInCents: Int
    var category: ExpenseCategory
    var date: Date
    var method: PaymentMethod
    
    init(id: UUID = UUID(), description: String, amountInCents: Int, category: ExpenseCategory, date: Date, method: PaymentMethod) {
        self.id = id
        self.expenseDescription = description
        self.amountInCents = amountInCents
        self.category = category
        self.date = date
        self.method = method
    }
}

