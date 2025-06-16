//
//  ExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI

struct ExpenseView: View {
    let transactions: [Transaction]
    let settings: Settings
    @State private var showingAddExpense = false
    @State private var showingQuickEntry = false  // Separate state for accountant mode
    @State private var editingTransaction: Transaction? = nil
    @State private var filter = TransactionFilter()
    @State private var showingFilterSheet = false
    @State private var isSearching = false
    @FocusState private var isSearchFieldFocused: Bool
    
    private var filteredTransactions: [Transaction] {
        if filter.isActive {
            return transactions.filter { filter.matches($0) }
        }
        return transactions
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                showingAddExpense = true  // Normal mode
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.medium)
            }
        }
        
        if #available(iOS 26.0, *) {
            ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                showingQuickEntry = true  // Accountant mode
            }) {
                Image(systemName: "book.closed")
                    .font(.system(size: 18))
                    .fontWeight(.medium)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 🔍 CUSTOM SEARCH BAR - Files App Style
            HStack(spacing: 8) {
                // Search bar (shrinks when buttons appear)
                HStack(spacing: 8) {
                    // Magnifying glass icon
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 17, weight: .medium))
                    
                    // Search text field
                    TextField("Search expenses", text: $filter.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 17))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isSearchFieldFocused)
                        .onTapGesture {
                            isSearchFieldFocused = true
                        }
                    
                    // Clear button (only shows when there's text)
                    if !filter.searchText.isEmpty {
                        Button(action: {
                            filter.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .cornerRadius(.infinity) // Maximum roundness
                .onTapGesture {
                    isSearchFieldFocused = true
                }
                .onChange(of: isSearchFieldFocused) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isSearching = newValue
                    }
                }
                
                // Filter button (appears when searching OR when filters are active)
                if isSearching || filter.activeFilterCount > 0 {
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: filter.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Filter")
                                .font(.system(size: 17, weight: .medium))
                            
                            if filter.activeFilterCount > 0 {
                                Text("\(filter.activeFilterCount)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                        }
                        .foregroundColor(filter.isActive ? .blue : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10) // Match search bar height
                        .background(Color(.systemGray5))
                        .cornerRadius(.infinity) // Maximum roundness
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                
                // Cancel button (X button - only shows when actively searching)
                if isSearching {
                    Button(action: {
                        filter.searchText = ""
                        isSearchFieldFocused = false
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isSearching = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 40, height: 40) // Match search bar height
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .animation(.easeInOut(duration: 0.25), value: isSearching)
            .animation(.easeInOut(duration: 0.25), value: filter.searchText.isEmpty)
            .animation(.easeInOut(duration: 0.25), value: filter.activeFilterCount)
            
            // Filter chips (only when active)
            if filter.activeFilterCount > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Date filter chip
                        if filter.dateFilterType != .none {
                            FilterChip(
                                text: filter.dateFilterType == .custom ?
                                    filter.dateFilterDisplayText :
                                    filter.dateFilterType.rawValue,
                                color: .blue,
                                onRemove: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        filter.dateFilterType = .none
                                    }
                                }
                            )
                        }
                        
                        // Category filter chips
                        ForEach(Array(filter.selectedCategories).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                            FilterChip(
                                text: category.rawValue,
                                color: category.color,
                                onRemove: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        _ = filter.selectedCategories.remove(category)
                                    }
                                }
                            )
                        }
                        
                        // Payment method filter chips
                        ForEach(Array(filter.selectedPaymentMethods).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { method in
                            FilterChip(
                                text: method.rawValue,
                                color: method.color,
                                onRemove: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        _ = filter.selectedPaymentMethods.remove(method)
                                    }
                                }
                            )
                        }
                        
                        // Clear all button
                        Button("Clear All") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                filter.selectedCategories.removeAll()
                                filter.selectedPaymentMethods.removeAll()
                                filter.dateFilterType = .none
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Content
            if filteredTransactions.isEmpty {
                if filter.isActive {
                    NoResultsView(filter: $filter)
                } else {
                    EmptyStateView()
                }
            } else {
                TransactionList(
                    groupedTransactions: groupedTransactions(for: filteredTransactions),
                    editingTransaction: $editingTransaction
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: filter.activeFilterCount)
        .background(Color(.systemGroupedBackground))
        // Tap anywhere to dismiss keyboard
        .onTapGesture {
            if isSearchFieldFocused {
                isSearchFieldFocused = false
            }
        }
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(accountantMode: false)  // Normal mode
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingQuickEntry) {
            AddExpenseView(accountantMode: true)   // Accountant mode
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(filter: $filter)
        }
        .sheet(item: $editingTransaction) { transaction in
            AddExpenseView(transactionToEdit: transaction, accountantMode: false)  // Never accountant mode when editing
                .presentationDragIndicator(.visible)
        }
    }
    
    func groupedTransactions(for transactions: [Transaction]) -> [(String, [Transaction])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let grouped = Dictionary(grouping: transactions) { transaction in
            dateFormatter.string(from: transaction.date)
        }
        
        return grouped.sorted { first, second in
            let firstDate = transactions.first { dateFormatter.string(from: $0.date) == first.key }?.date ?? Date.distantPast
            let secondDate = transactions.first { dateFormatter.string(from: $0.date) == second.key }?.date ?? Date.distantPast
            return firstDate > secondDate
        }
    }
}
