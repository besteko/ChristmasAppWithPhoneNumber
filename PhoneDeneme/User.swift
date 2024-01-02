//
//  User.swift
//  PhoneDeneme
//
//  Created by Beste Kocaoglu on 30.12.2023.
//

import Foundation


struct User {
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var email: String
    var profilePictureURL: String? // Örnek: Profil fotoğrafının URL'i
    // Diğer kullanıcı bilgilerini ekleyebilirsiniz

    init(firstName: String, lastName: String, phoneNumber: String, email: String, profilePictureURL: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.profilePictureURL = profilePictureURL
    }
}


