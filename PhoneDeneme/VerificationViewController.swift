//
//  VerificationViewController.swift
//  PhoneDeneme
//
//  Created by Beste Kocaoglu on 30.12.2023.
//

import UIKit

class VerificationViewController: UIViewController {
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    var authViewModel: AuthViewModel!
    var phoneNumber: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    
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
                        // Doğrulama başarılı, kullanıcıyı real time'a kaydet
                        let user = User(firstName: self.firstName!, lastName: self.lastName! , phoneNumber: self.phoneNumber!, email: self.email!)

                        self.authViewModel.saveUserToRealTimeDatabase(user: user) { success in
                            if success {
                                // Kullanıcıyı kaydettikten sonra SignInViewController'a geçiş yap
                                self.navigateToSignInViewController()
                            } else {
                                print("Kullanıcıyı kaydetme hatası")
                                // Hata durumunda kullanıcıyı uygun bir şekilde bilgilendirin
                            }
                        }

                    case .failure(let error):
                        // Doğrulama sırasında bir hata oluştu, kullanıcıyı uyar
                        print("Doğrulama hatası: \(error.localizedDescription)")
                    }
                }
            }

            private func navigateToSignInViewController() {
                // Geçiş yapmadan önce gerekirse view controller'a ek işlemler yapabilirsiniz
                // Örneğin, signInViewController'daki bir değişkeni set edebilirsiniz
                // signInViewController.someVariable = someValue

                // Storyboard üzerindeki SignInViewController'ın storyboardId'sini kullanarak view controller'ı oluştur
                if let signInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
                    // SignInViewController'a geçiş yap
                    navigationController?.pushViewController(signInViewController, animated: true)
                }
            }
        }
