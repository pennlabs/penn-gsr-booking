//
//  BookViewController.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit

protocol ShowsAlert {}

extension ShowsAlert where Self: UIViewController {
    func showAlert(withMsg: String, title: String = "Error", completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: withMsg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            if let completion = completion {
                completion()
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
}

protocol CollectionViewProtocol: UICollectionViewDelegate, UICollectionViewDataSource {}

class BookViewController: GAITrackedViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, ShowsAlert, CollectionViewProtocol {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Outlets and Properties
    
    @IBOutlet var pickerView: UIPickerView!
    
    lazy var dates : [Date] = DateHandler.getDates()
    
    lazy var locations : [Location] = LocationsHandler.getLocations()
    
    var roomData = Dictionary<String, [Hour]>()
    
    var currentDate : Date?
    
    var currentLocation : Location?
    
    var currentSelection : Set<Hour>?
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    var storedOffsets = [Int: CGFloat]()
    
    // MARK: - View Initialization Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.activityIndicator != nil {
            self.activityIndicator.startAnimating()
        }
        
        self.screenName = "Main Screen"
    }

    func track() {
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker?.set(kGAIScreenName, value: "Main Screen")
//        
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker?.send(builder?.build() as [AnyHashable: Any])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        track()
        
        refreshContent()
        
    }
    
    override func awakeFromNib() {
        // init properties
        
        currentDate = dates[0]
        currentLocation = locations[0]
        currentSelection = Set()
        
        refreshContent()
    }
    
    // MARK: - Picker view methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return dates.count
        case 1:
            return locations.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            currentDate = dates[row]
            break
        case 1:
            currentLocation = locations[row]
            break
        default:
            break
        }
        
        refreshContent()
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            if (row == 0) {
                return "Today"
            } else if (row == 1) {
                return "Tomorrow"
            }
            return dates[row].compact
        case 1:
            return locations[row].name
        default:
            return ""
        }
    }
    
    // MARK: - Table view methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return roomData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(roomData.keys)[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell",
                                                               for: indexPath)
        
        return cell
    }
    
    // MARK: - CollectionView Related Methods
    
    func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                                            forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? RoomCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forSection: indexPath.section)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                            didEndDisplaying cell: UITableViewCell,
                                                 forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? RoomCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    // MARK: - Data Methods

    func refreshContent() {
        
        if self.activityIndicator != nil {
            self.activityIndicator.startAnimating()
        }
        
        NetworkManager.getHours((currentDate?.compact)!, gid: (currentLocation?.code)!) {
            (res: AnyObject) in
            
            if (res is NSError) {
                self.showAlert(withMsg: "Can't communicate with the server", title: "Oops", completion: nil)
            } else {
                DispatchQueue.main.async(execute: {
                    if self.activityIndicator != nil {
                        self.activityIndicator.stopAnimating()
                    }
                    self.roomData = Parser.getAvailableTimeSlots(res as! String)
                    self.currentSelection?.removeAll()
                    self.enableButton(false)
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // Mark: - Submitting Hours Selection
    
    @IBAction func submitSelection(_ sender: AnyObject) {
        if (validateSubmission() == false) {
            showAlert(withMsg: "You can only choose consecutive times", title: "Can't do that.", completion: nil)
        } else {
            let (email, password) = getEmailAndPassword()
            
            if email != nil && password != nil {
                self.performSegue(withIdentifier: "mainToHeadless", sender: self)
            } else {
                self.performSegue(withIdentifier: "credentialsSegue", sender: self)
            }
            
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if (segue.identifier == "credentialsSegue") {
            let destinationNavigationController = segue.destination as! UINavigationController
            
            let destination = destinationNavigationController.topViewController as! CredentialsViewController
            
            destination.date = currentDate
            destination.ids = [Int]()
            
            for selection in currentSelection! {
                destination.ids!.append(selection.id)
            }
            
            destination.location = currentLocation
            
        } else if (segue.identifier == "mainToHeadless") {
            let destinationNavigationController = segue.destination as! UINavigationController
            let dest = destinationNavigationController.topViewController as! ProcessViewController
            
            let ids = getSelectionIds()
            let (email, password) = getEmailAndPassword()
            
            dest.ids = ids
            dest.date = currentDate
            dest.location = currentLocation
            dest.email = email
            dest.password = password
            
        } 
    }
    

}

