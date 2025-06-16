//
//  GoalsSettingsView.swift
//  Expense
//
//  Created by Dennis Wong on 13/6/2025.
//
import SwiftUI

// MARK: - Simplified Reusable Goals Settings View
struct GoalsSettingsView: View {
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
                    ZStack {
                        Circle()
                            .fill(period.iconColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: period.iconName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(period.iconColor)
                    }
                    
                    Text("Show Goals")
                    
                    Spacer()
                    
                    Toggle("", isOn: showGoals)
                }
                .padding(.vertical, -4)
            } footer: {
                Text(period.description)
            }
            
            if showGoals.wrappedValue {
                Section {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        HStack {
                            CategoryIcon(category: category, size: 40, iconSize: 16)
                            
                            Text(category.rawValue)
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { isCategoryEnabled(category) },
                                set: { _ in toggleCategory(category) }
                            ))
                        }
                        .padding(.vertical, -4)
                    }
                } header: {
                    Text("Categories")
                } footer: {
                    Text(period.categoriesFooter)
                }
            }
        }
        .navigationTitle(period.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Simplified Specific Goal Settings Views (much cleaner!)
struct DailyGoalsSettingsView: View {
    @Bindable var settings: Settings
    
    var body: some View {
        GoalsSettingsView(period: .daily, settings: settings)
    }
}

struct WeeklyGoalsSettingsView: View {
    @Bindable var settings: Settings
    
    var body: some View {
        GoalsSettingsView(period: .weekly, settings: settings)
    }
}

struct MonthlyGoalsSettingsView: View {
    @Bindable var settings: Settings
    
    var body: some View {
        GoalsSettingsView(period: .monthly, settings: settings)
    }
}
