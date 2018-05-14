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
} //Error Message

class AuthProvider {
    private static let _instance = AuthProvider();
    
    static var Instance: AuthProvider {
        return _instance;
    }
    
    var userName = "";
    
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
                if user?.uid != nil {
                    
                    //store the user to database
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password);
                    //login the user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler);
                    
                }
            }
        });
    } //signUp Function
    
    func isLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil {
            return true;
        }
        return false;
    }// When user has already logged in function
    
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut();
                return true;
            } catch {
                return false;
            }
        }
        return true;
    } //log out function
    
    func userID() -> String {
        return Auth.auth().currentUser!.uid;
    }
    
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
    } // Error Handler Function
} // Class
