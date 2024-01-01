//
//  ResetPasswordViewController.swift
//  PhoneDeneme
//
//  Created by Beste Kocaoglu on 1.01.2024.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var verificationCodeText: UITextField!
    @IBOutlet weak var newPasswordText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sendVerificationCode(_ sender: Any) {
        guard let phoneNumber = phoneNumberText.text else {
            // Eksik bilgi var, kullanıcıyı uyar
            return
        }

        Auth.auth().languageCode = "en" // Telefon doğrulama kodu dilini ayarlayabilirsiniz

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("Doğrulama kodu gönderme hatası: \(error.localizedDescription)")
                // Hata durumunda kullanıcıya uygun bir şekilde geri bildirimde bulunabilirsiniz
            } else {
                // Verification ID'yi uygun bir şekilde saklayabilir veya işleyebilirsiniz
                UserDefaults.standard.set(verificationID, forKey: "verificationID")
                // Doğrulama kodu gönderildi, kullanıcıyı uygun bir şekilde bilgilendirin
            }
        }
    }

    @IBAction func resetPasswordWithVerificationCode(_ sender: Any) {
        guard let verificationCode = verificationCodeText.text,
              let newPassword = newPasswordText.text else {
            // Eksik bilgi var, kullanıcıyı uyar
            return
        }

        guard let verificationID = UserDefaults.standard.string(forKey: "verificationID") else {
            // Doğrulama ID bulunamadı, kullanıcıyı uyar
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Doğrulama hatası: \(error.localizedDescription)")
                // Doğrulama sırasında bir hata oluştu, kullanıcıyı uygun bir şekilde bilgilendirin
            } else {
                // Doğrulama başarılı, şifre sıfırlama işlemini gerçekleştirin
                self.resetPassword(newPassword)
            }
        }
    }

    func resetPassword(_ newPassword: String) {
        guard let user = Auth.auth().currentUser else {
            // Kullanıcı oturum açmamışsa veya doğrulama sırasında hata oluştuysa, kullanıcıyı uyar
            return
        }

        user.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Şifre sıfırlama hatası: \(error.localizedDescription)")
                // Şifre sıfırlama sırasında bir hata oluştu, kullanıcıyı uygun bir şekilde bilgilendirin
            } else {
                // Şifre sıfırlama başarılı, istediğiniz işlemleri gerçekleştirin
                print("Şifre sıfırlama başarılı!")
            }
        }
    }
}

