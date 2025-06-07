//
//  BottomBarView.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI

struct BottomBarView: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        Spacer()
        TabView(selection: $selectedTab) {
            Text("Listen Now Content")
                .tabItem {
                    Image(systemName: "play.circle")
                    Text("Listen Now")
                }
                .tag(0)
            
            Text("Browse Content")
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Browse")
                }
                .tag(1)
            
            Text("Radio Content")
                .tabItem {
                    Image(systemName: "radio")
                    Text("Radio")
                }
                .tag(2)
            
            Text("Library Content")
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Library")
                }
                .tag(3)
            
            Text("Search Content")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(4)
        }
        .accentColor(.pink)
    }
}
