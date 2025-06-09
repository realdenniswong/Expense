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
            // Update existing expense - SwiftData automatically saves changes to @Model objects
            existingExpense.expenseDescription = description.isEmpty ? "Untitled" : description
            existingExpense.amount = amountValue
            existingExpense.category = selectedCategory
            existingExpense.date = selectedDate
            existingExpense.method = selectedPayment
            
            // Optional: Explicitly save (SwiftData auto-saves, but this ensures immediate persistence)
            try? modelContext.save()
        } else {
            // Create new expense
            let newExpense = Expense(
                description: description.isEmpty ? "Untitled" : description,
                amount: amountValue,
                category: selectedCategory,
                date: selectedDate,
                order: Int(Date().timeIntervalSince1970), // Use timestamp as order for new expenses
                method: selectedPayment
            )
            
            modelContext.insert(newExpense)
            try? modelContext.save()
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
