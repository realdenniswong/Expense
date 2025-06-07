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
    
    
    
    var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum ExpenseCategory: String, CaseIterable, Codable {
    case foodDrink = "Food & Drink"
    case transportation = "Transportation"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case billsUtilities = "Bills & Utilities"
    case healthcare = "Healthcare"
    case other = "Other"
    
    var color: Color {
        switch self {
        case .foodDrink: return .orange
        case .transportation: return .blue
        case .shopping: return .purple
        case .entertainment: return .pink
        case .billsUtilities: return .red
        case .healthcare: return .green
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .foodDrink: return "fork.knife"
        case .transportation: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "tv.fill"
        case .billsUtilities: return "bolt.fill"
        case .healthcare: return "cross.fill"
        case .other: return "ellipsis"
        }
    }
}
