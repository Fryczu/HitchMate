//
//  UserProfileView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 09/09/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Binding var profileUIImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = Image(uiImage: uiImage)
                parent.profileUIImage = uiImage // Dodaj tę linię
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}

struct UserProfileView: View {
    @State private var profileUIImage: UIImage?
    @State private var profileImage: Image?
    @State private var pickingImage = false
    @State private var userName: String = ""
    @State private var carInfo: String = ""
    @State private var description: String = ""
    @State private var uploadingData = false
    @State private var isEditingEnabled = false
    @State private var showSaveButton: Bool = false



    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 45, height: 1)
                Text("Przeciągnij w dół aby wrócić")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 45, height: 1)
            }
                .padding(.top, 20)
            
            HStack {
                if let image = profileImage {
                    image
                    .resizable()
                    .frame(width: 150, height: 150) // Zwiększony rozmiar
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.black, lineWidth: 4) // Dodana czarna ramka
                    )
                    .padding()
                    .padding(.leading, 90)
                } else {
                    Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150) // Zwiększony rozmiar dla obrazu zastępczego
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.black, lineWidth: 3) // Dodana czarna ramka
                    )
                    .padding()
                    .onTapGesture {
                        pickingImage = true
                    }
                    .padding(.leading, 120)
                }
                
                Button(action: {
                    isEditingEnabled.toggle()
                    showSaveButton = true // Pokaż przycisk Zapisz, gdy jesteś w trybie edycji
                }) {
                    Image(systemName: "pencil")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(Color.white)
                        .clipShape(Circle())
                        .padding(.leading, 30)
                        .padding(.bottom, 100)
                }
                .disabled(showSaveButton) // Zablokuj przycisk Edytuj, gdy jesteś w trybie zapisywania

            }
            .padding(.bottom, 20)
            .padding(.top, 20)
            
            

            VStack {
                Text("Imię")
                    .font(.headline)
                    .foregroundColor(Color.black)
                    .padding(.trailing, 280)
                TextField("", text: $userName)
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 2)
                            .padding(.horizontal, 20)
                    )
                    .disabled(!isEditingEnabled)
                    .padding(.bottom, 10)
                    .foregroundColor(Color.black)
                Text("Marka i model samochodu")
                    .font(.headline)
                    .foregroundColor(Color.black)
                    .padding(.trailing, 110)
                TextField("", text: $carInfo)
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 2)
                            .padding(.horizontal, 20)
                    )
                    .disabled(!isEditingEnabled)
                    .foregroundColor(Color.black)
                    .padding(.bottom, 10)
                Text("Opis")
                    .font(.headline)
                    .foregroundColor(Color.black)
                    .padding(.trailing, 280)
                TextEditor(text: $description)
                    .padding(.horizontal, 35)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 2)
                            .padding(.horizontal, 20)
                    )
                    .disabled(!isEditingEnabled)
                    .foregroundColor(Color.black)
                    .padding(.bottom, 10)
            }
            .padding(.bottom, 20)
            
            
            

            if showSaveButton {
                Button("Zapisz") {
                    saveUserProfile()
                    showSaveButton = false // Ukryj przycisk Zapisz po zapisaniu
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .disabled(uploadingData)
            }


            Spacer()
        }
        .sheet(isPresented: $pickingImage, onDismiss: loadImage) {
            ImagePicker(image: $profileImage, profileUIImage: $profileUIImage)
        }
        .onAppear(perform: loadUserData)
    }

    func loadImage() {
        func loadImage() {
            if let uiImage = profileUIImage {
                profileImage = Image(uiImage: uiImage)
            }
        }
    }

    func saveUserProfile() {
        uploadingData = true
        if let image = profileUIImage, let data = image.jpegData(compressionQuality: 0.6) {
            let storageRef = Storage.storage().reference().child("profile_images/\(Auth.auth().currentUser!.uid).jpg")

            storageRef.putData(data, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error uploading image: \(error)")
                    self.uploadingData = false
                    return
                }

                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error fetching URL: \(error)")
                        self.uploadingData = false
                        return
                    }

                    if let url = url {
                        let userData: [String: Any] = [
                            "name": self.userName,
                            "carInfo": self.carInfo,
                            "description": self.description,
                            "profileImageURL": url.absoluteString
                        ]

                        let db = Firestore.firestore()
                        // Używamy metody `updateData` zamiast `setData` aby zaktualizować dane bez ich nadpisywania
                        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(userData) { error in
                            if let error = error {
                                print("Error saving user data: \(error)")
                            }
                            self.uploadingData = false
                            self.showSaveButton = false
                        }
                    }
                }
            }
        }
    }

    
    func loadUserData() {
        if let userID = Auth.auth().currentUser?.uid {
            let docRef = Firestore.firestore().collection("users").document(userID)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    self.userName = data?["name"] as? String ?? ""
                    self.carInfo = data?["carInfo"] as? String ?? ""
                    self.description = data?["description"] as? String ?? ""
                    
                    // Jeśli istnieje URL obrazka, próbujemy go załadować
                    if let urlString = data?["profileImageURL"] as? String, let url = URL(string: urlString) {
                        downloadImage(from: url)
                    }
                    
                } else {
                    print("Document does not exist or there was an error.")
                }
            }
        }
    }
    
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = Image(uiImage: uiImage)
                    self.profileUIImage = uiImage
                }
            } else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }


}


struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
