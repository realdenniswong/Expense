//
//  DataImportView.swift
//  Expense
//
//  Created by Dennis Wong on 14/6/2025.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DataImportView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(\.modelContext) private var modelContext
    @State private var showingFilePicker = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Import Expenses")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("From JSON backup")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    Text("Import expense data from a previously exported JSON file. New expenses will be added to your existing data.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button {
                        showingFilePicker = true
                    } label: {
                        Text("Choose File to Import")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
                .padding(.vertical, 8)
            } footer: {
                Text("Only JSON files exported from this app can be imported. Duplicates will be skipped automatically.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Import Process", systemImage: "info.circle")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text("1.")
                                .fontWeight(.medium)
                            Text("Choose your exported JSON file from Files, iCloud, or email attachments.")
                        }
                        
                        HStack(alignment: .top) {
                            Text("2.")
                                .fontWeight(.medium)
                            Text("The app will check for duplicates and only import new expenses.")
                        }
                        
                        HStack(alignment: .top) {
                            Text("3.")
                                .fontWeight(.medium)
                            Text("You'll see a summary of how many expenses were imported.")
                        }
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Import Data")
        .navigationBarTitleDisplayMode(.large)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importData(from: url)
        case .failure(let error):
            alertTitle = "Import Failed"
            alertMessage = "Failed to select file: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func importData(from url: URL) {
        do {
            let gotAccess = url.startAccessingSecurityScopedResource()
            defer {
                if gotAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            var importedCount = 0
            var skippedCount = 0
            
            // Only support new format - clean and simple
            let importData = try decoder.decode(TransactionBackup.self, from: data)
            
            for transactionItem in importData.transactions {
                let existingTransaction = transactions.first { $0.id.uuidString == transactionItem.id }
                
                if existingTransaction == nil {
                    let newTransaction = Transaction(
                        id: UUID(uuidString: transactionItem.id) ?? UUID(),
                        title: transactionItem.title,
                        amount: Money(cents: transactionItem.amountCents),
                        category: ExpenseCategory(rawValue: transactionItem.category) ?? .other,
                        date: transactionItem.date,
                        paymentMethod: PaymentMethod(rawValue: transactionItem.paymentMethod) ?? .cash
                    )
                    
                    modelContext.insert(newTransaction)
                    importedCount += 1
                } else {
                    skippedCount += 1
                }
            }
            
            try modelContext.save()
            
            alertTitle = "Import Complete"
            if importedCount > 0 {
                alertMessage = "Successfully imported \(importedCount) expenses."
                if skippedCount > 0 {
                    alertMessage += " \(skippedCount) duplicates were skipped."
                }
            } else {
                alertMessage = "No new expenses found. All \(skippedCount) expenses already exist in your data."
            }
            showingAlert = true
            
        } catch {
            alertTitle = "Import Failed"
            alertMessage = "Invalid file format or unable to read the selected file."
            showingAlert = true
        }
    }
}
