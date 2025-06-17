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
    @State private var showingQuickEntry = false
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
                showingAddExpense = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.medium)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                showingQuickEntry = true
            }) {
                Image(systemName: "book.closed")
                    .font(.system(size: 18))
                    .fontWeight(.medium)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 17, weight: .medium))
                    
                    TextField("Search expenses", text: $filter.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 17))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isSearchFieldFocused)
                        .onTapGesture {
                            isSearchFieldFocused = true
                        }
                    
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
                .cornerRadius(.infinity)
                .onTapGesture {
                    isSearchFieldFocused = true
                }
                .onChange(of: isSearchFieldFocused) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isSearching = newValue
                    }
                }
                
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
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .cornerRadius(.infinity)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                
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
                            .frame(width: 40, height: 40)
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
            
            if filter.activeFilterCount > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if filter.dateRange != nil {
                            FilterChip(
                                text: filter.dateRangeDisplayText,
                                color: .blue,
                                onRemove: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        filter.dateRange = nil
                                    }
                                }
                            )
                        }
                        
                        ForEach(Array(filter.categories).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                            FilterChip(
                                text: category.rawValue,
                                color: category.color,
                                onRemove: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        _ = filter.categories.remove(category)
                                    }
                                }
                            )
                        }
                        
                        ForEach(Array(filter.paymentMethods).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { method in
                            FilterChip(
                                text: method.rawValue,
                                color: method.color,
                                onRemove: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        _ = filter.paymentMethods.remove(method)
                                    }
                                }
                            )
                        }
                        
                        Button("Clear All") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                filter.clear()
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
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: filter.activeFilterCount)
        .background(Color(.systemGroupedBackground))
        .onTapGesture {
            if isSearchFieldFocused {
                isSearchFieldFocused = false
            }
        }
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(accountantMode: false)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingQuickEntry) {
            AddExpenseView(accountantMode: true)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(filter: $filter)
        }
        .sheet(item: $editingTransaction) { transaction in
            AddExpenseView(transactionToEdit: transaction, accountantMode: false)
                .presentationDragIndicator(.visible)
        }
    }
    
    func groupedTransactions(for transactions: [Transaction]) -> [(String, [Transaction])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let grouped = Dictionary(grouping: transactions) { transaction in
            transaction.date.mediumDateString
        }
        
        return grouped.sorted { first, second in
            let firstDate = transactions.first { dateFormatter.string(from: $0.date) == first.key }?.date ?? Date.distantPast
            let secondDate = transactions.first { dateFormatter.string(from: $0.date) == second.key }?.date ?? Date.distantPast
            return firstDate > secondDate
        }
    }
}
