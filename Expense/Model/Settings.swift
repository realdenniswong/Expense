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
    
    // SIMPLIFIED: Single dictionary for all goal amounts (stored in cents)
    var goalAmounts: [String: Int]
    
    init(
        id: UUID = UUID(),
        showDailyGoals: Bool = true,
        showWeeklyGoals: Bool = true,
        showMonthlyGoals: Bool = true,
        dailyGoalCategories: Array<ExpenseCategory> = [.foodDrink, .transportation, .entertainment],
        weeklyGoalCategories: Array<ExpenseCategory> = [.foodDrink, .transportation, .shopping, .entertainment, .healthcare],
        monthlyGoalCategories: Array<ExpenseCategory> = ExpenseCategory.allCases
    ) {
        self.id = id
        self.showDailyGoals = showDailyGoals
        self.showWeeklyGoals = showWeeklyGoals
        self.showMonthlyGoals = showMonthlyGoals
        self.dailyGoalCategoriesRaw = dailyGoalCategories.map { $0.rawValue }
        self.weeklyGoalCategoriesRaw = weeklyGoalCategories.map { $0.rawValue }
        self.monthlyGoalCategoriesRaw = monthlyGoalCategories.map { $0.rawValue }
        
        // Initialize with empty dictionary - defaults will be provided by computed property
        self.goalAmounts = [:]
    }
    
    // MARK: - Computed Properties for ExpenseCategory arrays
    
    var dailyGoalCategories: Array<ExpenseCategory> {
        get {
            return dailyGoalCategoriesRaw.compactMap { ExpenseCategory(rawValue: $0) }
        }
        set {
            dailyGoalCategoriesRaw = newValue.map { $0.rawValue }
        }
    }
    
    var weeklyGoalCategories: Array<ExpenseCategory> {
        get {
            return weeklyGoalCategoriesRaw.compactMap { ExpenseCategory(rawValue: $0) }
        }
        set {
            weeklyGoalCategoriesRaw = newValue.map { $0.rawValue }
        }
    }
    
    var monthlyGoalCategories: Array<ExpenseCategory> {
        get {
            return monthlyGoalCategoriesRaw.compactMap { ExpenseCategory(rawValue: $0) }
        }
        set {
            monthlyGoalCategoriesRaw = newValue.map { $0.rawValue }
        }
    }
    
    // MARK: - SIMPLIFIED Goal Amount Methods
    
    func goalAmount(for category: ExpenseCategory) -> Int {
        // Return stored value or default
        return goalAmounts[category.rawValue] ?? defaultGoalAmount(for: category)
    }
    
    func setGoalAmount(_ amount: Int, for category: ExpenseCategory) {
        goalAmounts[category.rawValue] = amount
    }
    
    // MARK: - Default Goal Amounts
    
    private func defaultGoalAmount(for category: ExpenseCategory) -> Int {
        switch category {
        case .foodDrink: return 150000       // HK$1500
        case .transportation: return 80000    // HK$800
        case .shopping: return 100000        // HK$1000
        case .entertainment: return 60000     // HK$600
        case .billsUtilities: return 200000  // HK$2000
        case .healthcare: return 50000       // HK$500
        case .other: return 30000            // HK$300
        }
    }
    
    // MARK: - Money Type Helpers (for convenience)
    
    func goalMoney(for category: ExpenseCategory) -> Money {
        Money(cents: goalAmount(for: category))
    }
    
    func setGoalMoney(_ money: Money, for category: ExpenseCategory) {
        setGoalAmount(money.cents, for: category)
    }
    
    // MARK: - Helper Methods
    
    func shouldShowGoals(for period: TimePeriod) -> Bool {
        switch period {
        case .daily: return showDailyGoals
        case .weekly: return showWeeklyGoals
        case .monthly: return showMonthlyGoals
        }
    }
    
    func enabledCategories(for period: TimePeriod) -> Array<ExpenseCategory> {
        switch period {
        case .daily: return dailyGoalCategories
        case .weekly: return weeklyGoalCategories
        case .monthly: return monthlyGoalCategories
        }
    }
    
    func enabledCategoriesCount(for period: TimePeriod) -> Int {
        return enabledCategories(for: period).count
    }
    
    func isCategoryEnabled(_ category: ExpenseCategory, for period: TimePeriod) -> Bool {
        return enabledCategories(for: period).contains(category)
    }
    
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
