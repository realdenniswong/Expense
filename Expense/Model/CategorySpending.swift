//
//  CategorySpending.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//

struct CategorySpending {
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double
    
    var formattedAmount: String {
        String(format: "HK$%.2f", amount)
    }
    
    var formattedPercentage: String {
        "\(Int(percentage))% of total"
    }
}
