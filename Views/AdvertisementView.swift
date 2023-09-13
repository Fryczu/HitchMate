//
//  AdvertisementView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 13/09/2023.
//

import Foundation
import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct AdvertisementsView: View {
    //@StateObject var viewModel = MapViewModel()
    @State private var showingAddAdvertisement = false
    @ObservedObject var viewModel: MapViewModel = MapViewModel()

    @State private var showOnlyMyAds = false
    @State private var showingEditAdvertisement = false
    @State private var selectedAd: Advertisement? = Advertisement(
        id: "",
        userID: "",
        startAddress: "",
        endAddress: "",
        departureDate: Date(),
        availableSeats: 1,
        type: Advertisement.AdvertisementType.offering,
        username: "",
        profileImageURL: Optional<URL>.none // jawnie określony typ dla nil
    )
    @State private var isShowingUserProfile = false
    @State private var selectedUserId: String? // przechowuj tutaj userID użytkownika, którego profil chcesz wyświetlić
    @State private var activeSheet: ActiveSheet?
    
    func showUserProfile(_ userID: String) {
        self.selectedUserId = userID
        self.isShowingUserProfile = true
    }



    enum ActiveSheet: Int, Identifiable {
        case addAd, editAd

        var id: Int {
            rawValue
        }
    }

    

    var filteredAds: [Advertisement] {
        guard let userID = Auth.auth().currentUser?.uid else {
            return []
        }
        return showOnlyMyAds ? viewModel.advertisements.filter { $0.userID == userID } : viewModel.advertisements.filter { $0.userID != userID }
    }


    var body: some View {
        VStack {
            Toggle(isOn: $showOnlyMyAds) {
                Text(showOnlyMyAds ? "Moje ogłoszenia" : "Wszystkie ogłoszenia")
            }
            .padding()
            
            Button("Dodaj ogłoszenie") {
                activeSheet = .addAd
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            List(filteredAds, id: \.id) { ad in
                VStack(alignment: .leading) {
                    HStack {
                        if let profileImageURL = ad.profileImageURL {
                            // Pobierz obrazek z internetu (potrzebna zewnętrzna biblioteka, np. SDWebImageSwiftUI)
                            WebImage(url: profileImageURL)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .onTapGesture {
                                    // Wyświetl podgląd profilu
                                    showUserProfile(ad.userID)
                                }
                                .sheet(isPresented: $isShowingUserProfile) {
                                    // Użyj `viewModel` z bieżącego zakresu lub przekaż nową instancję, jeśli potrzebujesz
                                    CheckUserProfileView(userID: selectedUserId ?? "", viewModel: viewModel)
                                }
                        }

                        }
                        VStack(alignment: .leading) {
                            Text(ad.username).foregroundColor(.black)
                            Text(ad.type.rawValue).foregroundColor(.gray)
                            Text("Start: \(ad.startAddress)").foregroundColor(.black)
                            // ... (pozostałe pola)
                        }
                    }

                    Text("Start: \(ad.startAddress)").foregroundColor(.black)
                    Text("Koniec: \(ad.endAddress)").foregroundColor(.black)
                    Text("Data wyjazdu: \(ad.departureDate, style: .date)").foregroundColor(.black)
                    Text("Dostępne miejsca: \(ad.availableSeats)").foregroundColor(.black)
                    
                    if showOnlyMyAds {
                        Button("Edytuj") {
                            print("Editing ad: \(ad)")
                                selectedAd = ad
                                activeSheet = .editAd
                            
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .sheet(item: $activeSheet) { item in
                //print("Wywołanie arkusza dla: \(String(describing: item))")
                switch item {
                case .addAd:
                    AddAdvertisementView(viewModel: viewModel)
                case .editAd:
                    if let adToEdit = selectedAd {
                        
                        EditAdvertisementView(viewModel: viewModel, advertisement: Binding($selectedAd)!)

                    } else {
                        Text("Nie wybrano ogłoszenia do edycji.")
                    }
                }
            }
            .onAppear {
                viewModel.fetchAdvertisements()
            }


            
        }
}

/*struct AdvertisementView_Previews: PreviewProvider {
    static var previews: some View {
        AdvertisementView()
    }
}*/
