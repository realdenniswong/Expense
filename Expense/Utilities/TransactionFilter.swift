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
        dateRange = nil
    }
    
    // Helper for date range display
    var dateRangeDisplayText: String {
        guard let range = dateRange else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return "\(formatter.string(from: range.lowerBound)) - \(formatter.string(from: range.upperBound))"
    }
}

// MARK: - Simplified Filter Sheet
struct FilterSheet: View {
    @Binding var filter: TransactionFilter
    @Environment(\.dismiss) private var dismiss
    @State private var tempStartDate = Date()
    @State private var tempEndDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationStack {
            List {
                // Date Filter Section
                Section {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        if filter.dateRange != nil {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Date Range")
                                    .font(.body)
                                Text(filter.dateRangeDisplayText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("Date Range")
                                .font(.body)
                        }
                        
                        Spacer()
                        
                        if filter.dateRange != nil {
                            Button("Clear") {
                                filter.dateRange = nil
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        setupDatePicker()
                        showDatePicker = true
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
        .sheet(isPresented: $showDatePicker) {
            DateRangePickerSheet(
                startDate: $tempStartDate,
                endDate: $tempEndDate,
                onSave: { start, end in
                    filter.dateRange = start...end
                }
            )
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func setupDatePicker() {
        if let range = filter.dateRange {
            tempStartDate = range.lowerBound
            tempEndDate = range.upperBound
        } else {
            tempEndDate = Date()
            tempStartDate = Calendar.current.date(byAdding: .month, value: -1, to: tempEndDate) ?? tempEndDate
        }
    }
}

// MARK: - Simplified Date Range Picker
struct DateRangePickerSheet: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onSave: (Date, Date) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker("From", selection: $startDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                
                DatePicker("To", selection: $endDate, in: startDate..., displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Select Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSave(startDate, endDate)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
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
