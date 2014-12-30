//
//  KRWHomeButton.swift
//  Spot
//
//  Created by Kw on 30/12/14.
//  Copyright (c) 2014 K.Wachendorff. All rights reserved.
//

import UIKit

class KRWHomeButton: UIButton {

    override func drawRect(rect: CGRect) {
        if self.state == UIControlState.Normal {
            KRWSpotButtonStyleKit.drawKRWHomeButtonNormal()
        }else{
            KRWSpotButtonStyleKit.drawKRWHomeButtonClicked()
        }
    }


}
