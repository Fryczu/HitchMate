//
//  ShareLocationView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 10/09/2023.
//

import SwiftUI

struct ShareLocationView: View {
    @State private var destination: String = ""
    @State private var userType: String = "driver" // domyślna wartość, może to być 'hitchhiker' lub 'driver'
    @StateObject var viewModel = MapViewModel() // Twój ViewModel

    var body: some View {
        VStack(spacing: 20) {
            TextField("Wprowadź kierunek docelowy", text: $destination)

            Picker("Typ użytkownika", selection: $userType) {
                Text("Kierowca").tag("driver")
                Text("Autostopowicz").tag("hitchhiker")
            }.pickerStyle(SegmentedPickerStyle())

            Button("Udostępnij moją lokalizację") {
                viewModel.saveUserLocationAndDestination(destination: destination, userType: userType)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

        }
        .padding()
    }
}


struct ShareLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ShareLocationView()
    }
}
