//
//  ViewController.swift
//  Flash Chat
//
// This is the chat view controller for users to chat.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    
    // Declare instance variables here
    var messageArray: [Message] = [Message]()
    
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(onTableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessage()
        
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        //let array = ["1", "sdhvdoviivodhvisdhvkscvisjicvjscvjskcvjsdcvscv", "3"]
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView?.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            cell.avatarImageView.backgroundColor = UIColor.flatPowderBlueColorDark()
            cell.messageBackground.backgroundColor = UIColor.flatPowderBlue()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatMintColorDark()
            cell.messageBackground.backgroundColor = UIColor.flatMint()
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    @objc func onTableViewTapped() {
        textFieldDidEndEditing(messageTextfield)
    }
    
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 100.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 358
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
        textField.endEditing(true)
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text]
        
        messagesDB.childByAutoId().setValue(messageDictionary) { error, ref in
            if error != nil {
                print(error)
            } else {
                print("Send successful!")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
        
        
        
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessage() {
        let messagesDB = Database.database().reference().child("Messages")
        messagesDB.observe(.childAdded) { snapshot in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let sender = snapshotValue["Sender"]!
            let messageBody = snapshotValue["MessageBody"]!
            
            let message = Message(sender: sender, messageBody: messageBody)
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
            //print(sender, messageBody)
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch  {
            print(error)
        }
        
        
    }
    

    
    
    

}
