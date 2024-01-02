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

    func registerUser(user: User, password: String, confirmPassword: String, phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Şifre gücü, geçerliliği kontrol etmek için özel kontrolleri ekleyin
        guard password == confirmPassword else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Şifreler uyuşmuyor"])))
            return
        }

        // Firebase Authentication kullanarak e-posta ve şifre ile kullanıcı kaydı yapma
        Auth.auth().createUser(withEmail: user.email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Kullanıcı ID alınması
            guard let uid = authResult?.user.uid else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı ID alınamadı"])))
                return
            }

            // Kullanıcı verilerini Realtime Database'e kaydetme
            let userData = [
                "firstName": user.firstName,
                "lastName": user.lastName,
                "phoneNumber": user.phoneNumber,
                "email": user.email
            ]

            Database.database().reference().child("users").child(uid).setValue(userData) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // Firebase Authentication kullanıcının telefon numarasını kaydetme
                    let user = Auth.auth().currentUser
                    let credential = PhoneAuthProvider.provider().credential(withVerificationID: "verificationID", verificationCode: "verificationCode")
                    
                    user?.updatePhoneNumber(credential, completion: { error in
                        if let error = error {
                            print("Telefon numarasını güncelleme hatası: \(error.localizedDescription)")
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    })
                }
            }
        }
    }


    func startPhoneNumberVerification(_ phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Telefon numarası doğrulama işlemi
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("Doğrulama kodu gönderme hatası: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            // Verification ID'yi uygun bir şekilde saklama
            UserDefaults.standard.set(verificationID, forKey: "verificationID")
            // Doğrulama kodu gönderildi
            completion(.success(()))
        }
    }

    func verifyPhoneNumber(with verificationCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let verificationID = UserDefaults.standard.string(forKey: "verificationID") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Doğrulama ID bulunamadı"])))
            return
        }

        // Telefon numarası doğrulama işlemi
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Doğrulama başarılı
                completion(.success(()))
            }
        }
    }
}





