//
//  View+Extensions.swift
//  Expense
//
//  Created by Dennis Wong on 17/6/2025.
//

import SwiftUI
import Charts

// MARK: - Alert Helper
struct AlertState {
    var isShowing = false
    var title = ""
    var message = ""
    
    mutating func show(title: String, message: String) {
        self.title = title
        self.message = message
        self.isShowing = true
    }
    
    mutating func success(_ message: String) {
        show(title: "Success", message: message)
    }
    
    mutating func error(_ message: String) {
        show(title: "Error", message: message)
    }
}

extension View {
    func alertPresentation(_ alertState: Binding<AlertState>) -> some View {
        alert(alertState.wrappedValue.title, isPresented: alertState.isShowing) {
            Button("OK") { }
        } message: {
            Text(alertState.wrappedValue.message)
        }
    }
    
    func standardChartStyle() -> some View {
        self
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
    }
    
    func pieChartStyle() -> some View {
        self
            .chartBackground { _ in Color.clear }
            .frame(height: 320)
    }
    
    func barChartStyle() -> some View {
        self
            .frame(height: 200)
            .standardChartStyle()
    }
}
