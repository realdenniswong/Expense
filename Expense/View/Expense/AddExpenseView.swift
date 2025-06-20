//
//  AddExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI
import SwiftData
import CoreLocation

struct AddExpenseView: View {
    // MARK: - Dependencies
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    
    // MARK: - Configuration
    let transactionToEdit: Transaction?
    let accountantMode: Bool
    
    // MARK: - Form Data
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.foodDrink
    @State private var selectedPayment = PaymentMethod.creditCard
    @State private var selectedDate = Date()
    @State private var selectedLocation: String?
    @State private var selectedAddress: String?
    
    // MARK: - UI State
    @State private var showingPaymentMethodSheet = false
    @State private var showingCategorySheet = false
    @State private var showingLocationSheet = false
    @State private var showSuccessMessage = false
    @State private var successMessageText = ""
    @FocusState private var isAmountFieldFocused: Bool
    
    
    @State private var accountantManager: AccountantModeManager?
    
    // MARK: - Computed Properties
    
    private var isEdit: Bool { transactionToEdit != nil }
    private var isAccountantMode: Bool { accountantMode && transactionToEdit == nil }
    private var shouldDisableTrailingButton: Bool { amount.isEmpty }
    
    private var canGoBack: Bool {
        accountantManager?.canGoBack ?? false
    }

    private var canGoForward: Bool {
        accountantManager?.canGoForward ?? false
    }

    private var accountantModeSubtitle: String {
        accountantManager?.displaySubtitle ?? ""
    }
    
    private var navigationTitle: String {
        if !isAccountantMode {
            return transactionToEdit == nil ? "Add Expense" : "Edit Expense"
        } else {
            return ""
        }
    }
    
    // MARK: - Initializers
    
    init(accountantMode: Bool = false) {
        self.transactionToEdit = nil
        self.accountantMode = accountantMode
    }
    
    init(transactionToEdit: Transaction, accountantMode: Bool = false) {
        self.transactionToEdit = transactionToEdit
        self.accountantMode = accountantMode
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            formContent
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .autoHidingSuccessToast(
                    message: successMessageText,
                    subtitle: "\(selectedCategory.rawValue) • \(selectedPayment.rawValue)",
                    isShowing: $showSuccessMessage
                )
        }
        .onAppear { setupInitialState() }
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var formContent: some View {
        Form {
            amountAndPaymentSection
            detailsSection
            locationSection
            dateSection
        }
    }
    
    // MARK: - Form Sections
    
    @ViewBuilder
    private var amountAndPaymentSection: some View {
        Section(header: Text("Amount & Payment")) {
            amountInputRow
            paymentMethodRow
        }
    }
    
    @ViewBuilder
    private var amountInputRow: some View {
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
                    amount = InputValidator.sanitizeAmountInput(newValue)
                }
        }
        .contentShape(Rectangle())
        .onTapGesture { isAmountFieldFocused = true }
    }
    
    @ViewBuilder
    private var paymentMethodRow: some View {
        Button { showingPaymentMethodSheet = true } label: {
            HStack {
                selectedPayment.icon
                    .frame(width: 20)
                    .foregroundColor(selectedPayment.color)
                Text("Payment Method")
                    .tint(.primary)
                Spacer()
                Text(selectedPayment.rawValue)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingPaymentMethodSheet) {
            PaymentMethodSelectionSheet(
                selectedMethod: selectedPayment,
                onSelect: { method in
                    selectedPayment = method
                    showingPaymentMethodSheet = false
                }
            )
        }
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section(header: Text("Details")) {
            TextField("Title (Optional)", text: $title)
            categorySelectionRow
        }
    }
    
    @ViewBuilder
    private var categorySelectionRow: some View {
        Button { showingCategorySheet = true } label: {
            HStack {
                selectedCategory.icon
                    .frame(width: 20)
                    .foregroundColor(selectedCategory.color)
                Text("Category")
                    .tint(.primary)
                Spacer()
                Text(selectedCategory.rawValue)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingCategorySheet) {
            CategorySelectionSheet(
                selectedCategory: selectedCategory,
                onSelect: { category in
                    selectedCategory = category
                    showingCategorySheet = false
                }
            )
        }
    }
    
    @ViewBuilder
    private var locationSection: some View {
        Section(header: Text("Location")) {
            locationRow
        }
    }
    
    @ViewBuilder
    private var locationRow: some View {
        HStack {
            if let location = selectedLocation, let address = selectedAddress,
               !location.isEmpty, !address.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text(location)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            } else {
                Text("Add Location")
                    .foregroundColor(Color(uiColor: .placeholderText))
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { showingLocationSheet = true }
        .sheet(isPresented: $showingLocationSheet) {
            LocationSearchView(
                selectedLocation: $selectedLocation,
                selectedAddress: $selectedAddress
            )
        }
    }
    
    @ViewBuilder
    private var dateSection: some View {
        Section(header: Text("Date & Time")) {
            DatePicker("Date and time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .padding(.top, -20)
                .padding(.bottom, -40)
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if isAccountantMode {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Quick Entry")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(accountantModeSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: leadingButtonAction) {
                Image(systemName: leadingButtonIcon)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: trailingButtonAction) {
                Image(systemName: trailingButtonIcon)
            }
            .tint(shouldDisableTrailingButton ? .secondary : .accentColor)
            .disabled(shouldDisableTrailingButton)
        }
    }
    
    // MARK: - Toolbar Actions & Icons
    
    private var leadingButtonIcon: String {
        (isAccountantMode && canGoBack) ? "chevron.left" : "xmark"
    }
    
    private var leadingButtonAction: () -> Void {
        if isAccountantMode && canGoBack {
            return goToPreviousRecord
        } else {
            return { dismiss() }
        }
    }
    
    private var trailingButtonIcon: String {
        (!isAccountantMode || accountantManager?.isAddingNewRecord ?? true) ? "checkmark" : "chevron.right"
    }
    
    private var trailingButtonAction: () -> Void {
        if isAccountantMode {
            if accountantManager?.isAddingNewRecord ?? true {
                return saveTransaction
            } else {
                return goToNextRecord
            }
        } else {
            return saveTransaction
        }
    }
    
    // MARK: - Transaction Management
    
    private func saveTransaction() {
        let money = Money(amount)
        let finalTitle = title.isEmpty ? "Untitled" : title
        
        do {
            if let existingTransaction = transactionToEdit {
                try TransactionService.updateTransaction(
                    existingTransaction,
                    title: finalTitle,
                    amount: money,
                    category: selectedCategory,
                    date: selectedDate,
                    paymentMethod: selectedPayment,
                    in: modelContext
                )
                dismiss()
            } else {
                _ = try TransactionService.createTransaction(
                    title: finalTitle,
                    amount: money,
                    category: selectedCategory,
                    date: selectedDate,
                    paymentMethod: selectedPayment,
                    in: modelContext
                )
                
                if isAccountantMode {
                    showSuccessNotification(amount: money, title: finalTitle)
                    resetFormForNextEntry()
                } else {
                    dismiss()
                }
            }
        } catch {
            // Handle error if needed
            print("Failed to save transaction: \(error)")
        }
    }
    
    // MARK: - Accountant Mode Navigation
    
    private func goToPreviousRecord() {
        accountantManager?.saveChangesIfNeeded(
            currentTitle: title,
            currentAmount: amount,
            currentCategory: selectedCategory,
            currentPayment: selectedPayment,
            currentDate: selectedDate,
            in: modelContext
        )
        
        if let transaction = accountantManager?.goToPreviousRecord() {
            loadTransaction(transaction)
        }
    }

    private func goToNextRecord() {
        accountantManager?.saveChangesIfNeeded(
            currentTitle: title,
            currentAmount: amount,
            currentCategory: selectedCategory,
            currentPayment: selectedPayment,
            currentDate: selectedDate,
            in: modelContext
        )
        
        if let transaction = accountantManager?.goToNextRecord() {
            loadTransaction(transaction)
        } else {
            clearForm()
        }
    }
    
    // MARK: - Form Management
    
    private func setupInitialState() {
        clearForm()
        if isEdit, let transaction = transactionToEdit {
            loadTransaction(transaction)
        } else if isAccountantMode {
            accountantManager = AccountantModeManager(allTransactions: allTransactions)
            clearForm()
        }
    }
    
    private func loadTransaction(_ transaction: Transaction) {
        title = transaction.title == "Untitled" ? "" : transaction.title
        amount = transaction.amount.dollarsAndCents
        selectedCategory = transaction.category
        selectedDate = transaction.date
        selectedPayment = transaction.paymentMethod
    }
    
    private func clearForm() {
        title = ""
        amount = ""
        selectedCategory = .foodDrink
        selectedPayment = .creditCard
        selectedDate = Date()
        
        if isAccountantMode {
            isAmountFieldFocused = true
        }
    }
    
    private func resetFormForNextEntry() {
        title = ""
        amount = ""
        selectedDate = Date()
        isAmountFieldFocused = true
    }
    
    // MARK: - UI Feedback
    
    private func showSuccessNotification(amount: Money, title: String) {
        successMessageText = "Saved \(amount.formatted)"
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showSuccessMessage = true
        }
    }
}
