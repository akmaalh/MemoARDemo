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
    @FocusState private var focusedField: Field?
    var onUserCreated: () -> Void
    
    // Colors from HomeScreen
    let backgroundColor = Color(red: 0.98, green: 0.97, blue: 0.93) // Light cream
    let mainColor = Color(red: 0.95, green: 0.78, blue: 0.44) // Soft Yellow
    let secondaryColor = Color(red: 0.69, green: 0.25, blue: 0.07) // Dark Brown
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark text
    let placeholderColor = Color(red: 0.4, green: 0.4, blue: 0.4) // Darker gray for better visibility
    let inputTextColor = Color.black // Black for input text
    
    enum Field {
        case name, age
    }
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Logo
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 50)
                    .foregroundColor(mainColor)
                
                Text("MemoAR")
                    .font(.custom("verdana-bold", size: 45))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                
                Text("Selamat Datang di MemoAR")
                    .font(.custom("verdana-bold", size: 25))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Masukkan data diri kamu")
                    .font(.custom("verdana", size: 20))
                    .foregroundColor(textColor)
                    .padding(.bottom, 20)
                
                VStack(spacing: 20) {
                    ZStack(alignment: .leading) {
                        TextField("", text: $name)
                            .font(.custom("verdana", size: 20))
                            .foregroundColor(inputTextColor)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(secondaryColor.opacity(0.3), lineWidth: 2)
                            )
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .age
                            }
                        
                        if name.isEmpty {
                            Text("Nama")
                                .font(.custom("verdana", size: 20))
                                .foregroundColor(secondaryColor.opacity(0.7))
                                .padding(.leading, 20)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        TextField("", text: $age)
                            .font(.custom("verdana", size: 20))
                            .foregroundColor(inputTextColor)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(secondaryColor.opacity(0.3), lineWidth: 2)
                            )
                            .focused($focusedField, equals: .age)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Selesai") {
                                        focusedField = nil
                                    }
                                    .font(.custom("verdana-bold", size: 18))
                                    .foregroundColor(secondaryColor)
                                }
                            }
                        
                        if age.isEmpty {
                            Text("Umur")
                                .font(.custom("verdana", size: 20))
                                .foregroundColor(secondaryColor.opacity(0.7))
                                .padding(.leading, 20)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                Button(action: saveUser) {
                    Text("Masuk")
                        .font(.custom("verdana-bold", size: 24))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .background(mainColor)
                        .foregroundColor(secondaryColor)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(secondaryColor.opacity(0.6), lineWidth: 3)
                        )
                }
                .disabled(name.isEmpty || age.isEmpty)
                .opacity(name.isEmpty || age.isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .onTapGesture {
            focusedField = nil
        }
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

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.black)
            .accentColor(.black)
            .tint(.black)
    }
}

// Extension to support custom placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
