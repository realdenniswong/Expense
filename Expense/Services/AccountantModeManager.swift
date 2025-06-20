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
    private(set) var currentRecordIndex: Int?
    private(set) var currentEditingTransaction: Transaction?
    private let allTransactions: [Transaction]
    
    // Original values for change tracking
    private(set) var originalTitle = ""
    private(set) var originalAmount = ""
    private(set) var originalCategory = ExpenseCategory.foodDrink
    private(set) var originalPayment = PaymentMethod.creditCard
    private(set) var originalDate = Date()
    
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
        if isAddingNewRecord {
            return "Adding new expense"
        } else {
            return "Editing record \(allTransactions.count - currentRecordIndex!) of \(allTransactions.count)"
        }
    }
    
    // MARK: - Navigation Actions
    
    func goToPreviousRecord() -> Transaction? {
        let newIndex: Int
        if let current = currentRecordIndex {
            newIndex = current + 1
        } else {
            newIndex = 0
        }
        
        if newIndex < allTransactions.count {
            currentRecordIndex = newIndex
            currentEditingTransaction = allTransactions[newIndex]
            storeOriginalValues(from: allTransactions[newIndex])
            return allTransactions[newIndex]
        }
        return nil
    }
    
    func goToNextRecord() -> Transaction? {
        guard let current = currentRecordIndex else { return nil }
        
        if current > 0 {
            let newIndex = current - 1
            currentRecordIndex = newIndex
            currentEditingTransaction = allTransactions[newIndex]
            storeOriginalValues(from: allTransactions[newIndex])
            return allTransactions[newIndex]
        } else {
            // Go to adding new record
            currentRecordIndex = nil
            currentEditingTransaction = nil
            clearOriginalValues()
            return nil
        }
    }
    
    // MARK: - Change Tracking
    
    func hasChanges(currentTitle: String, currentAmount: String, currentCategory: ExpenseCategory, currentPayment: PaymentMethod, currentDate: Date) -> Bool {
        let currentDesc = currentTitle.isEmpty ? "Untitled" : currentTitle
        let originalDesc = originalTitle.isEmpty ? "Untitled" : originalTitle
        
        return currentDesc != originalDesc ||
               currentAmount != originalAmount ||
               currentCategory != originalCategory ||
               currentPayment != originalPayment ||
               currentDate != originalDate
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
                    in: context
                )
            } catch {
                print("Failed to save changes: \(error)")
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func storeOriginalValues(from transaction: Transaction) {
        originalTitle = transaction.title == "Untitled" ? "" : transaction.title
        originalAmount = transaction.amount.dollarsAndCents
        originalCategory = transaction.category
        originalPayment = transaction.paymentMethod
        originalDate = transaction.date
    }
    
    private func clearOriginalValues() {
        originalTitle = ""
        originalAmount = ""
        originalCategory = .foodDrink
        originalPayment = .creditCard
        originalDate = Date()
    }
}
