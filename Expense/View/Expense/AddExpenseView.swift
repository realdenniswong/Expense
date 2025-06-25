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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    let transactionToEdit: Transaction?
    let accountantMode: Bool

    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.foodDrink
    @State private var selectedPayment = PaymentMethod.creditCard
    @State private var selectedDate = Date()
    @State private var selectedLocation: String?
    @State private var selectedAddress: String?
    @State private var selectedLatitude: Double?
    @State private var selectedLongitude: Double?

    // Added original* state variables for tracking
    @State private var originalTitle = ""
    @State private var originalAmount = ""
    @State private var originalCategory = ExpenseCategory.foodDrink
    @State private var originalPayment = PaymentMethod.creditCard
    @State private var originalDate = Date()
    @State private var originalLocation: String?
    @State private var originalAddress: String?
    @State private var originalLatitude: Double?
    @State private var originalLongitude: Double?

    @State private var showingPaymentMethodSheet = false
    @State private var showingCategorySheet = false
    @State private var showingLocationSheet = false
    @State private var showSuccessMessage = false
    @State private var successMessageText = ""
    @FocusState private var isAmountFieldFocused: Bool

    @State private var accountantManager: AccountantModeManager?
    @State private var showCheckmark = false

    init(accountantMode: Bool = false) {
        self.transactionToEdit = nil
        self.accountantMode = accountantMode
    }

    init(transactionToEdit: Transaction, accountantMode: Bool = false) {
        self.transactionToEdit = transactionToEdit
        self.accountantMode = accountantMode
    }

    // Computed property to detect if any fields differ from original
    private var isDirty: Bool {
        title != originalTitle ||
        amount != originalAmount ||
        selectedCategory != originalCategory ||
        selectedPayment != originalPayment ||
        !Calendar.current.isDate(selectedDate, equalTo: originalDate, toGranularity: .minute) ||
        selectedLocation != originalLocation ||
        selectedAddress != originalAddress ||
        selectedLatitude != originalLatitude ||
        selectedLongitude != originalLongitude
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if accountantMode && transactionToEdit == nil {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor((accountantManager?.canGoBack ?? false) ? .accentColor : .secondary)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                guard accountantManager?.canGoBack == true else { return }
                                accountantManager?.saveChangesIfNeeded(
                                    currentTitle: title,
                                    currentAmount: amount,
                                    currentCategory: selectedCategory,
                                    currentPayment: selectedPayment,
                                    currentDate: selectedDate,
                                    in: modelContext
                                )
                                // After saving, update original fields to current
                                updateOriginalFieldsToCurrent()
                                if let transaction = accountantManager?.goToPreviousRecord() {
                                    loadTransaction(transaction)
                                }
                            }
                            .frame(width: 40, alignment: .center)

                        Spacer()

                        Text(accountantManager?.displaySubtitle ?? "")
                            .font(.headline)

                        Spacer()

                        // Fixed width container for right side icons
                        Group {
                            if accountantManager?.canGoForward == true {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .contentShape(Rectangle())
                                    .frame(width: 24, alignment: .center)
                                    .onTapGesture {
                                        guard accountantManager?.canGoForward == true else { return }
                                        accountantManager?.saveChangesIfNeeded(
                                            currentTitle: title,
                                            currentAmount: amount,
                                            currentCategory: selectedCategory,
                                            currentPayment: selectedPayment,
                                            currentDate: selectedDate,
                                            in: modelContext
                                        )
                                        // After saving, update original fields to current
                                        updateOriginalFieldsToCurrent()
                                        if let transaction = accountantManager?.goToNextRecord() {
                                            loadTransaction(transaction)
                                        } else {
                                            clearForm()
                                        }
                                    }
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .opacity(0)
                                    .frame(width: 24, alignment: .center)
                            }
                        }
                        .frame(width: 40, alignment: .center)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemGroupedBackground))
                }

                Form {
                    Section(header: Text("Amount & Payment")) {
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

                    Section(header: Text("Details")) {
                        TextField("Title (Optional)", text: $title)

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

                    Section(header: Text("Location")) {
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
                                selectedAddress: $selectedAddress,
                                selectedLatitude: $selectedLatitude,
                                selectedLongitude: $selectedLongitude
                            )
                        }
                    }

                    Section(header: Text("Date & Time")) {
                        DatePicker("Date and time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .padding(.top, -20)
                            .padding(.bottom, -40)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle((!accountantMode || transactionToEdit != nil) ? (transactionToEdit == nil ? "Add Expense" : "Edit Expense") : "Accountant Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !accountantMode {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if accountantMode && (accountantManager?.canGoBack ?? false) {
                                accountantManager?.saveChangesIfNeeded(
                                    currentTitle: title,
                                    currentAmount: amount,
                                    currentCategory: selectedCategory,
                                    currentPayment: selectedPayment,
                                    currentDate: selectedDate,
                                    in: modelContext
                                )
                                updateOriginalFieldsToCurrent()
                                if let transaction = accountantManager?.goToPreviousRecord() {
                                    loadTransaction(transaction)
                                }
                            } else {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: (accountantMode && (accountantManager?.canGoBack ?? false)) ? "chevron.left" : "xmark")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            saveTransaction()
                        } label: {
                            Image(systemName: "checkmark")
                        }
                        .tint(amount.isEmpty ? .secondary : .accentColor)
                        .disabled(amount.isEmpty)
                    }
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if accountantManager?.isAddingNewRecord ?? true {
                                saveTransaction()
                            } else {
                                accountantManager?.switchToAddNewRecordMode()
                                clearForm()
                            }
                        } label: {
                            Image(systemName: (accountantManager?.isAddingNewRecord ?? true) ? "checkmark" : "plus")
                        }
                        .tint(amount.isEmpty ? .secondary : .accentColor)
                        .disabled(amount.isEmpty)
                    }
                }
            }
            .autoHidingSuccessToast(
                message: successMessageText,
                subtitle: "\(selectedCategory.rawValue) • \(selectedPayment.rawValue)",
                isShowing: $showSuccessMessage
            )
        }
        .onAppear {
            if let transaction = transactionToEdit {
                loadTransaction(transaction)
                showCheckmark = !((accountantManager?.isAddingNewRecord ?? true))
            } else if accountantMode && transactionToEdit == nil {
                accountantManager = AccountantModeManager(allTransactions: allTransactions)
                clearForm()
            } else {
                clearForm()
            }
        }
        .onDisappear {
            if accountantMode, let _ = accountantManager?.currentEditingTransaction {
                accountantManager?.saveChangesIfNeeded(
                    currentTitle: title,
                    currentAmount: amount,
                    currentCategory: selectedCategory,
                    currentPayment: selectedPayment,
                    currentDate: selectedDate,
                    in: modelContext
                )
            }
        }
    }

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
                    location: selectedLocation,
                    address: selectedAddress,
                    latitude: selectedLatitude,
                    longitude: selectedLongitude,
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
                    location: selectedLocation,
                    address: selectedAddress,
                    latitude: selectedLatitude,
                    longitude: selectedLongitude,
                    in: modelContext
                )

                if accountantMode && transactionToEdit == nil {
                    successMessageText = "Saved \(money.formatted)"
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showSuccessMessage = true
                    }
                    title = ""
                    amount = ""
                    selectedDate = Date()
                    isAmountFieldFocused = true
                } else {
                    dismiss()
                }
            }
        } catch {
            print("Failed to save transaction: \(error)")
        }
        showCheckmark = false
    }

    private func loadTransaction(_ transaction: Transaction) {
        title = transaction.title == "Untitled" ? "" : transaction.title
        amount = transaction.amount.dollarsAndCents
        selectedCategory = transaction.category
        selectedDate = transaction.date
        selectedPayment = transaction.paymentMethod
        selectedLocation = transaction.location ?? ""
        selectedAddress = transaction.address ?? ""
        selectedLatitude = transaction.latitude
        selectedLongitude = transaction.longitude
        
        // Set original* fields to loaded values
        originalTitle = title
        originalAmount = amount
        originalCategory = selectedCategory
        originalPayment = selectedPayment
        originalDate = selectedDate
        originalLocation = selectedLocation
        originalAddress = selectedAddress
        originalLatitude = selectedLatitude
        originalLongitude = selectedLongitude
        
        if accountantMode && transactionToEdit == nil {
            showCheckmark = true // show checkmark container, actual visibility controlled by isDirty
        } else {
            showCheckmark = false
        }
    }

    private func clearForm() {
        title = ""
        amount = ""
        selectedCategory = .foodDrink
        selectedPayment = .creditCard
        selectedDate = Date()
        selectedLocation = nil
        selectedAddress = nil
        selectedLatitude = nil
        selectedLongitude = nil

        // Reset original fields to match cleared form
        originalTitle = ""
        originalAmount = ""
        originalCategory = .foodDrink
        originalPayment = .creditCard
        originalDate = selectedDate
        originalLocation = nil
        originalAddress = nil
        originalLatitude = nil
        originalLongitude = nil

        showCheckmark = false

        if accountantMode && transactionToEdit == nil {
            isAmountFieldFocused = true
        }
    }
    
    // Helper to update original* fields to current values after save
    private func updateOriginalFieldsToCurrent() {
        originalTitle = title
        originalAmount = amount
        originalCategory = selectedCategory
        originalPayment = selectedPayment
        originalDate = selectedDate
        originalLocation = selectedLocation
        originalAddress = selectedAddress
        originalLatitude = selectedLatitude
        originalLongitude = selectedLongitude
    }
}

