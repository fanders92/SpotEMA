//
//  KRWDrunkButton.swift
//  Spot
//
//  Created by Konstantin Wachendorff on 30/12/14.
//  Copyright (c) 2015 K.Wachendorff & F.Anders. All rights reserved.
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

class KRWHomeButtonRound: UIButton {
    override func drawRect(rect: CGRect) {
        if self.state == UIControlState.Normal {
            KRWSpotButtonStyleKit.drawKRWHomeButtonRoundNormal()
        }else{
            KRWSpotButtonStyleKit.drawKRWHomeButtonRoundClicked()
        }
    }
}

class KRWCallButton: UIButton {
    override func drawRect(rect: CGRect) {
        if self.state == UIControlState.Normal {
            KRWSpotButtonStyleKit.drawKRWCallButton2NormalBig()
        }else{
            KRWSpotButtonStyleKit.drawKRWCallButton2ClickedBig()
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
