//
//  TransactionService.swift
//  Expense
//
//  Created by Dennis Wong on 21/6/2025.
//

import SwiftUI
import SwiftData

struct TransactionService {
    
    /// Updates an existing transaction with new values
    static func updateTransaction(
        _ transaction: Transaction,
        title: String,
        amount: Money,
        category: ExpenseCategory,
        date: Date,
        paymentMethod: PaymentMethod,
        location: String?,
        address: String?,
        latitude: Double? = nil,
        longitude: Double? = nil,
        in context: ModelContext
    ) throws {
        transaction.title = title
        transaction.amount = amount
        transaction.category = category
        transaction.date = date
        transaction.paymentMethod = paymentMethod
        transaction.location = location
        transaction.address = address
        transaction.latitude = latitude
        transaction.longitude = longitude
        
        try context.save()
    }
    
    /// Creates and saves a new transaction
    static func createTransaction(
        title: String,
        amount: Money,
        category: ExpenseCategory,
        date: Date,
        paymentMethod: PaymentMethod,
        location: String?,
        address: String?,
        latitude: Double? = nil,
        longitude: Double? = nil,
        in context: ModelContext
    ) throws -> Transaction {
        let newTransaction = Transaction(
            title: title,
            amount: amount,
            category: category,
            date: date,
            paymentMethod: paymentMethod,
            location: location,
            address: address,
            latitude: latitude,
            longitude: longitude
        )
        
        context.insert(newTransaction)
        try context.save()
        
        return newTransaction
    }
}

