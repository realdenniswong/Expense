//
//  PaymentMethod.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI

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
