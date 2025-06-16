//
//  TransactionFilter.swift
//  Expense
//
//  Created by Dennis Wong on 16/6/2025.
//

import SwiftUI

// MARK: - Filter Model
struct TransactionFilter {
    var searchText: String = ""
    var selectedCategories: Set<ExpenseCategory> = Set()
    var selectedPaymentMethods: Set<PaymentMethod> = Set()
    
    var isActive: Bool {
        !searchText.isEmpty || !selectedCategories.isEmpty || !selectedPaymentMethods.isEmpty
    }
    
    var activeFilterCount: Int {
        var count = 0
        if !selectedCategories.isEmpty { count += 1 }
        if !selectedPaymentMethods.isEmpty { count += 1 }
        return count
    }
    
    func matches(_ transaction: Transaction) -> Bool {
        // Search text filter
        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            let titleMatches = transaction.title.lowercased().contains(searchLower)
            let categoryMatches = transaction.category.rawValue.lowercased().contains(searchLower)
            let paymentMatches = transaction.paymentMethod.rawValue.lowercased().contains(searchLower)
            
            if !titleMatches && !categoryMatches && !paymentMatches {
                return false
            }
        }
        
        // Category filter
        if !selectedCategories.isEmpty && !selectedCategories.contains(transaction.category) {
            return false
        }
        
        // Payment method filter
        if !selectedPaymentMethods.isEmpty && !selectedPaymentMethods.contains(transaction.paymentMethod) {
            return false
        }
        
        return true
    }
    
    mutating func clear() {
        searchText = ""
        selectedCategories.removeAll()
        selectedPaymentMethods.removeAll()
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Binding var filter: TransactionFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Categories Section
                Section {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        CategoryFilterRow(
                            category: category,
                            isSelected: filter.selectedCategories.contains(category)
                        ) { isSelected in
                            if isSelected {
                                filter.selectedCategories.insert(category)
                            } else {
                                filter.selectedCategories.remove(category)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Categories")
                        Spacer()
                        if !filter.selectedCategories.isEmpty {
                            Button("Clear") {
                                filter.selectedCategories.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                } footer: {
                    if filter.selectedCategories.isEmpty {
                        Text("All categories will be shown")
                    } else {
                        Text("\(filter.selectedCategories.count) categories selected")
                    }
                }
                
                // Payment Methods Section
                Section {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        PaymentMethodFilterRow(
                            paymentMethod: method,
                            isSelected: filter.selectedPaymentMethods.contains(method)
                        ) { isSelected in
                            if isSelected {
                                filter.selectedPaymentMethods.insert(method)
                            } else {
                                filter.selectedPaymentMethods.remove(method)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Payment Methods")
                        Spacer()
                        if !filter.selectedPaymentMethods.isEmpty {
                            Button("Clear") {
                                filter.selectedPaymentMethods.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                } footer: {
                    if filter.selectedPaymentMethods.isEmpty {
                        Text("All payment methods will be shown")
                    } else {
                        Text("\(filter.selectedPaymentMethods.count) payment methods selected")
                    }
                }
            }
            .navigationTitle("Filter Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        filter.clear()
                    }
                    .disabled(!filter.isActive)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Filter Row Components
struct CategoryFilterRow: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            HStack {
                CategoryIcon(category: category, size: 32, iconSize: 14)
                
                Text(category.rawValue)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PaymentMethodFilterRow: View {
    let paymentMethod: PaymentMethod
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            HStack {
                paymentMethod.icon
                    .foregroundColor(paymentMethod.color)
                    .frame(width: 20, height: 20)
                
                Text(paymentMethod.rawValue)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Filter Chip Component
struct FilterChip: View {
    let text: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(12)
    }
}

// MARK: - No Results View
struct NoResultsView: View {
    @Binding var filter: TransactionFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("No Results Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Try adjusting your search or filters")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Button("Clear Filters") {
                    filter.clear()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
