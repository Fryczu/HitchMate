//
//  LoginView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 06/09/2023.
//


import SwiftUI
import CoreData
import Firebase
import CoreLocation

struct HitchMateLogo: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.green]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: size, height: size)
            Text("HM")
                .font(Font.custom("AvenirNext-Bold", size: size/2))
                .foregroundColor(.black)
        }
    }
}



struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    //nawigacja pomiędzy LoginView, RegisterView i PasswordResetView
    @State var isPresented = false
    @State var isPresentedReset = false
    
    @State var loginAttempt = true
    @State var isLoggedIn = false
    
    @State private var showModal = false
    @StateObject private var locationManager = LocationManager()
    
    let hasAskedForLocationPermissionKey = "hasAskedForLocationPermission"

    
    
    var body: some View {
        VStack {
            HitchMateLogo(size: 200)
                .padding(.bottom, 20)
            
            HStack(spacing: 0) {
                Text("WITAMY W ")
                    .font(Font.custom("AvenirNext-Bold", size: 28))
                Text("HITCH")
                    .font(Font.custom("AvenirNext-Bold", size: 28))
                    .foregroundColor(Color.blue)
                Text("MATE")
                    .font(Font.custom("AvenirNext-Bold", size: 28))
                    .foregroundColor(Color.green)
            }
            .padding(.bottom, 15)
            
            
            TextField("E-mail", text: $email)
                .padding(.horizontal, 40)
                .frame(height: 50)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 2)
                        .padding(.horizontal, 20)
                )
                .padding(.bottom, 10)
            
            
            SecureField("Hasło", text: $password)
                .padding(.horizontal, 40)
                .frame(height: 50)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 2)
                        .padding(.horizontal, 20)
                )
                .padding(.bottom, 30)
            
            
            if !loginAttempt {
                Text("Zły e-mail lub hasło. Spróbuj ponownie.")
                    .font(.footnote)
                    .foregroundColor(Color.red)
                    .offset(x: 0, y: -30)
                    .padding(.bottom, -30)
            }
            
    
            Button("Zaloguj się") {
                login()
            }
            .fullScreenCover(isPresented: $isLoggedIn, content: UserPanelView.init)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            HStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 70, height: 1)
                Text("Nie posiadasz konta?")
                    .foregroundColor(.gray)
                    .font(.headline)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 70, height: 1)
            }
            .padding(.bottom, 10)
            
            Button("Zarejestruj się") {
                self.isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                RegisterView()
            }
            .font(.headline)
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 2)
                    .padding(2)
                    .padding(.horizontal, 18)
            )
            .padding(.bottom, 50)
            
            Button("Nie pamiętasz hasła?") {
                self.isPresentedReset = true
            }
            .sheet(isPresented: $isPresentedReset) {
                PasswordResetView()
            }
            .font(.headline)
            .foregroundColor(Color.gray)
            
            
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                loginAttempt = false
                clear()
            } else {
                loginAttempt = true
                isLoggedIn = true
                locationManager.requestLocationPermissionIfNeeded()
            }
            
        }
        
    }
        
    func clear() {
        email = ""
        password = ""
    }
    
}





struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
