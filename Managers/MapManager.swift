//
//  MapManager.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 09/09/2023.
//

import Foundation
import Firebase
import MapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

extension MapViewModel {
    
    func saveAdvertisement(startAddress: String, endAddress: String, departureDate: Date, availableSeats: Int, type: Advertisement.AdvertisementType, username: String, profileImageURL: URL?) {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: Unable to get current user ID.")
            return
        }

        let db = Firestore.firestore()
        let adData: [String: Any] = [
            "userID": userID,
            "startAddress": startAddress,
            "endAddress": endAddress,
            "departureDate": departureDate,
            "availableSeats": availableSeats,
            "type": type.rawValue,
            "username": username,
            "profileImageURL": profileImageURL?.absoluteString ?? ""
        ]

        let docRef = db.collection("advertisements").document()
        docRef.setData(adData) { error in
            if let error = error {
                print("Error saving advertisement data: \(error)")
            }
        }
    }
    
    func fetchAdvertisements() {
        let db = Firestore.firestore()
        db.collection("advertisements").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Błąd podczas pobierania ogłoszeń: \(err)")
            } else {
                print("Pomyślnie pobrano ogłoszenia: \(querySnapshot!.documents.count) ogłoszeń.") // <-- Dodaj to
                var fetchedAds: [Advertisement] = []
                
                for document in querySnapshot!.documents {
                    do {
                        var ad = try document.data(as: Advertisement.self)
                        ad.id = document.documentID
                        fetchedAds.append(ad)
                    } catch let error {
                        print("Błąd podczas deserializacji ogłoszenia dla dokumentu \(document.documentID): \(error)")
                        print("Dane dokumentu: \(document.data())")
                    }
                }





                
                DispatchQueue.main.async {
                    self.advertisements = fetchedAds
                    print("Zaktualizowano listę ogłoszeń: \(self.advertisements.count) ogłoszeń.") // <-- Dodaj to
                }
            }
        }
    }

    
    
    func updateAdvertisement(advertisement: Advertisement, startAddress: String, endAddress: String, departureDate: Date, availableSeats: Int) {
        guard let adId = advertisement.id else {
            print("Error: Advertisement ID is missing.")
            return
        }

        let db = Firestore.firestore()
        let adData: [String: Any] = [
            "userID": advertisement.userID,
            "startAddress": startAddress,
            "endAddress": endAddress,
            "departureDate": departureDate,
            "availableSeats": availableSeats,
            "type": advertisement.type.rawValue,
            "username": advertisement.username,
            "profileImageURL": advertisement.profileImageURL?.absoluteString ?? ""
        ]

        db.collection("advertisements").document(adId).updateData(adData) { error in
            if let error = error {
                print("Error updating advertisement data: \(error)")
            }
        }
    }


    
    func fetchUser(by userID: String, completion: @escaping (User?) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let user = try? document.data(as: User.self)
                completion(user)
            } else {
                print("Użytkownik nie został znaleziony")
                completion(nil)
            }
        }
    }

}


class MapViewModel: ObservableObject {
    @Published var userAnnotations: [UserAnnotation] = []
    @Published var advertisements: [Advertisement] = []
    @Published var currentUsername: String = ""
    @Published var currentProfileImageURL: URL? = nil

    
    var locationManager = LocationManager()

    var userCurrentLocation: CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    
    private var listener: ListenerRegistration?  // Dodaj to, aby móc przerwać nasłuchiwanie w odpowiednim czasie
        
        deinit {
            listener?.remove()  // Jeśli ViewModel zostanie zniszczony, zaprzestajemy nasłuchiwania
        }
    
    func fetchUserLocations() {
            let db = Firestore.firestore()
            listener = db.collection("usersLocation").addSnapshotListener { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                self.userAnnotations = snapshot?.documents.compactMap({ (document) -> UserAnnotation? in
                    if let latitude = document.data()["latitude"] as? Double,
                       let longitude = document.data()["longitude"] as? Double,
                       let userID = document.data()["userID"] as? String,
                       let destination = document.data()["destination"] as? String {

                        let annotation = UserAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        annotation.userID = userID
                        annotation.title = destination  // Ustawianie tytułu bezpośrednio tutaj
                        return annotation
                    }


                    return nil
                }) ?? []
            }
        }

    func saveUserLocationAndDestination(destination: String, userType: String) {
        guard let currentLocation = userCurrentLocation else {
            print("Error: Unable to get current location.")
            return
        }

        let db = Firestore.firestore()

        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: Unable to get current user ID.")
            return
        }

        let locationData: [String: Any] = [
            "userID": userID,
            "latitude": currentLocation.latitude,
            "longitude": currentLocation.longitude,
            "destination": destination,
            "userType": userType
        ]

        db.collection("usersLocation").document(userID).setData(locationData) { error in
                if let error = error {
                print("Error saving location data: \(error)")
            }
        }
    }
    
    func stopSharingLocation() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: Unable to get current user ID.")
            return
        }
        let db = Firestore.firestore()
        db.collection("usersLocation").document(userID).delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }

}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var location: CLLocation?
    var hasAskedForLocationPermissionKey = "hasAskedForLocationPermission"
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization() // lub requestAlwaysAuthorization() jeśli chcesz stały dostęp
        self.locationManager.startUpdatingLocation() // Rozpocznij aktualizacje lokalizacji
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            location = locations.last
            // Rozważ dodanie warunku, który zapisuje lokalizację tylko jeśli różnica jest większa niż pewna wartość (np. 10 metrów), aby uniknąć nadmiernego zapisywania w bazie danych
            saveCurrentLocationToFirestore()
        }
        
        private func saveCurrentLocationToFirestore() {
            guard let currentLocation = location else {
                return
            }
            let db = Firestore.firestore()
            guard let userID = Auth.auth().currentUser?.uid else {
                print("Error: Unable to get current user ID.")
                return
            }

            let locationData: [String: Any] = [
                "userID": userID,
                "latitude": currentLocation.coordinate.latitude,
                "longitude": currentLocation.coordinate.longitude
            ]

            db.collection("usersLocation").document(userID).setData(locationData) { error in
                if let error = error {
                    print("Error saving location data: \(error)")
                }
            }
    }
    
    func requestLocationPermissionIfNeeded() {
        let hasAskedForLocationPermission = UserDefaults.standard.bool(forKey: hasAskedForLocationPermissionKey)

        if !hasAskedForLocationPermission {
            UserDefaults.standard.setValue(true, forKey: hasAskedForLocationPermissionKey)
            locationManager.requestWhenInUseAuthorization()
        }
    }
}



