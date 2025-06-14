//
//  AddExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//
import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @Query private var settingsArray: [Settings]
    let expenseToEdit: Expense?
    
    init() {
        self.expenseToEdit = nil
    }
    
    // Initializer for editing existing expense
    init(expenseToEdit: Expense) {
        self.expenseToEdit = expenseToEdit
    }
    
    // Get the single settings object, or create one if none exists
    private var settings: Settings {
        if let existingSettings = settingsArray.first {
            return existingSettings
        } else {
            // Create the single settings object if none exists
            let newSettings = Settings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }
    }
    
    @State private var description = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.foodDrink
    @State private var selectedPayment = PaymentMethod.creditCard
    @State private var selectedDate = Date()
    @State private var showSuccessMessage = false
    @State private var successMessageText = ""
    
    // Navigation state for accountant mode
    @State private var currentRecordIndex: Int? = nil // nil means adding new record
    @State private var currentEditingExpense: Expense? = nil // The expense being edited
    
    // Change tracking for auto-save optimization
    @State private var originalDescription = ""
    @State private var originalAmount = ""
    @State private var originalCategory = ExpenseCategory.foodDrink
    @State private var originalPayment = PaymentMethod.creditCard
    @State private var originalDate = Date()
    
    @FocusState private var isAmountFieldFocused: Bool
    
    // Helper computed properties
    private var isAccountantMode: Bool {
        return settings.accountantMode && expenseToEdit == nil
    }
    
    private var isAddingNewRecord: Bool {
        return currentRecordIndex == nil
    }
    
    private var canGoBack: Bool {
        return isAccountantMode && (currentRecordIndex ?? 0) < allExpenses.count - 1
    }
    
    private var canGoForward: Bool {
        return isAccountantMode && currentRecordIndex != nil && (currentRecordIndex! > 0 || isAddingNewRecord)
    }
    
    // Dynamic save button
    private var rightButtonConfig: (text: String, icon: String) {
        if !isAccountantMode {
            return ("Save", "")
        } else if isAddingNewRecord {
            return ("", "checkmark")
        } else {
            return ("", "chevron.right")
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    // Amount input
                    Section {
                        HStack {
                            Text("HK$")
                                .font(.system(size: 30))
                                .foregroundColor(.secondary)
                            
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 30, weight: .regular, design: .default))
                                .multilineTextAlignment(.trailing)
                                .focused($isAmountFieldFocused)
                                .onChange(of: amount) { oldValue, newValue in
                                    amount = sanitizeAmountInput(newValue)
                                }
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
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
                    
                    // Record navigation info (only in accountant mode)
                    if isAccountantMode {
                        Section {
                            HStack {
                                if isAddingNewRecord {
                                    Text("Adding new expense")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Editing record \(currentRecordIndex! + 1) of \(allExpenses.count)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if !isAddingNewRecord {
                                    Text("Auto-saves")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.orange.opacity(0.1))
                                        .foregroundColor(.orange)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                // Success notification overlay (Apple-style)
                if showSuccessMessage {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 20, weight: .medium))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(successMessageText)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text("\(selectedCategory.rawValue) • \(selectedPayment.rawValue)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: .infinity)
                                .fill(.regularMaterial)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSuccessMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isAccountantMode && canGoBack {
                        Button {
                            goToPreviousRecord()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        handleRightButtonTap()
                    } label: {
                        if rightButtonConfig.icon.isEmpty {
                            Text(rightButtonConfig.text)
                        } else {
                            Image(systemName: rightButtonConfig.icon)
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                    }
                    .disabled(isAddingNewRecord && amount.isEmpty)
                }
            }
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    private var titleText: String {
        if !isAccountantMode {
            return expenseToEdit == nil ? "Add Expense" : "Edit Expense"
        } else {
            return "Accountant Mode"
        }
    }
    
    private func setupInitialState() {
        if let expense = expenseToEdit {
            // Editing existing expense (non-accountant mode)
            loadExpense(expense)
        } else if isAccountantMode {
            // Start in "add new" mode
            currentRecordIndex = nil
            currentEditingExpense = nil
            clearForm()
        }
    }
    
    private func loadExpense(_ expense: Expense) {
        description = expense.expenseDescription == "Untitled" ? "" : expense.expenseDescription
        amount = expense.amountInCents.currencyString
        selectedCategory = expense.category
        selectedDate = expense.date
        selectedPayment = expense.method
        
        // Store original values for change tracking
        originalDescription = description
        originalAmount = amount
        originalCategory = expense.category
        originalPayment = expense.method
        originalDate = expense.date
    }
    
    private func clearForm() {
        description = ""
        amount = ""
        selectedCategory = .foodDrink
        selectedPayment = .creditCard
        selectedDate = Date()
        currentEditingExpense = nil
        
        if isAccountantMode {
            isAmountFieldFocused = true
        }
    }
    
    private func saveCurrentChanges() {
        // Auto-save current changes before navigating - only if there are actual changes
        guard let editingExpense = currentEditingExpense else { return }
        
        // Check if any values have changed
        let currentDesc = description.isEmpty ? "Untitled" : description
        let originalDesc = originalDescription.isEmpty ? "Untitled" : originalDescription
        
        let hasChanges = currentDesc != originalDesc ||
                        amount != originalAmount ||
                        selectedCategory != originalCategory ||
                        selectedPayment != originalPayment ||
                        selectedDate != originalDate
        
        // Only save if there are actual changes
        if hasChanges {
            let normalizedAmount: String
            
            if amount.contains(".") {
                let parts = amount.split(separator: ".")
                let dollars = String(parts[0])
                let cents = parts.count > 1 ? String(parts[1]) : ""
                
                let paddedCents = String(cents.prefix(2).padding(toLength: 2, withPad: "0", startingAt: 0))
                normalizedAmount = dollars + paddedCents
            } else {
                normalizedAmount = amount + "00"
            }
            
            if let amountInCents = Int(normalizedAmount), !amount.isEmpty {
                editingExpense.expenseDescription = currentDesc
                editingExpense.amountInCents = amountInCents
                editingExpense.category = selectedCategory
                editingExpense.date = selectedDate
                editingExpense.method = selectedPayment
                
                try? modelContext.save()
                print("Auto-saved changes to record") // Debug - can remove later
            }
        } else {
            print("No changes detected, skipping save") // Debug - can remove later
        }
    }
    
    private func goToPreviousRecord() {
        // Save current changes first
        saveCurrentChanges()
        
        let newIndex: Int
        if let current = currentRecordIndex {
            newIndex = current + 1
        } else {
            newIndex = 0
        }
        
        if newIndex < allExpenses.count {
            currentRecordIndex = newIndex
            currentEditingExpense = allExpenses[newIndex]
            loadExpense(allExpenses[newIndex])
        }
    }
    
    private func goToNextRecord() {
        // Save current changes first
        saveCurrentChanges()
        
        guard let current = currentRecordIndex else { return }
        
        if current > 0 {
            let newIndex = current - 1
            currentRecordIndex = newIndex
            currentEditingExpense = allExpenses[newIndex]
            loadExpense(allExpenses[newIndex])
        } else {
            // Go to "add new" mode
            currentRecordIndex = nil
            clearForm()
        }
    }
    
    private func handleRightButtonTap() {
        if isAccountantMode {
            if isAddingNewRecord {
                saveExpense()
            } else {
                goToNextRecord()
            }
        } else {
            saveExpense()
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
            
            // Always dismiss when editing
            dismiss()
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
            
            if isAccountantMode {
                // Reset form for next entry - don't dismiss
                showSuccessNotification(amount: amountInCents, description: description.isEmpty ? "Untitled" : description)
                resetForm()
            } else {
                // Normal mode - dismiss the sheet
                dismiss()
            }
        }
    }
    
    private func resetForm() {
        // Clear form fields for next entry
        description = ""
        amount = ""
        selectedDate = Date()
        currentRecordIndex = nil
        currentEditingExpense = nil
        // Keep category and payment method as they're likely to be reused
        
        // Focus back on amount field for quick entry
        isAmountFieldFocused = true
    }
    
    private func showSuccessNotification(amount: Int, description: String) {
        successMessageText = "Saved \(amount.currencyString(symbol: "HK$"))"
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showSuccessMessage = true
        }
        
        // Auto-hide after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showSuccessMessage = false
            }
        }
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
