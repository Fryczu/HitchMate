//
//  ContentView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 06/09/2023.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @ObservedObject var userManager = UserManager()

    var body: some View {
        if userManager.isLogged {
            UserPanelView()
        } else {
            VStack {
                LoginView()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
