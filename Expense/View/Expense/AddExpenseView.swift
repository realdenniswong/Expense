//
//  AddExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    
    let transactionToEdit: Transaction?
    let accountantMode: Bool  // PARAMETER, not from settings
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.foodDrink
    @State private var selectedPayment = PaymentMethod.creditCard
    @State private var selectedDate = Date()
    @State private var showSuccessMessage = false
    @State private var successMessageText = ""
    
    // Navigation state for accountant mode
    @State private var currentRecordIndex: Int? = nil
    @State private var currentEditingTransaction: Transaction? = nil
    
    // Change tracking for auto-save optimization
    @State private var originalTitle = ""
    @State private var originalAmount = ""
    @State private var originalCategory = ExpenseCategory.foodDrink
    @State private var originalPayment = PaymentMethod.creditCard
    @State private var originalDate = Date()
    
    @FocusState private var isAmountFieldFocused: Bool
    
    // UPDATED INITIALIZERS
    init(accountantMode: Bool = false) {
        self.transactionToEdit = nil
        self.accountantMode = accountantMode
    }
    
    init(transactionToEdit: Transaction, accountantMode: Bool = false) {
        self.transactionToEdit = transactionToEdit
        self.accountantMode = accountantMode
    }
    
    // Helper computed properties
    private var isAccountantMode: Bool {
        return accountantMode && transactionToEdit == nil
    }
    
    private var isAddingNewRecord: Bool {
        return currentRecordIndex == nil
    }
    
    private var canGoBack: Bool {
        return isAccountantMode && (currentRecordIndex ?? 0) < allTransactions.count - 1
    }
    
    private var canGoForward: Bool {
        return isAccountantMode && currentRecordIndex != nil && (currentRecordIndex! > 0 || isAddingNewRecord)
    }
    
    private var rightButtonText: String {
        if !isAccountantMode || isAddingNewRecord {
            return "Save"
        } else {
            return "Next"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    amountSection
                    detailsSection
                    dateSection
                }
                .padding(.top, -20)
                
                // Success notification overlay
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
                if isAccountantMode {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Quick Entry")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(isAddingNewRecord ? "Adding new expense" : "Editing record \(allTransactions.count - currentRecordIndex!) of \(allTransactions.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if isAccountantMode && canGoBack {
                        Button("Previous") {
                            goToPreviousRecord()
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(rightButtonText) {
                        handleRightButtonTap()
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
            return transactionToEdit == nil ? "Add Expense" : "Edit Expense"
        } else {
            return ""
        }
    }
    
    // ... rest of the methods remain the same (amountSection, detailsSection, etc.)
    
    private var amountSection: some View {
        Section {
            HStack {
                Text("HK$")
                    .font(.system(size: 22))
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.trailing)
                    .monospacedDigit()
                    .focused($isAmountFieldFocused)
                    .onChange(of: amount) { _, newValue in
                        amount = sanitizeAmountInput(newValue)
                    }
            }
            // .padding(.vertical, 4)
            .contentShape(Rectangle())
            .onTapGesture {
                isAmountFieldFocused = true
            }
            
            NavigationLink(destination: PaymentPickerView(paymentMethod: $selectedPayment)) {
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
    }
    
    private var detailsSection: some View {
        Section {
            TextField("Title (Optional)", text: $title)
            NavigationLink(destination: CategoryPickerView(selectedCategory: $selectedCategory)) {
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
    }
    
    private var dateSection: some View {
        Section {
            DatePicker("Date and time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .padding(.top, -20)
                .padding(.bottom, -40)
        }
    }
    
    // ... (rest of methods remain the same)
    
    private func saveCurrentChanges() {
        // Auto-save current changes before navigating - only if there are actual changes
        guard let editingTransaction = currentEditingTransaction else { return }
        
        // Check if any values have changed
        let currentDesc = title.isEmpty ? "Untitled" : title
        let originalDesc = originalTitle.isEmpty ? "Untitled" : originalTitle
        
        let hasChanges = currentDesc != originalDesc ||
                        amount != originalAmount ||
                        selectedCategory != originalCategory ||
                        selectedPayment != originalPayment ||
                        selectedDate != originalDate
        
        // Only save if there are actual changes
        if hasChanges {
            let money = Money(amount)
            
            if !amount.isEmpty {
                editingTransaction.title = currentDesc
                editingTransaction.amount = money
                editingTransaction.category = selectedCategory
                editingTransaction.date = selectedDate
                editingTransaction.paymentMethod = selectedPayment
                
                try? modelContext.save()
            }
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
        
        if newIndex < allTransactions.count {
            currentRecordIndex = newIndex
            currentEditingTransaction = allTransactions[newIndex]
            loadTransaction(allTransactions[newIndex])
        }
    }
    
    private func goToNextRecord() {
        // Save current changes first
        saveCurrentChanges()
        
        guard let current = currentRecordIndex else { return }
        
        if current > 0 {
            let newIndex = current - 1
            currentRecordIndex = newIndex
            currentEditingTransaction = allTransactions[newIndex]
            loadTransaction(allTransactions[newIndex])
        } else {
            // Go to "add new" mode
            currentRecordIndex = nil
            clearForm()
        }
    }
    
    private func handleRightButtonTap() {
        if isAccountantMode {
            if isAddingNewRecord {
                saveTransaction()
            } else {
                goToNextRecord()
            }
        } else {
            saveTransaction()
        }
    }
    
    private func saveTransaction() {
        let money = Money(amount)
        let finalTitle = title.isEmpty ? "Untitled" : title
        
        if let existingTransaction = transactionToEdit {
            // Update existing transaction
            existingTransaction.title = finalTitle
            existingTransaction.amount = money
            existingTransaction.category = selectedCategory
            existingTransaction.date = selectedDate
            existingTransaction.paymentMethod = selectedPayment
            
            try? modelContext.save()
            dismiss()
        } else {
            // Create new transaction
            let newTransaction = Transaction(
                title: finalTitle,
                amount: money,
                category: selectedCategory,
                date: selectedDate,
                paymentMethod: selectedPayment
            )
            
            modelContext.insert(newTransaction)
            try? modelContext.save()
            
            if isAccountantMode {
                // Reset form for next entry - don't dismiss
                showSuccessNotification(amount: money, title: finalTitle)
                resetForm()
            } else {
                // Normal mode - dismiss the sheet
                dismiss()
            }
        }
    }
    
    private func resetForm() {
        // Clear form fields for next entry
        title = ""
        amount = ""
        selectedDate = Date()
        currentRecordIndex = nil
        currentEditingTransaction = nil
        // Keep category and payment method as they're likely to be reused
        
        // Focus back on amount field for quick entry
        isAmountFieldFocused = true
    }
    
    private func showSuccessNotification(amount: Money, title: String) {
        successMessageText = "Saved \(amount.formatted)"
        
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
    
    private func setupInitialState() {
        if let transaction = transactionToEdit {
            loadTransaction(transaction)
        } else if isAccountantMode {
            currentRecordIndex = nil
            currentEditingTransaction = nil
            clearForm()
        }
    }
    
    private func loadTransaction(_ transaction: Transaction) {
        title = transaction.title == "Untitled" ? "" : transaction.title
        amount = transaction.amount.dollarsAndCents
        selectedCategory = transaction.category
        selectedDate = transaction.date
        selectedPayment = transaction.paymentMethod
        
        // Store original values for change tracking
        originalTitle = title
        originalAmount = amount
        originalCategory = transaction.category
        originalPayment = transaction.paymentMethod
        originalDate = transaction.date
    }
    
    private func clearForm() {
        title = ""
        amount = ""
        selectedCategory = .foodDrink
        selectedPayment = .creditCard
        selectedDate = Date()
        currentEditingTransaction = nil
        
        if isAccountantMode {
            isAmountFieldFocused = true
        }
    }
    
    // ... (rest of methods remain the same)
    
    private func sanitizeAmountInput(_ value: String) -> String {
        let filtered = value.filter { $0.isNumber || $0 == "." }
        let components = filtered.split(separator: ".", omittingEmptySubsequences: false)
        
        if components.count > 2 {
            return String(components[0]) + "." + String(components[1])
        } else if components.count == 2 {
            let integerPart = String(components[0])
            let decimalPart = String(components[1].prefix(2))
            return integerPart + "." + decimalPart
        }
        return filtered
    }
}
