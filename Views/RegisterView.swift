//
//  RegisterView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 06/09/2023.
//

import SwiftUI
import Firebase
import Foundation
import Combine

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var alertMessage = ""
    @State private var alertIndicator = false
    @State private var showAlert = false
    
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @State private var isConfirmPasswordValid = false
    
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    @State var isPresented = false
    
    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 45, height: 1)
                Text("Przeciągnij w dół aby wrócić")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 45, height: 1)
            }
                .padding(.top, 20)
                .offset(x: 0, y: -70)
            
            Text("ZAŁÓŻ KONTO W ")
                .font(Font.custom("AvenirNext-Bold", size: 28))
                .padding(.bottom, 0)
            HStack() {
                Text("HITCH")
                    .foregroundColor(Color.blue)
                Text("MATE")
                    .foregroundColor(Color.green)
            }
                .font(Font.custom("AvenirNext-Bold", size: 28))
                .padding(.bottom, 20)
            
            Text("... i dołącz do rosnącej społeczności autostopowiczów! :)")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)

            TextField("E-mail", text: $email)
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isEmailValid ? Color.green : (email.isEmpty ? Color.gray : Color.red), lineWidth: 2)
                            .padding(.horizontal, 20)
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.bottom, 10)
                    .onReceive(Just(email)) { input in
                        isEmailValid = emailValidation(email: input)
                    }
            
            
            HStack {
                if isPasswordVisible {
                    TextField("Hasło", text: $password)
                } else {
                    SecureField("Hasło", text: $password)
                }
                
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
            .padding(.horizontal, 40)
            .frame(height: 50)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isPasswordValid ? Color.green : (password.isEmpty ? Color.gray : Color.red), lineWidth: 2)
                    .padding(.horizontal, 20)
            )
            .padding(.bottom, 10)
            .onChange(of: password) { value in
                isPasswordValid = password.count >= 8
                isConfirmPasswordValid = (confirmPassword == password && !password.isEmpty)
            }
            
            if !isPasswordValid && !password.isEmpty {
                Text("Hasło musi mieć minimum 8 znaków")
                    .foregroundColor(Color.red)
                    .font(Font.footnote)
                    .offset(x: 0, y: -10)
            }
            
            
            HStack {
                if isConfirmPasswordVisible {
                    TextField("Powtórz hasło", text: $confirmPassword)
                } else {
                    SecureField("Powtórz hasło", text: $confirmPassword)
                }
                
                Button(action: { isConfirmPasswordVisible.toggle() }) {
                    Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
                .padding(.horizontal, 40)
                .frame(height: 50)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isConfirmPasswordValid ? Color.green : (confirmPassword.isEmpty ? Color.gray : Color.red), lineWidth: 2)
                    .padding(.horizontal, 20)
                )
                .padding(.bottom, 30)
                .onChange(of: confirmPassword) { value in
                    isConfirmPasswordValid = (confirmPassword == password && !password.isEmpty)
                }
            
            if !isConfirmPasswordValid && !confirmPassword.isEmpty {
             Text("Hasła muszą być takie same")
                 .foregroundColor(Color.red)
                 .font(Font.footnote)
                 .offset(x: 0, y: -30)
            }
            
            Button("Zarejestruj się") {
                register()
            }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isRegistrationEnabled ? Color.black : Color.gray)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
                .disabled(!isRegistrationEnabled)
            
        }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage), dismissButton: .default(Text(alertIndicator ? "Przejdź do logowania" : "Spróbuj ponownie"), action: {
                    if alertMessage == "Konto zostało utworzone. Zaloguj się, aby kontynuować." {
                        presentationMode.wrappedValue.dismiss()
                    }
                }))
            }
    }
    
    
    //---------------------------- FUNKCJE ----------------------------
    
    func register() {
        Auth.auth().fetchSignInMethods(forEmail: email) { (providers, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let _ = providers {
                // adres email jest już w bazie danych
                alertMessage = "Na podany adres e-mail zostało już utworzone konto. Użyj innego adresu, albo zaloguj się z użyciem obecnego."
                clearFields()
                showAlert = true
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let user = result?.user {
                    // Dodaj dane użytkownika do Firestore
                    addUserToFirestore(userID: user.uid, email: email)
                }
                    // konto zostało utworzone
                    alertMessage = "Konto zostało utworzone. Zaloguj się, aby kontynuować."
                    alertIndicator = true
                    showAlert = true
                }
            
                
            }
        
            
            
            
    }
    
    func emailValidation(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        /*let emailRegEx = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"*/
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func passwordValidation(password: String) -> Bool {
        return true
    }
    
    private var isRegistrationEnabled: Bool {
        return isEmailValid && isPasswordValid && isConfirmPasswordValid
    }
    
    func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    func addUserToFirestore(userID: String, email: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).setData([
            "email": email,
            "name": "",
            "carInfo": "",
            "description": "",
            "profileImageURL": ""
            // Dodaj inne informacje, które chcesz przechować, np. "name": "Jan Kowalski"
        ]) { error in
            if let error = error {
                print("Błąd podczas zapisywania użytkownika do Firestore: \(error.localizedDescription)")
            } else {
                print("Użytkownik pomyślnie dodany do Firestore!")
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
