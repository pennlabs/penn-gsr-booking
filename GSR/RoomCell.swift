//
//  RoomCell.swift
//  GSR
//
//  Created by Yagil Burowski on 17/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import UIKit

class RoomCell: UITableViewCell {

    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCollectionViewDataSourceDelegate
        (dataSourceDelegate: CollectionViewProtocol, forSection section: Int) {

        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = section
        collectionView.allowsMultipleSelection = true
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var collectionViewOffset: CGFloat {
        get {
            return collectionView.contentOffset.x
        }
        
        set {
            collectionView.contentOffset.x = newValue
        }
    }
}
