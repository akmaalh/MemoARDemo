//
//  ProfileView.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

// ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataManager: GameDataManager
    @State private var showingEditForm = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding()
                
                if let user = dataManager.currentUser {
                    Text("Name: \(user.name)")
                        .font(.title2)
                    
                    Text("Age: \(user.age)")
                        .font(.title3)
                    
                    Text("High Score: \(user.highScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                }
                
                Spacer()
                
                Button("Edit Profile") {
                    showingEditForm = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                NavigationLink(destination: GameSelectionView()) {
                    Text("Play Game")
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: HistoryView()) {
                    Text("View Game History")
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Player Profile")
            .sheet(isPresented: $showingEditForm) {
                EditProfileView()
            }
        }
    }
}

// EditProfileView.swift

struct EditProfileView: View {
    @EnvironmentObject var dataManager: GameDataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var age: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if let user = dataManager.currentUser {
                    name = user.name
                    age = "\(user.age)"
                }
            }
        }
    }
    
    private func saveChanges() {
        guard !name.isEmpty, let ageValue = Int(age), ageValue > 0 else {
            return
        }
        
        if var user = dataManager.currentUser {
            user.name = name
            user.age = ageValue
            dataManager.saveUser(user)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}
