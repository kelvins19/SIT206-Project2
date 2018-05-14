//
//  MessagesHandler.swift
//  SIT206-Project2
//
//  Created by Kelvin Salim on 4/5/18.
//  Copyright © 2018 Kelvin Salim. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol MessageReceivedDelegate: class {
    func messageReceived(senderID: String, senderName: String, text: String);
    func mediaReceiver(senderID: String, senderName: String, url: String);
} // Message Received Delegate Protocol -- Message & Media Messages

class MessagesHandler {
    
    private static let _instance = MessagesHandler();
    private init() {}
    
    weak var delegate: MessageReceivedDelegate?;
    
    static var Instance: MessagesHandler {
        return _instance;
    }
    
    func sendMessage(senderID: String, senderName: String, text: String) {
        
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.TEXT: text];
        
        DBProvider.Instance.messagesRef.childByAutoId().setValue(data);
        
    } // Send Message Functions
    
    func sendMediaMessage(senderID: String, senderName: String, url: String) {
        
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.URL: url];
        
        DBProvider.Instance.mediaMessagesRef.childByAutoId().setValue(data);
        
    } // Send Media Message Function
    
    func sendMedia(image: Data?, video: URL?, senderID: String, senderName: String) {
        
        if image != nil {
            
            DBProvider.Instance.imageStorageRef.child(senderID + "\(NSUUID().uuidString).jpg").putData(image!, metadata: nil) { (metadata: StorageMetadata?, err: Error?)
                in
                
                if err != nil {
                    //inform the user there was a problem uploading his image
                    
                } else {
                    
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!))
                    
                }
            }
            
        } else {
          
            DBProvider.Instance.videoStorageRef.child(senderID + "\(NSUUID().uuidString)").putFile(from: video!, metadata: nil) { (metadata: StorageMetadata?, err: Error?)
                in
                
                if err != nil {
                    //inform the user that uploading the video has failed, using delegation
                } else {
                    
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!))
                    
                }
            }
        }
    } // Uploading Image & Video to Database
    
    func observeMessages() {
        DBProvider.Instance.messagesRef.observe(DataEventType.childAdded) {
            (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let senderID = data[Constants.SENDER_ID] as? String {
                    if let senderName = data[Constants.SENDER_NAME] as? String {
                        if let text = data[Constants.TEXT] as? String {
                            self.delegate?.messageReceived(senderID: senderID, senderName: senderName, text: text)
                        }
                    }
                }
            }
            
        }
    } // Retrieving Message From Database
    
    func observeMediaMessages() {
        
        DBProvider.Instance.mediaMessagesRef.observe(DataEventType.childAdded) {(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let id = data[Constants.SENDER_ID] as? String {
                    if let name = data[Constants.SENDER_NAME] as? String {
                        if let fileURL = data [Constants.URL] as? String {
                            self.delegate?.mediaReceiver(senderID: id, senderName: name, url: fileURL)
                        }
                    }
                }
            }
        }
    } // Retrieving Media Messages From Database
    
} // class
