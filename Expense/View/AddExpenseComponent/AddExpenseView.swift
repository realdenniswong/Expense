//
//  AddExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//
import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var expenseManager: ExpenseManager
    @Environment(\.dismiss) private var dismiss
    let expenseToEdit: Expense?
    
    init(expenseManager: ExpenseManager) {
        self.expenseManager = expenseManager
        self.expenseToEdit = nil
    }
    
    // Initializer for editing existing expense
    init(expenseManager: ExpenseManager, expenseToEdit: Expense) {
        self.expenseManager = expenseManager
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
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
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
                description = expense.description == "Untitled" ? "" : expense.description
                amount = String(format: "%.2f", expense.amount)
                selectedCategory = expense.category
                selectedDate = expense.date
                selectedPayment = expense.method
            }
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        if let existingExpense = expenseToEdit {
            // Update existing expense - keep the same order
            let updatedExpense = Expense(
                id: existingExpense.id,
                description: description.isEmpty ? "Untitled" : description,
                amount: amountValue,
                category: selectedCategory,
                date: selectedDate,
                order: existingExpense.order, // Keep existing order
                method: selectedPayment
            )
            expenseManager.updateExpense(updatedExpense)
        } else {
            // Create new expense - order will be assigned by the store
            let newExpense = Expense(
                id: UUID(),
                description: description.isEmpty ? "Untitled" : description,
                amount: amountValue,
                category: selectedCategory,
                date: selectedDate,
                order: 0,  // Placeholder - will be set by addExpense
                method: selectedPayment
            )
            expenseManager.addExpense(newExpense)
        }

        dismiss()
    }
    
    private func sanitizeAmountInput(_ value: String) -> String {
        let components = value.split(separator: ".")
        
        if components.count > 1 {
            let integerPart = components[0]
            let decimalPart = components[1]
            
            if decimalPart.count > 2 {
                let truncatedDecimal = decimalPart.prefix(2)
                return "\(integerPart).\(truncatedDecimal)"
            } else {
                return value
            }
        } else {
            return value
        }
    }
}
