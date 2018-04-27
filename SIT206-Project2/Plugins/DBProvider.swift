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

class DBProvider {
    
    private static let _instance = DBProvider();
    
    private init() {}
    
    static var Instance: DBProvider {
        return _instance;
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference();
    }
    
    var contactsRef : DatabaseReference {
        return dbRef.child(Constants.CONTACTS);
    }
    
    var messagesRef: DatabaseReference {
        return dbRef.child(Constants.MESSAGES);
    }
    
    var mediaMessagesRef: DatabaseReference {
        return dbRef.child(Constants.MEDIA_MESSAGES);
    }
    
    var storageRef: StorageReference {
        return Storage.storage().reference(forURL: "gs://sit206-project2.appspot.com/")
    }
    
    var imageStorageRef: StorageReference {
        return storageRef.child(Constants.IMAGE_STORAGE);
    }
    
    var videoStorageRef: StorageReference {
        return storageRef.child(Constants.VIDEO_STORAGE);
    }
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password];
        
        contactsRef.child(withID).setValue(data);
    }
    
    
    
    
} // class
