//
//  PasswordResetView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 09/09/2023.
//

import SwiftUI
import Firebase

struct PasswordResetView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
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
                .offset(x: 0, y: -250)
            
            Text("Podaj adres e-mail twojego konta, na który wyślemy link do zresetowania hasła.")
                .font(.headline)
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .padding(.bottom, 20)
                .multilineTextAlignment(.center)
            
            TextField("E-mail", text: $email)
                .padding(.horizontal, 40)
                .frame(height: 50)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 2)
                        .padding(.horizontal, 20)
                )
                .padding(.bottom, 15)
            
            Button("Zresetuj hasło") {
                passwordReset()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("Przejdź do logowania"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
    }
    
    func passwordReset() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                alertMessage = "Link do zresetowania hasła został wysłany na wskazany adres e-mail."
                showAlert = true
            }
        }
    }
    
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}

