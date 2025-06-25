//
//  TransactionDetailSheet.swift
//  Expense
//
//  Created by Dennis Wong on 18/6/2025.
//

import SwiftUI
import MapKit

private struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

private extension TransactionDetailSheet {
    @ViewBuilder
    var locationRow: some View {
        let hasCoordinate = transaction.latitude != nil && transaction.longitude != nil
        let name = transaction.location?.isEmpty == false ? transaction.location : nil
        let address = transaction.address?.isEmpty == false ? transaction.address : nil
        if hasCoordinate {
            let coordinate = CLLocationCoordinate2D(latitude: transaction.latitude!, longitude: transaction.longitude!)
            let annotation = IdentifiableCoordinate(coordinate: coordinate)
            VStack(alignment: .leading, spacing: 8) {
                Map(
                    position: .constant(.region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )))
                ) {
                    Marker("", coordinate: annotation.coordinate)
                }
                .frame(height: 250)
                .cornerRadius(8)

                // Show name/address and button side by side below the map if available
                if name != nil || address != nil {
                    HStack(alignment: .center, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            if let name = name {
                                Text(name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            if let address = address {
                                Text(address)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button(action: { openInMaps() }) {
                            Image(systemName: "map")
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Open in Maps")
                    }
                }
            }
            .padding(.vertical, 8)
        } else if name != nil || address != nil {
            // Only name/address with no coordinates, still show button if coordinates are present (no in this case)
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    if let name = name {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    if let address = address {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                // No button here because no coordinates
            }
            .padding(.vertical, 8)
        } else {
            // Neither available
            Text("No location info available")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
        }
    }

    var summaryRow: some View {
        HStack {
            CategoryIcon(category: transaction.category, size: 48, iconSize: 20)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(transaction.paymentMethod.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            AmountDisplayView.large(transaction.amount)
        }
        .padding(.vertical, 8)
    }

    var descriptionRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(transaction.title)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            // Uncomment this if/when transaction.description exists:
            // if let desc = transaction.description, !desc.isEmpty {
            //     Text(desc)
            //         .font(.body)
            //         .foregroundColor(.secondary)
            //         .lineLimit(nil) // allow wrapping
            // }
        }
    }
}

struct TransactionDetailSheet: View {
    let transaction: Transaction
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Summary") {
                    summaryRow
                }
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        descriptionRow
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(transaction.date.mediumDateString + " " + transaction.date.timeString)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        locationRow
                    }
                }
            }
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Delete", role: .destructive) {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showingEditSheet) {
            AddExpenseView(transactionToEdit: transaction)
        }
        .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTransaction()
            }
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
    }
    
    private func deleteTransaction() {
        modelContext.delete(transaction)
        try? modelContext.save()
        dismiss()
    }
    
    private func openInMaps() {
        guard let lat = transaction.latitude, let lon = transaction.longitude else { return }
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = transaction.location ?? "Location"
        mapItem.openInMaps(launchOptions: nil)
    }
}

// Extension to make text selectable
extension Text {
    func selectable() -> some View {
        self.textSelection(.enabled)
    }
}

