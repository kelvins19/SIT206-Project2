//
//  DBProvider.swift
//  SIT206-Project2
//
//  Created by Kelvin Salim on 27/4/18.
//  Copyright © 2018 Kelvin Salim. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol FetchData: class {
    func dataReceived(contacts: [Contact]);
} // Fetching Data from Database Protocol

class DBProvider {
    
    private static let _instance = DBProvider();
    
    weak var delegate: FetchData?;
    
    private init() {}
    
    static var Instance: DBProvider {
        return _instance;
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference();
    } // Database Reference
    
    var contactsRef : DatabaseReference {
        return dbRef.child(Constants.CONTACTS);
    } // Contacts Reference
    
    var messagesRef: DatabaseReference {
        return dbRef.child(Constants.MESSAGES);
    } // Messages Reference
    
    var mediaMessagesRef: DatabaseReference {
        return dbRef.child(Constants.MEDIA_MESSAGES);
    } // Media Messages Reference
    
    var storageRef: StorageReference {
        return Storage.storage().reference(forURL: "gs://sit206-project2.appspot.com/")
    } // Storage Reference
    
    var imageStorageRef: StorageReference {
        return storageRef.child(Constants.IMAGE_STORAGE);
    } // Image Storage Reference
    
    var videoStorageRef: StorageReference {
        return storageRef.child(Constants.VIDEO_STORAGE);
    } // Video Storage Reference
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password];
        
        contactsRef.child(withID).setValue(data);
    } // Save User Function
    
    func getContacts() {
        
        contactsRef.observeSingleEvent(of: DataEventType.value) {
            (snapshot: DataSnapshot) in
            var contacts = [Contact]();
            
            if let myContacts = snapshot.value as? NSDictionary {
                
                for(key, value) in myContacts {
                    
                    if let contactData = value as? NSDictionary {
                        
                        if let email = contactData[Constants.EMAIL] as? String {
                            
                            let id = key as! String;
                            let newContact = Contact(id: id, name: email);
                            contacts.append(newContact);
                        }
                    }
                }
            }
            self.delegate?.dataReceived(contacts: contacts);
        }
    
    } // Retrieving Contact Functions
    
    
} // class
