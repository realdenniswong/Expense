//
//  ExpenseCategory.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//
import SwiftUI

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
        case .entertainment: return .cyan
        case .billsUtilities: return .red
        case .healthcare: return .green
        case .other: return .brown
        }
    }
    
    var icon: Image {
        switch self {
        case .foodDrink: return Image(systemName: "fork.knife")
        case .transportation: return Image(systemName: "car.fill")
        case .shopping: return Image(systemName: "bag.fill")
        case .entertainment: return Image(systemName: "tv.fill")
        case .billsUtilities: return Image(systemName: "bolt.fill")
        case .healthcare: return Image(systemName: "cross.fill")
        case .other: return Image(systemName: "ellipsis")
        }
    }
}
