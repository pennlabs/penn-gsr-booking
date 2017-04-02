//
//  NetworkManager.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation


class NetworkManager: NSObject {
    static let availUrl = "http://libcal.library.upenn.edu/process_roombookings.php"
    
    var email : String?
    var password: String?
    var gid : Int?
    var ids : [Int]?
    var session : URLSession?
    
    override init() {
        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init(email: String, password: String, gid: Int, ids: [Int]) {
            self.init()
            self.email = email
            self.password = password
            self.gid = gid
            self.ids = ids
    }
    
    static func getHours(_ date: String, gid: Int, callback: @escaping (AnyObject) -> ()) {
        let headers = [
            "Referer": "http://libcal.library.upenn.edu/booking/vpdlc"
        ]
        
        let url = availUrl + "?m=calscroll&date=\(date)&gid=\(gid)"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
//        let task = URLSession.shared.dataTask(with: request) { (data, respones, error) in
//            
//        }
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                callback(error! as AnyObject)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                callback(response!)
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            
            callback(responseString! as AnyObject)
        }
        
        task.resume()
    }
    

    
    
    // MARK: - crazy experiemnt 
    
    
    func bookSelection() {
        let request = NSMutableURLRequest(url: URL(string: "http://libcal.library.upenn.edu/booking/vpdlc")!)
        self.sendNotification("msg", msg: "Starting up...")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            self.initiateProcess()
        }
        
        task.resume()
    }
    
    func initiateProcess() {
        let request = NSMutableURLRequest(url: URL(string: "http://libcal.library.upenn.edu/libauth_s_r.php")!)
        
        request.httpMethod = "POST"
        
        let bodyData = "tc=done&p1=\(Parser.idsArrayToString(ids!))&p2=\(gid!)&p3=8&p4=0&iid=335"
        
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }

            self.sendNotification("msg", msg: "Some back and forth...")
            
            if let nextUrl = response?.url! {
                self.get1(nextUrl)
            }
        }
        
        task.resume()
    }
    
    func get1(_ url : URL) {
        let request = NSMutableURLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            self.sendNotification("msg", msg: "Some back and forth...")
        
            self.get2(url)
        }
        
        task.resume()
    }
    
    
    func get2(_ url : URL) {
        let appendStr = "&idpentityid=https%3A%2F%2Fidp.pennkey.upenn.edu%2Fidp%2Fshibboleth"
        let getUrl = URL(string: url.absoluteString + appendStr)
        let request = NSMutableURLRequest(url: getUrl!)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            self.sendNotification("msg", msg: "Negotiating with artificial intelligence...")
            if let nextUrl = response?.url! {
                self.get3(nextUrl, referer: (getUrl?.absoluteString)!)
            }
        }
        
        task.resume()

    }

    
    func get3(_ url : URL, referer : String) {
        let request = NSMutableURLRequest(url: url)
        
        
        request.setValue(referer, forHTTPHeaderField: "Referer")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            self.sendNotification("msg", msg: "Making more progress...")
            self.authenticate()
        }
        
        task.resume()
        
    }

    
   func authenticate() {
        let pennKey = email!.components(separatedBy: "@")[0]
        let request = NSMutableURLRequest(url: URL(string: "https://weblogin.pennkey.upenn.edu/login")!)
        request.httpMethod = "POST"
        let bodyData = "login=\(pennKey)&password=\(password!)&required=UPENN.EDU&ref=https://idp.pennkey.upenn.edu/idp/Authn/RemoteUser&service=cosign-pennkey-idp-0"
        
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        request.setValue("https://weblogin.pennkey.upenn.edu/login?factors=UPENN.EDU&cosign-pennkey-idp-0&https://idp.pennkey.upenn.edu/idp/Authn/RemoteUser", forHTTPHeaderField: "Referer")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            self.sendNotification("msg", msg: "Providing the secret password...")
            self.postAuthenticate(dataString! as String)
        }
        
        task.resume()
    }
    
    
    func postAuthenticate(_ dataString : String) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://libauth.com/saml/module.php/saml/sp/saml2-acs.php/springy-sp")!)
        request.httpMethod = "POST"
        
        let SAMLResponse = Parser.dataStringToSAMLResponse(dataString)
        let bodyData = "RelayState=https%3A%2F%2Flibauth.com%2Fsaml%2Fmodule.php%2Fcore%2Fauthenticate.php%3Fas%3Dspringy-sp&SAMLResponse=\(SAMLResponse)"
        
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        request.setValue("https://idp.pennkey.upenn.edu/idp/profile/SAML2/Redirect/SSO", forHTTPHeaderField: "Referer")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            if let url = response?.url! {
                self.postBooking(url.absoluteString)
                self.sendNotification("msg", msg: "Finalizing everything...")
            }
        }
        
        task.resume()

    }
    
    func postBooking(_ referrer : String) {
        let request = NSMutableURLRequest(url: URL(string: "http://libcal.library.upenn.edu/process_roombookings.php?m=booking_full")!)
        request.httpMethod = "POST"
        
        let bodyData = "gid=\(gid!)&iid=335&email=\(email!)&nick=strategy&q1=2-3&qcount=1&fid=919"
        request.setValue(referrer, forHTTPHeaderField: "Referer")
        
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error == nil {
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if dataString == "ProcPage::invalid request" {
                    self.sendNotification("msg", msg: "Request Failed")
                    let errorMessage = "<body style='font-family:Helvetica'><h3>Possible reasons:</h3>" +
                        "<ul>" +
                        "<li>Penn's servers are mad at you. Exit the app and try again. If that doesn't work, head to the 'About' section of this app, logout and try again.</li>" +
                    "</ul></body>"
                    self.sendNotification("status", msg: errorMessage)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any] {
                        
                        let msg = json["msg"] as! String
                        switch json["status"] as! Int {
                        case 0:
                            self.sendNotification("msg", msg: "Encountered Error:")
                            self.sendNotification("status", msg: msg)
                            break
                        case 2:
                            self.sendNotification("msg", msg: "Result:")
                            self.sendNotification("status", msg: "<body style='font-family:Helvetica'>\(msg)</body>")
                        default:
                            break
                        }
                    }
                } catch {
                    self.sendNotification("msg", msg: "Request Failed")
                    let errorMessage = "<body style='font-family:Helvetica'><h3>Possible reasons:</h3>" +
                        "<ul>" +
                        "<li>Penn's servers are mad at you. Exit the app, wait a few minutes and try again.</li>" +
                        "<li>If that's not it, you may have entered the wrong email or password. In this case, logout and try again.</li>" +
                        "<li>You might have exceeded your daily booking limit.</li>" +
                        "<li>For anything else contact <a href='mailto:upenngsr@gmail.com'>upenngsr@gmail.com</a></li>" +
                        "</ul></body>"
                    self.sendNotification("status", msg: errorMessage)
                }
            } else {
                self.handleError()
            }
        }
        
        task.resume()
    }

    func sendNotification(_ type: String, msg : String) {
        switch type {
        case "msg":
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ProgressMessageNotification"), object: msg)
            break
        case "status":
            NotificationCenter.default.post(name: Notification.Name(rawValue: "StatusMessageNotification"), object: msg)
        default:
            break
        }
        
    }
    fileprivate func handleError() {
        self.sendNotification("msg", msg: "Request Failed")
        self.sendNotification("status", msg: "<p style='font-family:Helvetica'>Email  upenngsr@gmail.com to get help</p>")
    }
}

    
