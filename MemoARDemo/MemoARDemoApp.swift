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
    @State private var showTutorial = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                HomeScreen()
                    .environmentObject(dataManager)
                    .opacity((showUserForm || showTutorial) ? 0 : 1)
                
                if showUserForm {
                    UserFormView(onUserCreated: {
                        withAnimation {
                            showUserForm = false
                            showTutorial = true
                        }
                    })
                    .environmentObject(dataManager)
                    .transition(.opacity)
                }
                
                if showTutorial {
                    TutorialView() {
                        withAnimation {
                            showTutorial = false
                        }
                    }
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
            .environment(\.locale, Locale(identifier: "id"))
        }
    }
}
