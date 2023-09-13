//
//  CheckUserProfileView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 13/09/2023.
//

import SwiftUI
import Foundation

struct CheckUserProfileView: View {
    var userID: String
    @ObservedObject var viewModel: MapViewModel
    @State private var user: User?
    
    init(userID: String, viewModel: MapViewModel) {
            self.userID = userID
            self.viewModel = viewModel
        }
    
    var body: some View {
        VStack {
            if let user = user {
                if let imageURL = user.profileImageURL,
                   let image = UIImage(data: try! Data(contentsOf: imageURL)) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .padding()
                }
                
                Text(user.username)
                    .font(.largeTitle)
                
                // Dodaj więcej informacji o użytkowniku jeśli potrzebujesz
            } else {
                Text("Ładowanie...")
            }
        }
        .onAppear(perform: loadUserData)
    }
    
    func loadUserData() {
        viewModel.fetchUser(by: userID) { fetchedUser in
            self.user = fetchedUser
        }
    }
}


/*struct CheckUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CheckUserProfileView()
    }
}*/
