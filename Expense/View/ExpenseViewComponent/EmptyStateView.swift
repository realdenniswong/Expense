//
//  EmptyStateView.swift
//  Expense
//
//  Created by Dennis Wong on 9/6/2025.
//
import SwiftUI

struct EmptyStateView : View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 16) {
                // Icon
                Image(systemName: "banknote")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                // Title
                Text("No Expenses Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Description
                Text("Track your spending by adding your first expense")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Hint
                Text("Tap the + button to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

