//
//  ExportModels.swift
//  Expense
//
//  Created by Dennis Wong on 16/6/2025.
//
import Foundation

struct TransactionBackup: Codable {
    let exportDate: Date
    let totalTransactions: Int
    let appVersion: String
    let transactions: [TransactionData]
}

struct TransactionData: Codable {
    let id: String
    let title: String
    let amountCents: Int
    let category: String
    let paymentMethod: String
    let date: Date
}
