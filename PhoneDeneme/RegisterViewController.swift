//
//  ViewController.swift
//  PhoneDeneme
//
//  Created by Beste Kocaoglu on 29.12.2023.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var merryDesign: UIImageView!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var surnameText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var textLabel: UINavigationItem!
    
    var authViewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUpClicked(_ sender: Any) {
        guard let phoneNumber = phoneNumberText.text, !phoneNumber.isEmpty else {
                    // Telefon numarası eksik, kullanıcıyı uyar
                    return
                }

                authViewModel.startPhoneNumberVerification(phoneNumber) { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success:
                        // Doğrulama başlatıldı, telefon numarasını doğrulama ekranını göster
                        self.showVerificationScreen(phoneNumber: phoneNumber)
                    case .failure(let error):
                        // Başlatma sırasında bir hata oluştu, kullanıcıyı uyar
                        print("Doğrulama başlatma hatası: \(error.localizedDescription)")
                    }
                }
            }

    private func showVerificationScreen(phoneNumber: String) {
            let verificationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VerificationViewController") as! VerificationViewController
            verificationVC.authViewModel = authViewModel
            verificationVC.phoneNumber = phoneNumber
            verificationVC.firstName = nameText.text
            verificationVC.lastName = surnameText.text
            verificationVC.email = emailText.text
            verificationVC.password = passwordText.text
            present(verificationVC, animated: true, completion: nil)
        }
    }
        
