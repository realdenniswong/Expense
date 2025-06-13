//
//  CardBackground.swift
//  Expense
//
//  Created by Dennis Wong on 14/6/2025.
//
import SwiftUI

struct CardBackground: ViewModifier {
    let padding: CGFloat
    
    init(padding: CGFloat = 20) {
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
    }
}

extension View {
    func cardBackground(padding: CGFloat = 20) -> some View {
        modifier(CardBackground(padding: padding))
    }
}
