//
//  KRWDrunkButton.swift
//  Spot
//
//  Created by Kw on 30/12/14.
//  Copyright (c) 2014 K.Wachendorff. All rights reserved.
//

import UIKit

class KRWDrunkButton: UIButton {
    override func drawRect(rect: CGRect) {
        if self.state == UIControlState.Normal {
            KRWSpotButtonStyleKit.drawKRWDrunkButtonNormal()
        }else{
            KRWSpotButtonStyleKit.drawKRWDrunkButtonClicked()
        }
    }
}

class KRWContactButton: UIButton {
    override func drawRect(rect: CGRect) {
        if self.state == UIControlState.Normal {
            KRWSpotButtonStyleKit.drawKRWContactButtonNormal()
        }else{
            KRWSpotButtonStyleKit.drawKRWContactButtonClicked()
        }
    }
}

class KRWHomeButton: UIButton {
    override func drawRect(rect: CGRect) {
        if self.state == UIControlState.Normal {
            KRWSpotButtonStyleKit.drawKRWHomeButtonNormal()
        }else{
            KRWSpotButtonStyleKit.drawKRWHomeButtonClicked()
        }
    }
}

class KRWHomeButtonSmall: UIButton {
    override func drawRect(rect: CGRect) {
        if self.state == UIControlState.Normal {
            KRWSpotButtonStyleKit.drawKRWHomeButtonSmallNormal()
        }else{
            KRWSpotButtonStyleKit.drawKRWHomeButtonSmallClicked()
        }
    }
}

class KRWCallButton: UIButton {
    override func drawRect(rect: CGRect) {
        if self.state == UIControlState.Normal {
            KRWSpotButtonStyleKit.drawKRWCallButton2Normal()
        }else{
            KRWSpotButtonStyleKit.drawKRWCallButton2Clicked()
        }
    }
}

class KRWCameraButton: UIButton {
    override func drawRect(rect: CGRect) {
        if self.state == UIControlState.Normal {
            KRWCameraButtonStyleKit.drawCameraButton()
        }else{
            KRWCameraButtonStyleKit.drawCameraButtonClicked()
        }
    }
    
}
