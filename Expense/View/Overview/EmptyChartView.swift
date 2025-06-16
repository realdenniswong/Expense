//
//  EmptyChartView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//

import SwiftUI

struct EmptyChartView: View {
    let period: TimePeriod
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No \(period.rawValue.lowercased()) expenses")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 320)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
