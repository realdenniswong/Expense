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
    var dailyGoalCategoriesRaw: [String]
    var weeklyGoalCategoriesRaw: [String]
    var monthlyGoalCategoriesRaw: [String]
    
    // Other settings
    var enableNotifications: Bool
    
    init(
        id: UUID = UUID(),
        showDailyGoals: Bool = true,
        showWeeklyGoals: Bool = true,
        showMonthlyGoals: Bool = true,
        dailyGoalCategories: [ExpenseCategory] = [.foodDrink, .transportation, .entertainment],
        weeklyGoalCategories: [ExpenseCategory] = [.foodDrink, .transportation, .shopping, .entertainment, .healthcare],
        monthlyGoalCategories: [ExpenseCategory] = ExpenseCategory.allCases,
        enableNotifications: Bool = true
    ) {
        self.id = id
        self.showDailyGoals = showDailyGoals
        self.showWeeklyGoals = showWeeklyGoals
        self.showMonthlyGoals = showMonthlyGoals
        self.dailyGoalCategoriesRaw = dailyGoalCategories.map { $0.rawValue }
        self.weeklyGoalCategoriesRaw = weeklyGoalCategories.map { $0.rawValue }
        self.monthlyGoalCategoriesRaw = monthlyGoalCategories.map { $0.rawValue }
        self.enableNotifications = enableNotifications
    }
    
    // MARK: - Computed Properties for ExpenseCategory arrays
    
    var dailyGoalCategories: [ExpenseCategory] {
        get {
            dailyGoalCategoriesRaw.compactMap { ExpenseCategory(rawValue: $0) }
        }
        set {
            dailyGoalCategoriesRaw = newValue.map { $0.rawValue }
        }
    }
    
    var weeklyGoalCategories: [ExpenseCategory] {
        get {
            weeklyGoalCategoriesRaw.compactMap { ExpenseCategory(rawValue: $0) }
        }
        set {
            weeklyGoalCategoriesRaw = newValue.map { $0.rawValue }
        }
    }
    
    var monthlyGoalCategories: [ExpenseCategory] {
        get {
            monthlyGoalCategoriesRaw.compactMap { ExpenseCategory(rawValue: $0) }
        }
        set {
            monthlyGoalCategoriesRaw = newValue.map { $0.rawValue }
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
    func enabledCategories(for period: TimePeriod) -> [ExpenseCategory] {
        switch period {
        case .daily: return dailyGoalCategories
        case .weekly: return weeklyGoalCategories
        case .monthly: return monthlyGoalCategories
        }
    }
    
    // Method to get count of enabled categories for a period
    func enabledCategoriesCount(for period: TimePeriod) -> Int {
        enabledCategories(for: period).count
    }
    
    // Method to check if a category is enabled for a specific period
    func isCategoryEnabled(_ category: ExpenseCategory, for period: TimePeriod) -> Bool {
        enabledCategories(for: period).contains(category)
    }
    
    // Method to toggle a category for a specific period
    func toggleCategory(_ category: ExpenseCategory, for period: TimePeriod) {
        switch period {
        case .daily:
            if dailyGoalCategories.contains(category) {
                dailyGoalCategories.removeAll { $0 == category }
            } else {
                dailyGoalCategories.append(category)
            }
        case .weekly:
            if weeklyGoalCategories.contains(category) {
                weeklyGoalCategories.removeAll { $0 == category }
            } else {
                weeklyGoalCategories.append(category)
            }
        case .monthly:
            if monthlyGoalCategories.contains(category) {
                monthlyGoalCategories.removeAll { $0 == category }
            } else {
                monthlyGoalCategories.append(category)
            }
        }
    }
}
