//
//  SuccessToast.swift
//  Expense
//
//  Created by Dennis Wong on 21/6/2025.
//

import SwiftUI

struct SuccessToast: View {
    let message: String
    let subtitle: String?
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            VStack {
                toastCard
                Spacer()
            }
            .padding(.top, 8)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    private var toastCard: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 20, weight: .medium))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: .infinity)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - View Extension for Easy Usage
extension View {
    func successToast(message: String, subtitle: String? = nil, isShowing: Binding<Bool>) -> some View {
        ZStack {
            self
            SuccessToast(message: message, subtitle: subtitle, isShowing: isShowing)
        }
    }
}

// MARK: - Auto-hiding Toast Modifier
struct AutoHidingSuccessToast: ViewModifier {
    let message: String
    let subtitle: String?
    @Binding var isShowing: Bool
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .successToast(message: message, subtitle: subtitle, isShowing: $isShowing)
            .onChange(of: isShowing) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isShowing = false
                        }
                    }
                }
            }
    }
}

extension View {
    func autoHidingSuccessToast(
        message: String,
        subtitle: String? = nil,
        isShowing: Binding<Bool>,
        duration: Double = 1.5
    ) -> some View {
        modifier(AutoHidingSuccessToast(
            message: message,
            subtitle: subtitle,
            isShowing: isShowing,
            duration: duration
        ))
    }
}
