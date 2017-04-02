//
//  CredentialsViewController.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit

class CredentialsViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var date : Date?
    var location : Location?
    var ids : [Int]?
    var email : String?
    var password : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.becomeFirstResponder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        track()
    }
    
    func track() {
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker?.set(kGAIScreenName, value: "Login Screen")
//        
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker?.send(builder?.build() as [AnyHashable: Any])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailField.resignFirstResponder()
    }

    @IBAction func saveCredentials(_ sender: AnyObject) {
        submit()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss()
    }
    
    internal func submit() {
        
        email = emailField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        password = passwordField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
       
        if (email == "" || password == "") {
            return
        }
        
        let defaults = UserDefaults.standard
        
        defaults.setValue(email, forKey: "email")
        defaults.setValue(password, forKey: "password")
        
        self.performSegue(withIdentifier: "credsToHeadless", sender: self)
        
    }
    
    internal func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "credsToHeadless") {
            let dest = segue.destination as! ProcessViewController
            dest.ids = ids
            dest.date = date
            dest.location = location
            dest.email = email
            dest.password = password
        }
    }
}
