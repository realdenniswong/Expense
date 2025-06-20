//
//  TransactionFilter.swift
//  Expense
//
//  Created by Dennis Wong on 16/6/2025.
//

import SwiftUI

// MARK: - Simplified Filter Model
struct TransactionFilter {
    var searchText: String = ""
    var categories: Set<ExpenseCategory> = []
    var paymentMethods: Set<PaymentMethod> = []
    var dateRange: ClosedRange<Date>?
    var lastDateRange: ClosedRange<Date>? = nil
    
    var isActive: Bool {
        !searchText.isEmpty || !categories.isEmpty || !paymentMethods.isEmpty || dateRange != nil
    }
    
    var activeFilterCount: Int {
        var count = 0
        if !categories.isEmpty { count += 1 }
        if !paymentMethods.isEmpty { count += 1 }
        if dateRange != nil { count += 1 }
        return count
    }
    
    func matches(_ transaction: Transaction) -> Bool {
        // Search text filter
        if !searchText.isEmpty {
            let search = searchText.lowercased()
            let titleMatches = transaction.title.lowercased().contains(search)
            let categoryMatches = transaction.category.rawValue.lowercased().contains(search)
            let paymentMatches = transaction.paymentMethod.rawValue.lowercased().contains(search)
            
            guard titleMatches || categoryMatches || paymentMatches else {
                return false
            }
        }
        
        // Category filter
        if !categories.isEmpty && !categories.contains(transaction.category) {
            return false
        }
        
        // Payment method filter
        if !paymentMethods.isEmpty && !paymentMethods.contains(transaction.paymentMethod) {
            return false
        }
        
        // Date filter
        if let range = dateRange, !range.contains(transaction.date) {
            return false
        }
        
        return true
    }
    
    mutating func clear() {
        searchText = ""
        categories.removeAll()
        paymentMethods.removeAll()
        lastDateRange = dateRange
        dateRange = nil
    }
    
    // Helper for date range display
    var dateRangeDisplayText: String {
        guard let range = dateRange else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return "\(formatter.string(from: range.lowerBound)) - \(formatter.string(from: range.upperBound))"
    }
}

// MARK: - Simplified Filter Sheet
struct FilterSheet: View {
    @Binding var filter: TransactionFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Date Filter Section
                Section {
                    Toggle("Filter by Date", isOn: Binding(
                        get: { filter.dateRange != nil },
                        set: { isOn in
                            if isOn {
                                filter.dateRange = filter.lastDateRange ?? {
                                    let end = Date()
                                    let start = Calendar.current.date(byAdding: .month, value: -1, to: end)!
                                    return start...end
                                }()
                            } else {
                                filter.lastDateRange = filter.dateRange
                                filter.dateRange = nil
                            }
                        }
                    ))

                    if filter.dateRange != nil {
                        DatePicker("From", selection: Binding(
                            get: { filter.dateRange?.lowerBound ?? Date() },
                            set: { newValue in
                                let end = filter.dateRange?.upperBound ?? newValue
                                filter.dateRange = min(newValue, end)...max(newValue, end)
                            }
                        ), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)

                        DatePicker("To", selection: Binding(
                            get: { filter.dateRange?.upperBound ?? Date() },
                            set: { newValue in
                                let start = filter.dateRange?.lowerBound ?? newValue
                                filter.dateRange = min(start, newValue)...max(start, newValue)
                            }
                        ), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                    }
                } header: {
                    Text("Date")
                }
                
                // Categories Section
                Section {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        CategoryFilterRow(
                            category: category,
                            isSelected: filter.categories.contains(category)
                        ) { isSelected in
                            if isSelected {
                                filter.categories.insert(category)
                            } else {
                                filter.categories.remove(category)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Categories")
                        Spacer()
                        if !filter.categories.isEmpty {
                            Button("Clear") {
                                filter.categories.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // Payment Methods Section
                Section {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        PaymentMethodFilterRow(
                            paymentMethod: method,
                            isSelected: filter.paymentMethods.contains(method)
                        ) { isSelected in
                            if isSelected {
                                filter.paymentMethods.insert(method)
                            } else {
                                filter.paymentMethods.remove(method)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Payment Methods")
                        Spacer()
                        if !filter.paymentMethods.isEmpty {
                            Button("Clear") {
                                filter.paymentMethods.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
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
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Filter Row Components (Simplified)
struct CategoryFilterRow: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            HStack {
                CategoryIcon(category: category, size: 20, iconSize: 12)
                    .frame(width: 20, height: 20)
                
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
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Filter Chip Component (Simplified)
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
