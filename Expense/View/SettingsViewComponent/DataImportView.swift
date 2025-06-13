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
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
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
            
            // MARK: - Instructions Section
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
            // Start accessing the security-scoped resource
            let gotAccess = url.startAccessingSecurityScopedResource()
            defer {
                if gotAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let importData = try decoder.decode(ExpenseBackup.self, from: data)
            
            var importedCount = 0
            var skippedCount = 0
            
            for expenseItem in importData.expenses {
                // Check if expense already exists (by ID)
                let existingExpense = expenses.first { $0.id.uuidString == expenseItem.id }
                
                if existingExpense == nil {
                    // Create new expense
                    let newExpense = Expense(
                        id: UUID(uuidString: expenseItem.id) ?? UUID(),
                        description: expenseItem.description,
                        amountInCents: expenseItem.amountInCents,
                        category: ExpenseCategory(rawValue: expenseItem.category) ?? .other,
                        date: expenseItem.date,
                        method: PaymentMethod(rawValue: expenseItem.paymentMethod) ?? .cash
                    )
                    
                    modelContext.insert(newExpense)
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
            
        } catch let error as DecodingError {
            alertTitle = "Import Failed"
            alertMessage = "Invalid file format. Please select a valid expense backup file."
            print("Decoding error: \(error)")
            showingAlert = true
        } catch {
            alertTitle = "Import Failed"
            alertMessage = "Unable to read the selected file: \(error.localizedDescription)"
            print("Import error: \(error)")
            showingAlert = true
        }
    }
}
