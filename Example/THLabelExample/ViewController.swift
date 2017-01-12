//
//  ViewController.swift
//  THLabelExample
//
//  Created by Vitalii Parovishnyk on 1/11/17.
//  Copyright © 2017 IGR Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak fileprivate var label1: THLabel?
    @IBOutlet weak fileprivate var label2: THLabel?
    @IBOutlet weak fileprivate var label3: THLabel?
    @IBOutlet weak fileprivate var label4: THLabel?
    @IBOutlet weak fileprivate var label5: THLabel?
    @IBOutlet weak fileprivate var label6: THLabel?

    override func viewDidLoad() {
        // Demonstrate shadow blur.
        self.label1?.shadowColor = Constants.kShadowColor1;
        self.label1?.shadowOffset = Constants.kShadowOffset;
        self.label1?.shadowBlur = Constants.kShadowBlur;
        
        // Demonstrate inner shadow.
        self.label2?.innerShadowColor = Constants.kShadowColor1;
        self.label2?.innerShadowOffset = Constants.kInnerShadowOffset;
        self.label2?.innerShadowBlur = Constants.kInnerShadowBlur;
        
        // Demonstrate stroke.
        self.label3?.strokeColor = Constants.kStrokeColor;
        self.label3?.strokeSize = Constants.kStrokeSize;
        
        // Demonstrate fill gradient.
        self.label4?.gradientStartColor = Constants.kGradientStartColor;
        self.label4?.gradientEndColor = Constants.kGradientEndColor;
        
        // Demonstrate fade truncating.
        self.label5?.fadeTruncatingMode = THLabelFadeTruncatingMode.tail;
        
        // Demonstrate everything.
        self.label6?.shadowColor = Constants.kShadowColor2;
        self.label6?.shadowOffset = Constants.kShadowOffset;
        self.label6?.shadowBlur = Constants.kShadowBlur;
        self.label6?.innerShadowColor = Constants.kShadowColor2;
        self.label6?.innerShadowOffset = Constants.kInnerShadowOffset;
        self.label6?.innerShadowBlur = Constants.kInnerShadowBlur;
        self.label6?.strokeColor = Constants.kStrokeColor;
        self.label6?.strokeSize = Constants.kStrokeSize;
        self.label6?.gradientStartColor = Constants.kGradientStartColor;
        self.label6?.gradientEndColor = Constants.kGradientEndColor;
    }
}

