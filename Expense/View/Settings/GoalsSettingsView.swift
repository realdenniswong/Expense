//
//  GoalsSettingsView.swift
//  Expense
//
//  Created by Dennis Wong on 13/6/2025.
//
import SwiftUI

// MARK: - Reusable Goals Settings View
struct GoalsSettingsView: View {
    let config: GoalPeriodConfig
    let period: TimePeriod
    @Bindable var settings: Settings
    
    private var showGoals: Binding<Bool> {
        switch period {
        case .daily: return $settings.showDailyGoals
        case .weekly: return $settings.showWeeklyGoals
        case .monthly: return $settings.showMonthlyGoals
        }
    }
    
    private func isCategoryEnabled(_ category: ExpenseCategory) -> Bool {
        settings.isCategoryEnabled(category, for: period)
    }
    
    private func toggleCategory(_ category: ExpenseCategory) {
        settings.toggleCategory(category, for: period)
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: config.iconName)
                        .foregroundColor(config.iconColor)
                        .frame(width: 24)
                    
                    Text("Show \(config.title)")
                    
                    Spacer()
                    
                    Toggle("", isOn: showGoals)
                }
            } footer: {
                Text(config.description)
            }
            
            if showGoals.wrappedValue {
                Section {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(category.color.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                
                                category.icon
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(category.color)
                            }
                            
                            Text(category.rawValue)
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { isCategoryEnabled(category) },
                                set: { _ in toggleCategory(category) }
                            ))
                        }
                    }
                } header: {
                    Text("Categories")
                } footer: {
                    Text(config.categoriesFooter)
                }
            }
        }
        .navigationTitle(config.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Specific Goal Settings Views
struct DailyGoalsSettingsView: View {
    @Bindable var settings: Settings
    
    var body: some View {
        GoalsSettingsView(config: .daily, period: .daily, settings: settings)
    }
}

struct WeeklyGoalsSettingsView: View {
    @Bindable var settings: Settings
    
    var body: some View {
        GoalsSettingsView(config: .weekly, period: .weekly, settings: settings)
    }
}

struct MonthlyGoalsSettingsView: View {
    @Bindable var settings: Settings
    
    var body: some View {
        GoalsSettingsView(config: .monthly, period: .monthly, settings: settings)
    }
}

// MARK: - Goal Period Configuration
struct GoalPeriodConfig {
    let title: String
    let iconName: String
    let iconColor: Color
    let description: String
    let categoriesFooter: String
    
    static let daily = GoalPeriodConfig(
        title: "Daily Goals",
        iconName: "target",
        iconColor: .blue,
        description: "Enable daily spending goals to track frequent expenses like food and transportation.",
        categoriesFooter: "Select which expense categories to track daily spending goals for."
    )
    
    static let weekly = GoalPeriodConfig(
        title: "Weekly Goals",
        iconName: "calendar.badge.clock",
        iconColor: .orange,
        description: "Enable weekly spending goals to track moderate frequency expenses like shopping and entertainment.",
        categoriesFooter: "Select which expense categories to track weekly spending goals for."
    )
    
    static let monthly = GoalPeriodConfig(
        title: "Monthly Goals",
        iconName: "calendar",
        iconColor: .green,
        description: "Enable monthly spending goals to track all expense categories, including bills and healthcare.",
        categoriesFooter: "Select which expense categories to track monthly spending goals for."
    )
}
