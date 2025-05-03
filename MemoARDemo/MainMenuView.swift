//
//  MainMenuView.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

import SwiftUI

// MainMenuView.swift
import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var dataManager: GameDataManager
    
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            
            GameSelectionView()
                .tabItem {
                    Label("Play", systemImage: "gamecontroller")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
        }
    }
}
