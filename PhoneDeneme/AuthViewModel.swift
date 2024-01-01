//
//  AuthViewModel.swift
//  PhoneDeneme
//
//  Created by Beste Kocaoglu on 30.12.2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class AuthViewModel {

    func registerUser(user: User, password: String, confirmPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard password == confirmPassword else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Şifreler uyuşmuyor"])))
            return
        }

        Auth.auth().createUser(withEmail: user.email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let uid = authResult?.user.uid else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı ID alınamadı"])))
                return
            }

            let userData = ["firstName": user.firstName, "lastName": user.lastName, "phoneNumber": user.phoneNumber, "email": user.email]
            Database.database().reference().child("users").child(uid).setValue(userData)

            self.startPhoneNumberVerification(user.phoneNumber) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func startPhoneNumberVerification(_ phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("Doğrulama kodu gönderme hatası: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            // Verification ID'yi uygun bir şekilde saklayabilir veya işleyebilirsiniz
            UserDefaults.standard.set(verificationID, forKey: "verificationID")
            // Doğrulama kodu gönderildi, kullanıcıyı uygun bir şekilde bilgilendirin
            completion(.success(()))
        }
    }
    func verifyPhoneNumber(with verificationCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
           guard let verificationID = UserDefaults.standard.string(forKey: "verificationID") else {
               completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Doğrulama ID bulunamadı"])))
               return
           }

           let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
           
           Auth.auth().signIn(with: credential) { authResult, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }

               // Doğrulama başarılı, istediğiniz işlemleri gerçekleştirin
               completion(.success(()))
           }
       }
    func saveUserToRealTimeDatabase(user: User, completion: @escaping (Bool) -> Void) {
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }

            let userData = [
                "firstName": user.firstName,
                "lastName": user.lastName,
                "phoneNumber": user.phoneNumber,
                "email": user.email
            ]

            Database.database().reference().child("users").child(currentUserID).setValue(userData) { error, _ in
                if let error = error {
                    print("Realtime Database kaydetme hatası: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
   }




