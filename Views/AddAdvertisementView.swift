//
//  AddAdvertisementView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 13/09/2023.
//

import SwiftUI

struct AddAdvertisementView: View {
    @ObservedObject var viewModel: MapViewModel

    @State private var startAddress: String = ""
    @State private var endAddress: String = ""
    @State private var departureDate: Date = Date()
    @State private var availableSeats: Int = 1
    @State private var advertisementType: Advertisement.AdvertisementType = .offering
    

    var body: some View {
            VStack(spacing: 20) {
                Picker("Rodzaj ogłoszenia", selection: $advertisementType) {
                    Text(Advertisement.AdvertisementType.offering.rawValue).tag(Advertisement.AdvertisementType.offering)
                    Text(Advertisement.AdvertisementType.seeking.rawValue).tag(Advertisement.AdvertisementType.seeking)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("Adres początkowy", text: $startAddress)
                    .foregroundColor(.black)
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal)

                TextField("Adres końcowy", text: $endAddress)
                    .foregroundColor(.black)
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal)

                DatePicker("Data wyjazdu", selection: $departureDate, displayedComponents: .date)
                    .foregroundColor(.black)
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal)

                Stepper("Dostępne miejsca: \(availableSeats)", value: $availableSeats, in: 1...6)
                    .foregroundColor(.black)

                Button("Dodaj ogłoszenie") {
                    viewModel.saveAdvertisement(
                        startAddress: startAddress,
                        endAddress: endAddress,
                        departureDate: departureDate,
                        availableSeats: availableSeats,
                        type: advertisementType,
                        username: viewModel.currentUsername,
                        profileImageURL: viewModel.currentProfileImageURL
                    )
                }

            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}


/*struct AddAdvertisementView_Previews: PreviewProvider {
    static var previews: some View {
        AddAdvertisementView(viewModel: MapViewModel)
    }
}*/
