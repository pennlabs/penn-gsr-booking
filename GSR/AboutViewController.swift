//
//  AboutViewController.swift
//  GSR
//
//  Created by Yagil Burowski on 04/10/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit

class AboutViewController: GAITrackedViewController, ShowsAlert {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set screen name.
        self.screenName = "About Screen"
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        track()
    }
    
    func track() {
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker?.set(kGAIScreenName, value: "About Screen")
//        
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker?.send(builder?.build() as [AnyHashable: Any])
    }
    
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss()
    }
    
    
    
    @IBAction func resetCredentials() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "password")
        self.showAlert(withMsg: "You've successfuly reset your credentials. They are no longer stored on this device.", title: "Reset Credentials", completion: {
            self.dismiss(animated: true, completion: nil)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
