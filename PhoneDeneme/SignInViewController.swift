//
//  SignInViewController.swift
//  PhoneDeneme
//
//  Created by Beste Kocaoglu on 30.12.2023.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    @IBOutlet weak var loginEmailText: UITextField!
    
    @IBOutlet weak var loginPasswordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signInClicked(_ sender: Any) {
        guard let email = loginEmailText.text,
                      let password = loginPasswordText.text else {
                    // Eksik bilgi var, kullanıcıyı uyar
                    return
                }

                Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                    guard let self = self else { return }

                    if let error = error {
                        // Giriş sırasında bir hata oluştu, kullanıcıyı uyar
                        print("Giriş hatası: \(error.localizedDescription)")
                    } else {
                        // Giriş başarılı, istediğiniz işlemleri gerçekleştirin
                        print("Giriş başarılı!")
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                    }
                }
            }

    
    @IBAction func forgotPassword(_ sender: Any) {
    }
    @IBAction func accountClicked(_ sender: Any) {
    }
    
}
