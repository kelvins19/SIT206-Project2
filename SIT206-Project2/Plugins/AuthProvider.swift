//
//  AuthProvider.swift
//  SIT206-Project2
//
//  Created by Kelvin Salim on 15/4/18.
//  Copyright © 2018 Kelvin Salim. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void;

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid Email Address, Please Provide Real Email Address";
    static let WRONG_PASSWORD = "Wrong Password, Please Check Your Password Again";
    static let PROBLEM_CONNECTING = "Problem Connecting to Database";
    static let USER_NOT_FOUND = "User not Found, Please Register by Clicking Sign Up";
    static let EMAIL_ALREADY_IN_USE = "Email Already In Use by Another Use, Please Use Another Email";
    static let WEAK_PASSWORD = "Password Should Be At Least 6 Characters Long";
}

class AuthProvider {
    private static let _instance = AuthProvider();
    
    static var Instance: AuthProvider {
        return _instance;
    }
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user,error) in
            
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler);
            }
            else {
                loginHandler?(nil);
            }
        });
    } //Login Function
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().createUser(withEmail: withEmail, password: password, completion: { (user,error) in
            
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler);
            }
            else {
                loginHandler?(nil);
            }
        });
    } //signUp Function
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        
        if let errCode = AuthErrorCode(rawValue: err.code){
            
            switch errCode {
                
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD);
                break;
                
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL);
                break;
                
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND);
                break;
                
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE);
                break;
                
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD);
                break;
                
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING);
                break;
            }
        }
    }
    
    
    
}
