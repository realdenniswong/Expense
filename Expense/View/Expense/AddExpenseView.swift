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
    
    let isEdit: Bool
    let transactionToEdit: Transaction?
    let accountantMode: Bool
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.foodDrink
    @State private var selectedPayment = PaymentMethod.creditCard
    @State private var showingPaymentMethodSheet = false
    @State private var showingCategorySheet = false
    @State private var selectedDate = Date()
    @State private var showSuccessMessage = false
    @State private var successMessageText = ""
    @State private var selectedLocation: String? = nil
    @State private var selectedAddress: String? = nil
    
    @State private var currentRecordIndex: Int? = nil
    @State private var currentEditingTransaction: Transaction? = nil
    
    @State private var originalTitle = ""
    @State private var originalAmount = ""
    @State private var originalCategory = ExpenseCategory.foodDrink
    @State private var originalPayment = PaymentMethod.creditCard
    @State private var originalDate = Date()
    
    @FocusState private var isAmountFieldFocused: Bool
    
    @State private var showingLocationSheet = false
    
    init(accountantMode: Bool = false) {
        self.transactionToEdit = nil
        self.accountantMode = accountantMode
        self.isEdit = false
    }
    
    init(transactionToEdit: Transaction, accountantMode: Bool = false) {
        self.transactionToEdit = transactionToEdit
        self.accountantMode = accountantMode
        self.isEdit = true
    }
    
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
    
    private var leadingButtonIconName: String {
        (isAccountantMode && canGoBack) ? "chevron.left" : "xmark"
    }
    
    private var leadingButtonAction: () -> Void {
        if isAccountantMode && canGoBack {
            return goToPreviousRecord
        } else {
            return { dismiss() }
        }
    }
    
    private var trailingButtonIconName: String {
        (!isAccountantMode || isAddingNewRecord) ? "checkmark" : "chevron.right"
    }
    
    private var trailingButtonAction: () -> Void {
        if isAccountantMode {
            if isAddingNewRecord {
                return saveTransaction
            } else {
                return goToNextRecord
            }
        } else {
            return saveTransaction
        }
    }
    
    private var shouldDisableTrailingButton: Bool {
        return amount.isEmpty
    }
    
    private var accountantModeSubtitle: String {
        if isAddingNewRecord {
            return "Adding new expense"
        } else {
            return "Editing record \(allTransactions.count - currentRecordIndex!) of \(allTransactions.count)"
        }
    }
    
    private var titleText: String {
        if !isAccountantMode {
            return transactionToEdit == nil ? "Add Expense" : "Edit Expense"
        } else {
            return ""
        }
    }
    
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
                Image(systemName: leadingButtonIconName)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: trailingButtonAction) {
                Image(systemName: trailingButtonIconName)
            }
            .tint(shouldDisableTrailingButton ? .secondary : .accentColor)
            .disabled(shouldDisableTrailingButton)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section(header: Text("Amount & Payment")) {
                        amountSection
                    }
                    Section(header: Text("Details")) {
                        detailsSection
                    }
                    Section(header: Text("Location")) {
                        locationSection
                    }
                    Section(header: Text("Date & Time")) {
                        dateSection
                    }

                }
                
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
                toolbarContent
            }
        }
        .onAppear {
            setupInitialState()
        }
    }
    
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
            .contentShape(Rectangle())
            .onTapGesture {
                isAmountFieldFocused = true
            }

            Button {
                showingPaymentMethodSheet = true
            } label: {
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
                .contentShape(Rectangle())
            }
            .sheet(isPresented: $showingPaymentMethodSheet) {
                paymentMethodSheet
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .presentationDragIndicator(.visible)
        }
    }
    @State private var showingDebugAlert = false
    private var detailsSection: some View {
        Section {
            TextField("Title (Optional)", text: $title)
            Button {
                showingCategorySheet = true
            } label: {
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
                .contentShape(Rectangle())
            }
            .sheet(isPresented: $showingCategorySheet) {
                categorySheet
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .presentationDragIndicator(.visible)
        }
    }
    
    private var paymentMethodSheet: some View{
        NavigationStack {
            List {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    HStack {
                        method.icon
                            .frame(width: 20)
                            .foregroundColor(method.color)
                        Text(method.rawValue)
                        Spacer()
                        if method == selectedPayment {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPayment = method
                        showingPaymentMethodSheet = false
                    }
                }
            }
            .padding(.top, -20)
            .navigationTitle("Select Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingPaymentMethodSheet = false
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
    
    private var categorySheet: some View{
        NavigationStack {
            List {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    HStack {
                        category.icon
                            .frame(width: 20)
                            .foregroundColor(category.color)
                        Text(category.rawValue)
                        Spacer()
                        if category == selectedCategory {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCategory = category
                        showingCategorySheet = false
                    }
                }
            }
            .padding(.top, -20)
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingCategorySheet = false
                    }) {
                        Image(systemName: "xmark")
                    }
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
    
    private var locationSection: some View {
        HStack {
            if let loc = selectedLocation, let addr = selectedAddress, !loc.isEmpty, !addr.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text(loc)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(addr)
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
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        )
        .onTapGesture {
            showingLocationSheet = true
        }
        .sheet(isPresented: $showingLocationSheet) {
            LocationSearchView(selectedLocation: $selectedLocation, selectedAddress: $selectedAddress)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func saveCurrentChanges() {
        guard let editingTransaction = currentEditingTransaction else { return }
        
        let currentDesc = title.isEmpty ? "Untitled" : title
        let originalDesc = originalTitle.isEmpty ? "Untitled" : originalTitle
        
        let hasChanges = currentDesc != originalDesc ||
                        amount != originalAmount ||
                        selectedCategory != originalCategory ||
                        selectedPayment != originalPayment ||
                        selectedDate != originalDate
        
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
        saveCurrentChanges()
        
        guard let current = currentRecordIndex else { return }
        
        if current > 0 {
            let newIndex = current - 1
            currentRecordIndex = newIndex
            currentEditingTransaction = allTransactions[newIndex]
            loadTransaction(allTransactions[newIndex])
        } else {
            currentRecordIndex = nil
            clearForm()
        }
    }
    
    private func saveTransaction() {
        let money = Money(amount)
        let finalTitle = title.isEmpty ? "Untitled" : title
        
        if let existingTransaction = transactionToEdit {
            existingTransaction.title = finalTitle
            existingTransaction.amount = money
            existingTransaction.category = selectedCategory
            existingTransaction.date = selectedDate
            existingTransaction.paymentMethod = selectedPayment
            
            try? modelContext.save()
            dismiss()
        } else {
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
                showSuccessNotification(amount: money, title: finalTitle)
                resetForm()
            } else {
                dismiss()
            }
        }
    }
    
    private func resetForm() {
        title = ""
        amount = ""
        selectedDate = Date()
        currentRecordIndex = nil
        currentEditingTransaction = nil
        isAmountFieldFocused = true
    }
    
    private func showSuccessNotification(amount: Money, title: String) {
        successMessageText = "Saved \(amount.formatted)"
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showSuccessMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showSuccessMessage = false
            }
        }
    }
    
    private func setupInitialState() {
        clearForm()
        if isEdit{
            if let transaction = transactionToEdit {
                loadTransaction(transaction)
            }
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

