//
//  ContentView.swift
//  MemoARDemo
//
//  Created by Akmal Hakim on 03/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = GameDataManager()
    
    var body: some View {
        if dataManager.hasUser {
            // Pass an actual closure for onStartGame
            MainMenuView()
            .environmentObject(dataManager)
        } else {
            UserFormView(onUserCreated: {
                // Logic to execute when user is created
                print("User created")
            })
            .environmentObject(dataManager)
        }
    }
}
