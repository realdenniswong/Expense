//
//  Settings.swift
//  Expense
//
//  Created by Dennis Wong on 13/6/2025.
//

import SwiftUI
import SwiftData

@Model
class Settings {
    var id: UUID
    
    // Spending Goal toggles for each period
    var showDailyGoals: Bool
    var showWeeklyGoals: Bool
    var showMonthlyGoals: Bool
    
    // Spending Goal categories for each period - stored as arrays of category raw values
    var dailyGoalCategoriesRaw: Array<String>
    var weeklyGoalCategoriesRaw: Array<String>
    var monthlyGoalCategoriesRaw: Array<String>
    
    // SAFE: Goal amounts (stored in cents) - OPTIONAL to prevent data loss
    var foodDrinkGoalAmount: Int?
    var transportationGoalAmount: Int?
    var shoppingGoalAmount: Int?
    var entertainmentGoalAmount: Int?
    var billsUtilitiesGoalAmount: Int?
    var healthcareGoalAmount: Int?
    var otherGoalAmount: Int?
    
    var accountantMode: Bool
    
    init(
        id: UUID = UUID(),
        showDailyGoals: Bool = true,
        showWeeklyGoals: Bool = true,
        showMonthlyGoals: Bool = true,
        dailyGoalCategories: Array<ExpenseCategory> = [.foodDrink, .transportation, .entertainment],
        weeklyGoalCategories: Array<ExpenseCategory> = [.foodDrink, .transportation, .shopping, .entertainment, .healthcare],
        monthlyGoalCategories: Array<ExpenseCategory> = ExpenseCategory.allCases,
        accountantMode: Bool = false
    ) {
        self.id = id
        self.showDailyGoals = showDailyGoals
        self.showWeeklyGoals = showWeeklyGoals
        self.showMonthlyGoals = showMonthlyGoals
        self.dailyGoalCategoriesRaw = dailyGoalCategories.map { category in category.rawValue }
        self.weeklyGoalCategoriesRaw = weeklyGoalCategories.map { category in category.rawValue }
        self.monthlyGoalCategoriesRaw = monthlyGoalCategories.map { category in category.rawValue }
        
        // Initialize goal amounts as nil (will use defaults)
        self.foodDrinkGoalAmount = nil
        self.transportationGoalAmount = nil
        self.shoppingGoalAmount = nil
        self.entertainmentGoalAmount = nil
        self.billsUtilitiesGoalAmount = nil
        self.healthcareGoalAmount = nil
        self.otherGoalAmount = nil
        
        self.accountantMode = accountantMode
    }
    
    // MARK: - Computed Properties for ExpenseCategory arrays
    
    var dailyGoalCategories: Array<ExpenseCategory> {
        get {
            return dailyGoalCategoriesRaw.compactMap { rawValue in
                ExpenseCategory(rawValue: rawValue)
            }
        }
        set {
            dailyGoalCategoriesRaw = newValue.map { category in
                category.rawValue
            }
        }
    }
    
    var weeklyGoalCategories: Array<ExpenseCategory> {
        get {
            return weeklyGoalCategoriesRaw.compactMap { rawValue in
                ExpenseCategory(rawValue: rawValue)
            }
        }
        set {
            weeklyGoalCategoriesRaw = newValue.map { category in
                category.rawValue
            }
        }
    }
    
    var monthlyGoalCategories: Array<ExpenseCategory> {
        get {
            return monthlyGoalCategoriesRaw.compactMap { rawValue in
                ExpenseCategory(rawValue: rawValue)
            }
        }
        set {
            monthlyGoalCategoriesRaw = newValue.map { category in
                category.rawValue
            }
        }
    }
    
    // MARK: - Goal Amount Helper Methods (with defaults)
    
    func goalAmount(for category: ExpenseCategory) -> Int {
        switch category {
        case .foodDrink: return foodDrinkGoalAmount ?? 150000      // HK$1500
        case .transportation: return transportationGoalAmount ?? 80000   // HK$800
        case .shopping: return shoppingGoalAmount ?? 100000       // HK$1000
        case .entertainment: return entertainmentGoalAmount ?? 60000     // HK$600
        case .billsUtilities: return billsUtilitiesGoalAmount ?? 200000  // HK$2000
        case .healthcare: return healthcareGoalAmount ?? 50000     // HK$500
        case .other: return otherGoalAmount ?? 30000              // HK$300
        }
    }
    
    func setGoalAmount(_ amount: Int, for category: ExpenseCategory) {
        switch category {
        case .foodDrink: foodDrinkGoalAmount = amount
        case .transportation: transportationGoalAmount = amount
        case .shopping: shoppingGoalAmount = amount
        case .entertainment: entertainmentGoalAmount = amount
        case .billsUtilities: billsUtilitiesGoalAmount = amount
        case .healthcare: healthcareGoalAmount = amount
        case .other: otherGoalAmount = amount
        }
    }
    
    // MARK: - Helper Methods
    
    // Method to check if goals should be shown for a specific period
    func shouldShowGoals(for period: TimePeriod) -> Bool {
        switch period {
        case .daily: return showDailyGoals
        case .weekly: return showWeeklyGoals
        case .monthly: return showMonthlyGoals
        }
    }
    
    // Method to get enabled categories for a specific period
    func enabledCategories(for period: TimePeriod) -> Array<ExpenseCategory> {
        switch period {
        case .daily: return dailyGoalCategories
        case .weekly: return weeklyGoalCategories
        case .monthly: return monthlyGoalCategories
        }
    }
    
    // Method to get count of enabled categories for a period
    func enabledCategoriesCount(for period: TimePeriod) -> Int {
        return enabledCategories(for: period).count
    }
    
    // Method to check if a category is enabled for a specific period
    func isCategoryEnabled(_ category: ExpenseCategory, for period: TimePeriod) -> Bool {
        return enabledCategories(for: period).contains(category)
    }
    
    // Method to toggle a category for a specific period
    func toggleCategory(_ category: ExpenseCategory, for period: TimePeriod) {
        switch period {
        case .daily:
            var categories = dailyGoalCategories
            if categories.contains(category) {
                categories.removeAll { $0 == category }
            } else {
                categories.append(category)
            }
            dailyGoalCategories = categories
        case .weekly:
            var categories = weeklyGoalCategories
            if categories.contains(category) {
                categories.removeAll { $0 == category }
            } else {
                categories.append(category)
            }
            weeklyGoalCategories = categories
        case .monthly:
            var categories = monthlyGoalCategories
            if categories.contains(category) {
                categories.removeAll { $0 == category }
            } else {
                categories.append(category)
            }
            monthlyGoalCategories = categories
        }
    }
}
