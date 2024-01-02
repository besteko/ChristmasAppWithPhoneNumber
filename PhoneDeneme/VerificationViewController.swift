//
//  VerificationViewController.swift
//  PhoneDeneme
//
//  Created by Beste Kocaoglu on 30.12.2023.
//

import UIKit
import FirebaseAuth
import Firebase

class VerificationViewController: UIViewController {
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    var authViewModel: AuthViewModel!
    var phoneNumber: String!
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String!
    var confirmPassword: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func verifyButtonTapped(_ sender: Any) {
            guard let verificationCode = verificationCodeTextField.text else {
                // Eksik bilgi var, kullanıcıyı uyar
                return
            }

            authViewModel.verifyPhoneNumber(with: verificationCode) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    // Doğrulama başarılı, kullanıcıyı authentication ve real-time'a kaydet
                    print("Email: \(self.email), Password: \(self.password ?? "Password değeri nil")")
                    self.registerUserInAuthentication()
                    // diğer işlemler...
                case .failure(let error):
                    // Doğrulama sırasında bir hata oluştu, kullanıcıyı uyar
                    print("Doğrulama hatası: \(error.localizedDescription)")
                }
            }
        }


    private func registerUserInAuthentication() {
        guard let email = email, let password = password else {
            // email veya password nil ise, işlemi sonlandır ve kullanıcıyı uygun şekilde bilgilendir.
            print("Hata: email veya password eksik veya boş.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Authentication kayıt hatası: \(error.localizedDescription)")

                // Hata mesajını kullanıcıya bildir
                self.showErrorMessage(error.localizedDescription)

                // İşlemi durdur
                return
            }

            // Authentication başarıyla kaydedildi.
            print("Authentication başarıyla kaydedildi.")

            // Kullanıcıyı Realtime Database'e kaydet
            self.saveUserInRealtimeDatabase()

            // Başarılı kayıt durumunda login ekranına geç
            self.navigateToSignInViewController()
        }
    }


            private func saveUserInRealtimeDatabase() {
                guard let currentUserID = Auth.auth().currentUser?.uid,
                      let firstName = self.firstName,
                      let lastName = self.lastName,
                      let phoneNumber = self.phoneNumber,
                      let email = self.email else {
                    print("Eksik bilgi var, kullanıcıyı kaydedemedi.")
                    return
                }

                let userData = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "phoneNumber": phoneNumber,
                    "email": email
                ]

                Database.database().reference().child("users").child(currentUserID).setValue(userData) { error, _ in
                    if let error = error {
                        print("Realtime Database kaydetme hatası: \(error.localizedDescription)")
                    } else {
                        print("Realtime Database başarıyla kaydedildi.")
                        
                        // Oturumu kapat ve giriş ekranına yönlendir
                        self.signOutAndNavigateToSignIn()
                    }
                }
            }

            private func signOutAndNavigateToSignIn() {
                do {
                    try Auth.auth().signOut()
                    print("Kullanıcı başarıyla çıkış yaptı.")
                    navigateToSignInViewController()
                } catch let signOutError as NSError {
                    print("Çıkış yaparken hata oluştu: \(signOutError.localizedDescription)")
                }
            }
    private func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    private func navigateToSignInViewController() {
        // Kullanıcı kaydı başarılı olduğunda sadece alert göster ve login ekranına geçme
        showSuccessMessage("Kayıt Başarılı")
    }

    private func showSuccessMessage(_ message: String) {
        let alertController = UIAlertController(title: "Başarılı", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default) { [weak self] _ in
            // Kullanıcı alert'i tamamladığında login ekranına geç
            self?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }        }
