//
//  UIViewControllerExtension.swift
//  GSR
//
//  Created by Yagil Burowski on 12/10/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    internal func showAlert(withMsg msg: String, title: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
