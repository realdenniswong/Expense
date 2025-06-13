//
//  CategoryIconView.swift
//  Expense
//
//  Created by Dennis Wong on 14/6/2025.
//
import SwiftUI

struct CategoryIconView: View {
    let category: ExpenseCategory
    let size: CGFloat
    let iconSize: CGFloat
    
    init(category: ExpenseCategory, size: CGFloat = 40, iconSize: CGFloat = 16) {
        self.category = category
        self.size = size
        self.iconSize = iconSize
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(category.color.opacity(0.15))
                .frame(width: size, height: size)
            
            category.icon
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(category.color)
        }
    }
}
