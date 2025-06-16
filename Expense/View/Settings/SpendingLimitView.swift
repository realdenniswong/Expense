//
//  SpendingLimitView.swift
//  Expense
//
//  Created by Dennis Wong on [Current Date].
//

import SwiftUI
import SwiftData

struct SpendingLimitView: View {
    @Bindable var settings: Settings
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            Section {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    GoalAmountRow(category: category, settings: settings, modelContext: modelContext)
                }
            } header: {
                Text("Monthly Spending Goals")
            } footer: {
                Text("Set your monthly spending limit for each category. Daily and weekly goals will be calculated automatically based on these amounts.")
            }
        }
        .navigationTitle("Spending Limits")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct GoalAmountRow: View {
    let category: ExpenseCategory
    @Bindable var settings: Settings
    let modelContext: ModelContext
    @State private var amountText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            // Category icon and name
            CategoryIcon(category: category, size: 40, iconSize: 16)
            
            Text(category.rawValue)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            // Amount input - Apple native style
            HStack(spacing: 2) {
                Text("HK$")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                TextField("0", text: $amountText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.body)
                    .textFieldStyle(.plain)
                    .frame(width: 60)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        saveAmount()
                        isTextFieldFocused = false
                    }
                    .onChange(of: amountText) { oldValue, newValue in
                        // Only allow numbers
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            amountText = filtered
                        }
                    }
                    .onChange(of: isTextFieldFocused) { oldValue, newValue in
                        if !newValue {
                            saveAmount()
                        }
                    }
            }
        }
        .padding(.vertical, -4)
        .contentShape(Rectangle())
        .onTapGesture {
            isTextFieldFocused = true
        }
        .onAppear {
            loadCurrentAmount()
        }
    }
    
    private func loadCurrentAmount() {
        let currentMoney = settings.goalMoney(for: category)
        amountText = String(currentMoney.cents / 100) // Convert cents to dollars
    }
    
    private func saveAmount() {
        guard let dollars = Int(amountText), dollars >= 0 else {
            loadCurrentAmount() // Reset to current value if invalid
            return
        }
        let money = Money(cents: dollars * 100)
        settings.setGoalMoney(money, for: category)
        
        // Save to SwiftData
        do {
            try modelContext.save()
        } catch {
            print("Failed to save goal amount: \(error)")
        }
    }
}
