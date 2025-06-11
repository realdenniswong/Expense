//
//  AddExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let expenseToEdit: Expense?
    
    init() {
        self.expenseToEdit = nil
    }
    
    // Initializer for editing existing expense
    init(expenseToEdit: Expense) {
        self.expenseToEdit = expenseToEdit
    }
    
    @State private var description = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.foodDrink
    @State private var selectedPayment = PaymentMethod.creditCard
    @State private var selectedDate = Date()
    
    @FocusState private var isAmountFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                // Amount input
                Section {
                    HStack {
                        Text("$")
                            .font(.system(size: 30))
                            .foregroundColor(.secondary)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 30))
                            .multilineTextAlignment(.trailing)
                            .focused($isAmountFieldFocused)
                            .onChange(of: amount) { oldValue, newValue in
                                amount = sanitizeAmountInput(newValue)
                            }
                    }
                    .padding()
                    .cornerRadius(8)
                    .contentShape(Rectangle()) // Makes the whole HStack tappable
                    .onTapGesture {
                        isAmountFieldFocused = true
                    }
                    
                    // Payment Method Selection
                    NavigationLink(destination: PaymentSelectionView(paymentMethod: $selectedPayment)) {
                        HStack {
                            selectedPayment.icon
                                
                                .frame(width: 20)
                                .foregroundColor(selectedPayment.color)

                            Text("Payment Method")
                            
                            Spacer()
                            
                            Text(selectedPayment.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Description
                Section {
                    TextField("Description (Optional)", text: $description)
                    // Category Selection
                    NavigationLink(destination: CategorySelectionView(selectedCategory: $selectedCategory)) {
                        HStack {
                            selectedCategory.icon
                                
                                .frame(width: 20)
                                .foregroundColor(selectedCategory.color)

                            Text("Category")
                            
                            Spacer()
                            
                            Text(selectedCategory.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Date
                Section {
                    DatePicker("Date and time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .padding(.vertical, 8)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
        .onAppear {
            // Pre-populate fields if editing
            if let expense = expenseToEdit {
                description = expense.expenseDescription == "Untitled" ? "" : expense.expenseDescription
                amount = expense.amountInCents.currencyString
                selectedCategory = expense.category
                selectedDate = expense.date
                selectedPayment = expense.method
            }
        }
    }
    
    private func saveExpense() {
        let normalizedAmount: String
        
        if amount.contains(".") {
            let parts = amount.split(separator: ".")
            let dollars = String(parts[0])
            let cents = parts.count > 1 ? String(parts[1]) : ""
            
            // Pad cents to 2 digits or truncate if more than 2
            let paddedCents = String(cents.prefix(2).padding(toLength: 2, withPad: "0", startingAt: 0))
            normalizedAmount = dollars + paddedCents
        } else {
            normalizedAmount = amount + "00"  // Add 00 for missing cents
        }
        
        guard let amountInCents = Int(normalizedAmount) else { return }
        
        if let existingExpense = expenseToEdit {
            // Update existing expense - SwiftData automatically saves changes to @Model objects
            existingExpense.expenseDescription = description.isEmpty ? "Untitled" : description
            existingExpense.amountInCents = amountInCents
            existingExpense.category = selectedCategory
            existingExpense.date = selectedDate
            existingExpense.method = selectedPayment
            
            // Optional: Explicitly save (SwiftData auto-saves, but this ensures immediate persistence)
            try? modelContext.save()
        } else {
            // Create new expense
            let newExpense = Expense(
                description: description.isEmpty ? "Untitled" : description,
                amountInCents: amountInCents,
                category: selectedCategory,
                date: selectedDate,
                method: selectedPayment
            )
            
            modelContext.insert(newExpense)
            try? modelContext.save()
        }

        dismiss()
    }
    
    private func sanitizeAmountInput(_ value: String) -> String {
        // Only allow digits and one decimal point
        let filtered = value.filter { $0.isNumber || $0 == "." }
        
        // Split by decimal point
        let components = filtered.split(separator: ".", omittingEmptySubsequences: false)
        
        if components.count > 2 {
            // Too many decimal points, keep only first decimal
            return String(components[0]) + "." + String(components[1])
        } else if components.count == 2 {
            // Limit decimal places to 2
            let integerPart = String(components[0])
            let decimalPart = String(components[1].prefix(2))
            return integerPart + "." + decimalPart
        } else {
            // No decimal point or just one part
            return filtered
        }
    }
}
