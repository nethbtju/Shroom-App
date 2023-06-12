//
//  BadgeCollectionViewCell.swift
//  Shroom
//
//  Created by Neth Botheju on 7/6/2023.
//

import UIKit

/// Custom CollectionViewCell that allows the badges to be displayed
class BadgeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var badgeImage: UIImageView!
    
    @IBOutlet weak var badgeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
