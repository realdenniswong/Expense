//
//  TransactionFilter.swift
//  Expense
//
//  Created by Dennis Wong on 16/6/2025.
//

import SwiftUI

// MARK: - Date Filter Type
enum DateFilterType: String, CaseIterable {
    case none = "All Time"
    case custom = "Custom Range"
    
    var systemImageName: String {
        switch self {
        case .none: return "calendar"
        case .custom: return "calendar.badge.plus"
        }
    }
}

// MARK: - Filter Model
struct TransactionFilter {
    var searchText: String = ""
    var selectedCategories: Set<ExpenseCategory> = Set()
    var selectedPaymentMethods: Set<PaymentMethod> = Set()
    
    // Date filtering
    var dateFilterType: DateFilterType = .none
    var customStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    var customEndDate: Date = Date()
    
    var isActive: Bool {
        !searchText.isEmpty ||
        !selectedCategories.isEmpty ||
        !selectedPaymentMethods.isEmpty ||
        dateFilterType != .none
    }
    
    var activeFilterCount: Int {
        var count = 0
        if !selectedCategories.isEmpty { count += 1 }
        if !selectedPaymentMethods.isEmpty { count += 1 }
        if dateFilterType != .none { count += 1 }
        return count
    }
    
    // Get the date range for current filter
    private var dateRange: (start: Date, end: Date)? {
        switch dateFilterType {
        case .none:
            return nil
        case .custom:
            return (customStartDate, customEndDate)
        }
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
        
        // Date filter
        if let range = dateRange {
            if transaction.date < range.start || transaction.date > range.end {
                return false
            }
        }
        
        return true
    }
    
    mutating func clear() {
        searchText = ""
        selectedCategories.removeAll()
        selectedPaymentMethods.removeAll()
        dateFilterType = .none
        // Reset custom dates to default range (last month to now)
        customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        customEndDate = Date()
    }
    
    // Get display text for current date filter
    var dateFilterDisplayText: String {
        switch dateFilterType {
        case .none:
            return ""
        case .custom:
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return "\(formatter.string(from: customStartDate)) - \(formatter.string(from: customEndDate))"
        }
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Binding var filter: TransactionFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Date Filter Section
                Section {
                    ForEach(DateFilterType.allCases, id: \.self) { dateType in
                        DateFilterRow(
                            dateType: dateType,
                            isSelected: filter.dateFilterType == dateType
                        ) {
                            filter.dateFilterType = dateType
                        }
                    }
                    
                    // Custom date range picker (only show when custom is selected)
                    if filter.dateFilterType == .custom {
                        VStack(spacing: 12) {
                            DatePicker("From", selection: $filter.customStartDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .onChange(of: filter.customStartDate) { _, newValue in
                                    // If start date is after end date, update end date
                                    if newValue > filter.customEndDate {
                                        filter.customEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue) ?? newValue
                                    }
                                }
                            
                            DatePicker("To", selection: $filter.customEndDate, in: filter.customStartDate..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                        }
                        .padding(.vertical, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                } header: {
                    HStack {
                        Text("Date Range")
                        Spacer()
                        if filter.dateFilterType != .none {
                            Button("Clear") {
                                filter.dateFilterType = .none
                                // Reset custom dates to default range
                                filter.customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                                filter.customEndDate = Date()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
                
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

// MARK: - Date Filter Row Component
struct DateFilterRow: View {
    let dateType: DateFilterType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: dateType.systemImageName)
                    .foregroundColor(.blue)
                    .frame(width: 20, height: 20)
                
                Text(dateType.rawValue)
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
        .padding(.vertical, -4)
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
