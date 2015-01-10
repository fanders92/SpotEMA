//
//  KRWTableViewCell.swift
//  Spot
//
//  Created by Konstantin Wachendorff on 03/01/15.
//  Copyright (c) 2015 K.Wachendorff & F.Anders. All rights reserved.
//

import UIKit

class KRWTableViewCell: UITableViewCell {

    @IBOutlet weak var txtStreet: UILabel!
    @IBOutlet weak var txtName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
