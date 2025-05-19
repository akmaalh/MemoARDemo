//
//  MemoARDemoApp.swift
//  MemoARDemo
//
//  Created by Akmal Hakim on 03/05/25.
//

import SwiftUI

@main
struct MemoARDemoApp: App {
    @StateObject private var dataManager = GameDataManager()
    @State private var showUserForm = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                HomeScreen()
                    .environmentObject(dataManager)
                
                if showUserForm {
                    UserFormView(onUserCreated: {
                        withAnimation {
                            showUserForm = false
                        }
                    })
                    .environmentObject(dataManager)
                    .transition(.opacity)
                }
            }
            .onAppear {
                // Check if user exists
                if dataManager.getCurrentUser() == nil {
                    withAnimation {
                        showUserForm = true
                    }
                }
            }
        }
    }
}
