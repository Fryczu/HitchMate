//
//  MapView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 09/09/2023.
//

import SwiftUI
import MapKit
import FirebaseFunctions

class UserAnnotation: MKPointAnnotation {
    var userID: String?
    var userType: String?
    var destination: String? {
        didSet {
            self.title = destination
        }
    }
}


struct MapView: UIViewRepresentable {
    @Binding var showUserLocation: Bool
    @Binding var currentLocation: CLLocationCoordinate2D?
    var annotations: [UserAnnotation]

    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = showUserLocation
        if showUserLocation {
            mapView.userTrackingMode = .follow
        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.showsUserLocation = showUserLocation
        uiView.addAnnotations(annotations)
        
        if let currentLocation = currentLocation {
            let region = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            uiView.setRegion(region, animated: true)
        }
    }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? UserAnnotation else { return nil }

            let identifier = "userAnnotation"
            var view: MKMarkerAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)   // Dodawanie przycisku
            }

            // Ustawianie koloru markerów
            if annotation.userType == "hitchhiker" {
                view.markerTintColor = .blue
            } else {
                view.markerTintColor = .green
            }
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) // Dodawanie przycisku

            view.glyphImage = nil  // Ustaw to na nil, jeśli nie chcesz używać obrazu w miejscu domyślnego znaku

            return view
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? UserAnnotation else { return }
            
            // Identyfikacja użytkownika i wysyłanie powiadomienia
            if let userID = annotation.userID {
                sendNotification(to: userID)
            }
        }
        
        func sendNotification(to userID: String) {
            // Tutaj skonfiguruj połączenie z serwerem i wysłanie powiadomienia
            print("Sending notification to user: \(userID)")
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let userAnnotation = view.annotation as? UserAnnotation {
                let userId = userAnnotation.userID
                // Wywołaj funkcję Firebase Cloud Functions, aby wysłać powiadomienie
                let functions = Functions.functions()
                functions.httpsCallable("sendNotification").call(["userId": userId]) { (result, error) in
                    if let error = error {
                        print("Błąd: \(error.localizedDescription)")
                    }
                    if let success = (result?.data as? [String: Bool])?["success"], success {
                        print("Powiadomienie zostało wysłane!")
                    }
                }
            }
        }

    }
}



/*struct MapView_Previews: PreviewProvider {
    static var sampleAnnotations: [MKPointAnnotation] = {
        var annotations = [MKPointAnnotation]()
        
        let annotation = MKPointAnnotation()
        annotation.title = "Przykład"
        annotation.subtitle = "Przykładowy podtytuł"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122) // przykładowe współrzędne Warszawy
        annotations.append(annotation)
        
        return annotations
    }()
    
    static var previews: some View {
        MapView(annotations: .constant(sampleAnnotations))
    }
}*/
