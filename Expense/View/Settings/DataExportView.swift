//
//  DataExportView.swift
//  Expense
//
//  Created by Dennis Wong on 14/6/2025.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DataExportView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var isExporting = false
    @State private var showingSaveDialog = false
    @State private var exportedData: Data?
    @State private var fileName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Export All Expenses")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("\(transactions.count) total expenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    Text("Export your expense data as a JSON file. This includes all your transaction details, categories, payment methods, and dates.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button {
                        exportData()
                    } label: {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                                Text("Exporting...")
                            } else {
                                Text("Export All Data")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isExporting ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isExporting)
                }
                .padding(.vertical, 8)
            } footer: {
                Text("The exported file can be saved to Files, shared via email, or backed up to cloud storage. Your data will remain private and secure.")
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.large)
        .fileExporter(
            isPresented: $showingSaveDialog,
            document: JSONDocument(data: exportedData ?? Data()),
            contentType: .json,
            defaultFilename: fileName
        ) { result in
            switch result {
            case .success(let url):
                alertMessage = "Successfully exported to \(url.lastPathComponent)"
                showingAlert = true
            case .failure(let error):
                alertMessage = "Export failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
        .alert("Export Result", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func exportData() {
        isExporting = true
        
        fileName = "expenses_backup_\(formatDate(Date())).json"
        
        // Create export data with new Transaction model
        let exportData = TransactionBackup(
            exportDate: Date(),
            totalTransactions: transactions.count,
            appVersion: "2.0.0", // Updated version for new format
            transactions: transactions.map { transaction in
                TransactionData(
                    id: transaction.id.uuidString,
                    title: transaction.title,
                    amountCents: transaction.amount.cents,
                    category: transaction.category.rawValue,
                    paymentMethod: transaction.paymentMethod.rawValue,
                    date: transaction.date
                )
            }
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let jsonData = try encoder.encode(exportData)
            exportedData = jsonData
            
            isExporting = false
            showingSaveDialog = true
        } catch {
            isExporting = false
            alertMessage = "Export failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
