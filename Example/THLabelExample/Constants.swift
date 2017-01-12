//
//  Constants.swift
//  THLabelExample
//
//  Created by Vitalii Parovishnyk on 1/12/17.
//  Copyright © 2017 IGR Software. All rights reserved.
//

import UIKit

class Constants: NSObject {
    static let kShadowColor1                = UIColor.black
    static let kShadowColor2                = UIColor(white:0.0, alpha:0.75)
    static let isPad                        = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)
    static let kShadowOffset                = CGSize(width:0.0, height:isPad ? 4.0 : 2.0)
    static let kShadowBlur: CGFloat         = isPad ? 10.0 : 5.0
    static let kInnerShadowOffset           = CGSize(width:0.0, height:isPad ? 2.0 : 1.0)
    static let kInnerShadowBlur: CGFloat    = isPad ? 4.0 : 2.0
    
    static let kStrokeColor                 = UIColor.black
    static let kStrokeSize: CGFloat         = isPad ? 6.0 : 3.0
    
    static let kGradientStartColor	= UIColor(red:255.0 / 255.0, green:193.0 / 255.0, blue:127.0 / 255.0, alpha:1.0)
    static let kGradientEndColor    = UIColor(red:255.0 / 255.0, green:163.0 / 255.0, blue:64.0 / 255.0, alpha:1.0)
}
