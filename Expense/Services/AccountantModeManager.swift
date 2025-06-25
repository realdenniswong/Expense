//
//  AccountantModeManager.swift
//  Expense
//
//  Created by Dennis Wong on 21/6/2025.
//

import SwiftUI
import SwiftData

@Observable
class AccountantModeManager {
    struct OriginalValues {
        var title = ""
        var amount = ""
        var category = ExpenseCategory.foodDrink
        var payment = PaymentMethod.creditCard
        var date = Date()
        var location: String? = nil
        var address: String? = nil
    }
    
    private(set) var currentRecordIndex: Int?
    private(set) var currentEditingTransaction: Transaction?
    private let allTransactions: [Transaction]
    
    // Original values for change tracking
    private(set) var original = OriginalValues()
    
    init(allTransactions: [Transaction]) {
        self.allTransactions = allTransactions
    }
    
    // MARK: - Navigation State
    
    var isAddingNewRecord: Bool {
        currentRecordIndex == nil
    }
    
    var canGoBack: Bool {
        (currentRecordIndex ?? 0) < allTransactions.count - 1
    }
    
    var canGoForward: Bool {
        currentRecordIndex != nil && (currentRecordIndex! > 0 || isAddingNewRecord)
    }
    
    var displaySubtitle: String {
        isAddingNewRecord
            ? "New expense"
            : "Editing record \(allTransactions.count - (currentRecordIndex ?? 0)) of \(allTransactions.count)"
    }
    
    // MARK: - Navigation Actions
    
    func goToRecord(offset: Int) -> Transaction? {
        let newIndex: Int
        if let current = currentRecordIndex {
            newIndex = current + offset
        } else {
            newIndex = offset > 0 ? 0 : -1
        }
        
        if newIndex >= 0 && newIndex < allTransactions.count {
            currentRecordIndex = newIndex
            currentEditingTransaction = allTransactions[newIndex]
            storeOriginalValues(from: allTransactions[newIndex])
            return allTransactions[newIndex]
        } else if newIndex == -1 {
            // Go to adding new record
            currentRecordIndex = nil
            currentEditingTransaction = nil
            clearOriginalValues()
            return nil
        }
        return nil
    }
    
    func goToPreviousRecord() -> Transaction? {
        return goToRecord(offset: 1)
    }
    
    func goToNextRecord() -> Transaction? {
        return goToRecord(offset: -1)
    }
    
    /// Switches to adding a new record mode by clearing the current selection and original values.
    func switchToAddNewRecordMode() {
        currentRecordIndex = nil
        currentEditingTransaction = nil
        clearOriginalValues()
    }
    
    // MARK: - Change Tracking
    
    func hasChanges(currentTitle: String, currentAmount: String, currentCategory: ExpenseCategory, currentPayment: PaymentMethod, currentDate: Date) -> Bool {
        let currentDesc = currentTitle.isEmpty ? "Untitled" : currentTitle
        let originalDesc = original.title.isEmpty ? "Untitled" : original.title
        
        return currentDesc != originalDesc ||
               currentAmount != original.amount ||
               currentCategory != original.category ||
               currentPayment != original.payment ||
               currentDate != original.date
    }
    
    func saveChangesIfNeeded(
        currentTitle: String,
        currentAmount: String,
        currentCategory: ExpenseCategory,
        currentPayment: PaymentMethod,
        currentDate: Date,
        in context: ModelContext
    ) {
        guard let editingTransaction = currentEditingTransaction else { return }
        
        let hasChanges = hasChanges(
            currentTitle: currentTitle,
            currentAmount: currentAmount,
            currentCategory: currentCategory,
            currentPayment: currentPayment,
            currentDate: currentDate
        )
        
        if hasChanges && !currentAmount.isEmpty {
            let money = Money(currentAmount)
            let finalTitle = currentTitle.isEmpty ? "Untitled" : currentTitle
            
            do {
                try TransactionService.updateTransaction(
                    editingTransaction,
                    title: finalTitle,
                    amount: money,
                    category: currentCategory,
                    date: currentDate,
                    paymentMethod: currentPayment,
                    location: original.location,
                    address: original.address,
                    in: context
                )
            } catch {
                // Removed debug print
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func storeOriginalValues(from transaction: Transaction) {
        original.title = transaction.title == "Untitled" ? "" : transaction.title
        original.amount = transaction.amount.dollarsAndCents
        original.category = transaction.category
        original.payment = transaction.paymentMethod
        original.date = transaction.date
        original.location = transaction.location
        original.address = transaction.address
    }
    
    private func clearOriginalValues() {
        original = OriginalValues()
    }
}
