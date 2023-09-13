//
//  Advertisement.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 13/09/2023.
//

import Foundation

class Advertisement: Codable {
    var id: String?
    var userID: String?
    var startAddress: String
    var endAddress: String
    var departureDate: Date
    var availableSeats: Int
    var type: AdvertisementType
    var username: String
    var profileImageURL: URL?

    enum AdvertisementType: String {
        case seeking = "Szukam"
        case offering = "Oferuję"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userID, startAddress, endAddress, departureDate, availableSeats, type, username, profileImageURL
    }
    
    init(id: String,
             userID: String,
             startAddress: String,
             endAddress: String,
             departureDate: Date,
             availableSeats: Int,
             type: AdvertisementType,
             username: String,
             profileImageURL: URL?) {
            self.id = id
            self.userID = userID
            self.startAddress = startAddress
            self.endAddress = endAddress
            self.departureDate = departureDate
            self.availableSeats = availableSeats
            self.type = type
            self.username = username
            self.profileImageURL = profileImageURL
        }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userID = try container.decode(String.self, forKey: .userID)
        startAddress = try container.decode(String.self, forKey: .startAddress)
        endAddress = try container.decode(String.self, forKey: .endAddress)
        departureDate = try container.decode(Date.self, forKey: .departureDate)
        availableSeats = try container.decode(Int.self, forKey: .availableSeats)
        
        let typeString = try container.decode(String.self, forKey: .type)
        if let advertisementType = AdvertisementType(rawValue: typeString) {
            type = advertisementType
        } else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid AdvertisementType")
        }
        
        username = try container.decode(String.self, forKey: .username)
        
        if let profileImageString = try? container.decode(String.self, forKey: .profileImageURL) {
            profileImageURL = URL(string: profileImageString)
        } else {
            profileImageURL = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userID, forKey: .userID)
        try container.encode(startAddress, forKey: .startAddress)
        try container.encode(endAddress, forKey: .endAddress)
        try container.encode(departureDate, forKey: .departureDate)
        try container.encode(availableSeats, forKey: .availableSeats)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(username, forKey: .username)
        
        if let profileImageString = profileImageURL?.absoluteString {
            try container.encode(profileImageString, forKey: .profileImageURL)
        }
    }

}


