//
//  UserPanelView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 06/09/2023.
//

import SwiftUI
import Firebase
import MapKit

struct UserPanelView: View {
    @StateObject var viewModel = MapViewModel()
    @State private var showingProfile = false
    @State private var showingShareLocation = false
    @State private var currentLocation: CLLocationCoordinate2D?
    @State private var showUserLocation: Bool = true
    @State private var isSharingLocation = false
    @State private var showingAdvertisements = false


    var body: some View {
        ZStack {
            MapView(showUserLocation: $showUserLocation, currentLocation: $currentLocation, annotations: viewModel.userAnnotations)
                .edgesIgnoringSafeArea(.all) // Pozwala mapie wypełnić całą dostępną przestrzeń
            
            // Przycisk "Udostępnij swoją lokalizację"
            Button(action: {
                if isSharingLocation {
                    viewModel.stopSharingLocation()
                    isSharingLocation = false
                } else {
                    showingShareLocation = true
                    isSharingLocation = true
                }
            }) {
                Image(systemName: "hand.thumbsup.fill") // Ikonka łapki w górę
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
            .padding(25)
            .background(Color.black)
            .clipShape(Circle())
            .overlay( // Dodaje obramówkę
                Circle()
                    .stroke(Color.white, lineWidth: 5) // Biała obramówka o grubości 3
            )
            .padding(.bottom, 650)
            .padding(.leading, 250)
            
            // Przycisk "Profil"
            Button(action: {
                showingProfile = true
            }) {
                Text("Profil")
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Pozycjonuje przycisk na dole ekranu
            .padding()
            
            Button(action: {
                showingAdvertisements = true
            }) {
                Text("Ogłoszenia")
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .cornerRadius(8)
            .padding(.trailing, 100)
        }
        .sheet(isPresented: $showingShareLocation) {
            ShareLocationView()
        }
        .sheet(isPresented: $showingProfile) {
            UserProfileView()
        }
        .sheet(isPresented: $showingAdvertisements) {
            AdvertisementsView()
        }
        .onAppear {
            viewModel.fetchUserLocations()
        }
    }
}



struct UserPanelView_Previews: PreviewProvider {
    static var previews: some View {
        UserPanelView()
    }
}
