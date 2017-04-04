//
//  ProcessViewController.swift
//  GSR
//
//  Created by Yagil Burowski on 04/10/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit

class ProcessViewController: GAITrackedViewController {

    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var webView: UIWebView!
    
    var date : Date?
    var location : Location?
    var ids : [Int]?
    var email : String?
    var password : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        registerForNotifications()
        
        DispatchQueue.main.async(execute: {
            let activityInd = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            activityInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityInd)
            
            activityInd.startAnimating()
        })
        
        self.screenName = "Process Screen"
        
        let networkingManager = NetworkManager(email: email!, password: password!, gid: (location?.code)!, ids: ids!)
        
        networkingManager.bookSelection()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        track()
    }
    
    func track() {
// TODO: - tracking code not working in swift 3, need to check what google says
        
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker?.set(kGAIScreenName, value: "Process Screen")
//        
//        if let builder = GAIDictionaryBuilder.createScreenView()
//        tracker?.send(builder?.build() as [AnyHashable: Any])
    }
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ProcessViewController.handleNotification(_:)), name:NSNotification.Name(rawValue: "ProgressMessageNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProcessViewController.handleStatusMessage(_:)), name:NSNotification.Name(rawValue: "StatusMessageNotification"), object: nil)
    }
    
    func handleStatusMessage(_ notification: Notification) {
        let html = notification.object as! String
        self.webView.loadHTMLString(html, baseURL: nil)
        DispatchQueue.main.async(execute: {
            let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(ProcessViewController.dismissSelf))
            self.navigationItem.rightBarButtonItem = button
        })
        
    }
    
    func handleNotification(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            let msg = notification.object as! String
            self.statusLabel.text = msg
        })
        
    }
    
    func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    internal func updateLabel(_ msg: String) {
        statusLabel.text = msg
    }
}
