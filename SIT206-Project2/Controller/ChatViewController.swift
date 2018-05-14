//
//  ChatViewController.swift
//  SIT206-Project2
//
//  Created by Kelvin Salim on 29/4/18.
//  Copyright © 2018 Kelvin Salim. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit // To Play Video
import SDWebImage // For Downloading Media Message From Database

class ChatViewController: JSQMessagesViewController, MessageReceivedDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var messages = [JSQMessage]();
    
    let picker = UIImagePickerController();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self;
        MessagesHandler.Instance.delegate = self;
        
        // Do any additional setup after loading the view.
        self.senderId = AuthProvider.Instance.userID();
        self.senderDisplayName = AuthProvider.Instance.userName; // To know which user send the messages
        
        MessagesHandler.Instance.observeMessages();
        MessagesHandler.Instance.observeMediaMessages();
    }
    
    // Collection View Functions
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory();
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.blue); // Outgoing Message Bubble
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.green);
        } // Incoming Message Bubble

    } // Chat Bubble
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileimage"), diameter: 30)
    } // Profile Image
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let msg = messages[indexPath.item];
        
        if msg.isMediaMessage {
            if let mediaItem = msg.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL);
                let playerController = AVPlayerViewController();
                playerController.player = player;
                self.present(playerController, animated: true, completion: nil);
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell;
        return cell;
    }
    // End of Collection View Functions
    
    // Sending Buttons Functions
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        MessagesHandler.Instance.sendMessage(senderID: senderId, senderName: senderDisplayName, text: text);
        
        //this will remove the text from text field
        finishSendingMessage();
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Media Messages", message: "Please Select A Media", preferredStyle: .actionSheet);
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        
        let photos = UIAlertAction(title: "Photos", style: .default, handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeImage);
            
        })
        
        let videos = UIAlertAction(title: "Videos", style: .default, handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeMovie);
            
        })
        
        alert.addAction(photos);
        alert.addAction(videos);
        alert.addAction(cancel);
        present(alert, animated: true, completion: nil);
        
    }
    // End Sending Button Actions
    
    // Picker View Functions
    
    private func chooseMedia(type: CFString) {
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let data = UIImageJPEGRepresentation(pic, 0.01);
            
            MessagesHandler.Instance.sendMedia(image: data, video: nil, senderID: senderId, senderName: senderDisplayName);
            
            
        } else if let vidURL = info[UIImagePickerControllerMediaURL] as? URL {
            
            MessagesHandler.Instance.sendMedia(image: nil, video: vidURL, senderID: senderId, senderName: senderDisplayName);
            
        }
        
        self.dismiss(animated: true, completion: nil);
        collectionView.reloadData();
        
    }
    
    // End Picker View Functions
    
    // Delegation Functions
    
    func messageReceived(senderID: String, senderName: String, text: String) {
        messages.append(JSQMessage(senderId: senderID, displayName: senderName, text: text));
        collectionView.reloadData();
    }
    
    func mediaReceiver(senderID: String, senderName: String, url: String) {
        
        if let mediaURL = URL(string: url) {
            
            do {
                let data = try Data(contentsOf: mediaURL);
                if let _ = UIImage(data: data) {
                    let _ = SDWebImageDownloader.shared().downloadImage(with: mediaURL, options: [], progress: nil) { (image, data, error, finished) in
                        
                        DispatchQueue.main.async {
                            let photo = JSQPhotoMediaItem(image: image);
                            if senderID == self.senderId {
                                photo?.appliesMediaViewMaskAsOutgoing = true;
                            } else {
                                photo?.appliesMediaViewMaskAsOutgoing = false;
                            }
                            self.messages.append(JSQMessage(senderId: senderID, displayName: senderName, media: photo));
                            self.collectionView.reloadData();
                        }
                    }
                } else {
                    
                    let video = JSQVideoMediaItem(fileURL: mediaURL, isReadyToPlay: true);
                    if senderID == self.senderId {
                        video?.appliesMediaViewMaskAsOutgoing = true;
                    } else {
                        video?.appliesMediaViewMaskAsOutgoing = false;
                    }
                    messages.append(JSQMessage(senderId: senderID, displayName: senderName, media: video));
                    self.collectionView.reloadData();
                }
            } catch {
                // here we are going to catch all potential errors that we get
            }
        }
    }
    // End Delegation Functions
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    } // Back Button
    
    
    
    
    
    /* // Sharing Location Function -- Coming Soon
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latestLocation = locations[locations.count-1]
        
    }
    
    let sendLocation = UIAlertAction(title: "Send Location", style: .default, handler: { (action) -> Void in
        
        
        
        let loc: JSQLocationMediaItem = JSQLocationMediaItem(location: self.latestLocation)
        
        loc.appliesMediaViewMaskAsOutgoing = true
        
        let locmessage: JSQMessage = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: NSDate() as Date!, media: loc)
        
        self.messages.append(locmessage)
        
        self.finishSendingMessage(animated: true)
        self.collectionView.reloadData()
        
        print("Location button tapped")
    })
    
    let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        print("Cancel button tapped")
    })
    
    alertController.addAction(sendLocation)
    
    self.navigationController!.present(alertController, animated: true, completion: nil)
    */
    
}// class
