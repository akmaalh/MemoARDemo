//
//  UserFormView.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

// UserFormView.swift
import SwiftUI

struct UserFormView: View {
    @EnvironmentObject var dataManager: GameDataManager
    @State private var name: String = ""
    @State private var age: String = ""
    var onUserCreated: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Kitchen Hunt")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter your name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Enter your age", text: $age)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Save and Continue") {
                saveUser()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(name.isEmpty || age.isEmpty)
        }
        .padding()
    }
    
    private func saveUser() {
        guard !name.isEmpty, let ageValue = Int(age), ageValue > 0 else {
            return
        }
        
        let user = User(name: name, age: ageValue)
        dataManager.saveUser(user)
        onUserCreated()
    }
}
