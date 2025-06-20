//
//  Money.swift
//  Expense
//
//  Created by Dennis Wong on 16/6/2025.
//

import SwiftUI
import SwiftData
import Foundation

// Money value type
struct Money: Codable, Equatable {
    let cents: Int
    
    init(cents: Int) {
        self.cents = cents
    }
    
    init(_ dollars: Double) {
        self.cents = Int(dollars * 100)
    }
    
    init(_ dollarsString: String) {
        if dollarsString.contains(".") {
            let parts = dollarsString.split(separator: ".")
            let dollars = Int(String(parts[0])) ?? 0
            let cents = parts.count > 1 ? String(parts[1]).prefix(2) : "00"
            let paddedCents = String(cents.padding(toLength: 2, withPad: "0", startingAt: 0))
            self.cents = dollars * 100 + (Int(paddedCents) ?? 0)
        } else {
            let dollars = Int(dollarsString) ?? 0
            self.cents = dollars * 100
        }
    }
    
    var formatted: String {
        let dollars = cents / 100
        let remainingCents = cents % 100
        return String(format: "HK$%d.%02d", dollars, remainingCents)
    }
    
    var dollarsOnly: String {
        String(cents / 100)
    }
    
    var dollarsAndCents: String {
        let dollars = cents / 100
        let remainingCents = cents % 100
        return String(format: "%d.%02d", dollars, remainingCents)
    }
    
    static let zero = Money(cents: 0)
    
    static func + (lhs: Money, rhs: Money) -> Money {
        Money(cents: lhs.cents + rhs.cents)
    }
    
    static func - (lhs: Money, rhs: Money) -> Money {
        Money(cents: lhs.cents - rhs.cents)
    }
}

// Main transaction model
@Model
class Transaction {
    var id: UUID
    var title: String
    var amount: Money
    var category: ExpenseCategory
    var date: Date
    var paymentMethod: PaymentMethod
    var location: String?
    var address: String?
    
    var weeklyGoalCategoriesRaw: [String] = []
    
    init(id: UUID = UUID(), title: String, amount: Money, category: ExpenseCategory, date: Date, paymentMethod: PaymentMethod, location: String? = nil, address: String? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.paymentMethod = paymentMethod
        self.location = location
        self.address = address
    }
}

