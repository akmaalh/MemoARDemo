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
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .environmentObject(dataManager)
        }
    }
}
