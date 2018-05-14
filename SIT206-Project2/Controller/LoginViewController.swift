//
//  LoginViewController.swift
//  SIT206-Project2
//
//  Created by Kelvin Salim on 15/4/18.
//  Copyright © 2018 Kelvin Salim. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    private let CONTACT_SEGUE = "ContactSegue"
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButton(_ sender: Any) {
        if usernameTextField.text != "" && passwordTextField.text != "" {
           
            AuthProvider.Instance.login(withEmail: usernameTextField.text!, password: passwordTextField.text!, loginHandler: {(message) in
                
                if message != nil {
                    self.alertUser(title: "Problem With Authentication", message: message!);
                } else {
                    
                    self.usernameTextField.text = "";
                    self.passwordTextField.text = "";
                    
                    self.performSegue(withIdentifier: self.CONTACT_SEGUE, sender: nil);
                }
            }) // Authenticating The User Based On Data From Database
            
        } else {
            alertUser(title: "Email and Password are Required", message: "Please Enter your Email and Password in The Text Fields"); // Alert User If The Email or Password Empty
            
        }
        
    } // Function When Login Button Pressed
    
    @IBAction func signUpButton(_ sender: Any) {
        if usernameTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.signUp(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (message) in
                if message != nil {
                    self.alertUser(title: "Problem Creating A New User", message: message!);
                } else {
                    
                    self.usernameTextField.text = "";
                    self.passwordTextField.text = "";
                    
                    self.performSegue(withIdentifier: self.CONTACT_SEGUE, sender: nil);
                }
            }
            
        } else {
            alertUser(title: "Email and Password are Required", message: "Please Enter your Email and Password in The Text Fields");
            
        }
    } // Sign Up Functions
    
    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    } // Alert User Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        if AuthProvider.Instance.isLoggedIn() {
            performSegue(withIdentifier: self.CONTACT_SEGUE, sender: nil);
        } // Move to ContactViewController
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
