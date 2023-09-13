//
//  User.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 13/09/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Decodable {
    @DocumentID var id: String?
    var username: String
    var profileImageURL: URL?
}
