//
//  UnitCollectionViewCell.swift
//  Shroom
//
//  Created by Neth Botheju on 21/5/2023.
//

import UIKit

/// Customer collection for the units collection 
class UnitCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var progressBar: UIView!
    
    @IBOutlet weak var unitCode: UILabel!
    
    @IBOutlet weak var unitName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Apply rounded corners
        contentView.layer.cornerRadius = 10.0
        contentView.layer.masksToBounds = true
                
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = 10.0
        layer.masksToBounds = false
    }
    
}
