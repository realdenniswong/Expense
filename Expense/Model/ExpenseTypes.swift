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
    case fitness = "Fitness"
    case other = "Other"

    var color: Color {
        switch self {
        case .foodDrink: return .orange
        case .transportation: return .blue
        case .shopping: return .purple
        case .entertainment: return .cyan
        case .billsUtilities: return .red
        case .healthcare: return .green
        case .fitness: return .mint
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
        case .fitness: return Image(systemName: "dumbbell")
        case .other: return Image(systemName: "ellipsis")
        }
    }
}

enum PaymentMethod: String, CaseIterable, Codable {
    case octopus = "Octopus"
    case creditCard = "Credit Card"
    case alipay = "Alipay"
    case alipayHK = "Alipay HK"
    case payMe = "PayMe"
    case fps = "FPS"
    case cash = "Cash"
    
    var color: Color {
        switch self {
        case .octopus: return .orange
        case .creditCard: return .gray
        case .alipay: return .blue
        case .alipayHK: return .purple
        case .payMe: return .red
        case .fps: return .yellow
        case .cash: return .green
        }
    }
    
    var icon: Image {
        switch self {
        case .alipay:
            return Image(systemName: "a.circle")
        case .payMe:
            return Image(systemName: "p.circle")
        case .creditCard:
            return Image(systemName: "creditcard")
        case .fps:
            return Image(systemName: "arrow.left.arrow.right")
        case .cash:
            return Image(systemName: "banknote")
        case .octopus:
            return Image(systemName: "wave.3.right")
        case .alipayHK:
            return Image(systemName: "a.circle")
        }
    }
}
