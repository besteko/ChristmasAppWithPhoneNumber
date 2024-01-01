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
        guard let firstName = nameText.text,
                             let lastName = surnameText.text,
                             let phoneNumber = phoneNumberText.text,
                             let email = emailText.text,
                             let password = passwordText.text,
                             let confirmPassword = confirmPasswordText.text else {
                           // Eksik bilgi var, kullanıcıyı uyar
                           return
                       }

                       let user = User(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email)

                       authViewModel.registerUser(user: user, password: password, confirmPassword: confirmPassword) { result in
                           switch result {
                           case .success:
                               // Kayıt başarılı, telefon numarasını doğrulama ekranını göster
                               self.showVerificationScreen(phoneNumber: phoneNumber)
                           case .failure(let error):
                               // Kayıt sırasında bir hata oluştu, kullanıcıyı uyar
                               print("Kayıt hatası: \(error.localizedDescription)")
                           }
                       }
                   }

                   private func showVerificationScreen(phoneNumber: String) {
                       let verificationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VerificationViewController") as! VerificationViewController
                       verificationVC.authViewModel = authViewModel
                       verificationVC.phoneNumber = phoneNumber
                       present(verificationVC, animated: true, completion: nil)
                   }
               }
