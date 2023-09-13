//
//  EditAdvertisementView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 13/09/2023.
//

import SwiftUI

struct EditAdvertisementView: View {
    @ObservedObject var viewModel: MapViewModel
    @Binding var advertisement: Advertisement

    @State private var startAddress: String
    @State private var endAddress: String
    @State private var departureDate: Date
    @State private var availableSeats: Int

    init(viewModel: MapViewModel, advertisement: Binding<Advertisement>) {
        self.viewModel = viewModel
        _advertisement = advertisement
        _startAddress = State(wrappedValue: advertisement.wrappedValue.startAddress)
        _endAddress = State(wrappedValue: advertisement.wrappedValue.endAddress)
        _departureDate = State(wrappedValue: advertisement.wrappedValue.departureDate)
        _availableSeats = State(wrappedValue: advertisement.wrappedValue.availableSeats)
    }


    var body: some View {
        VStack(spacing: 20) {
            TextField("Adres początkowy", text: $startAddress)
            TextField("Adres końcowy", text: $endAddress)
            DatePicker("Data wyjazdu", selection: $departureDate, displayedComponents: .date)
            Stepper("Dostępne miejsca: \(availableSeats)", value: $availableSeats, in: 1...6)

            Button("Zaktualizuj ogłoszenie") {
                viewModel.updateAdvertisement(advertisement: advertisement,
                                              startAddress: startAddress,
                                              endAddress: endAddress,
                                              departureDate: departureDate,
                                              availableSeats: availableSeats)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

/*struct EditAdvertisementView_Previews: PreviewProvider {
    static var previews: some View {
        EditAdvertisementView()
    }
}*/
