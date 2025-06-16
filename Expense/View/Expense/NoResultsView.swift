//
//  NoResultsView.swift
//  Expense
//
//  Created by Dennis Wong on 17/6/2025.
//
import SwiftUI

struct NoResultsView: View {
    @Binding var filter: TransactionFilter
    
    var body: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("Try adjusting your search or filters to find what you're looking for.")
        } actions: {
            Button("Clear Filters") {
                filter.clear()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
