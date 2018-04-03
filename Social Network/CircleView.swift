//
//  CircleView.swift
//  devslopes-social
//
//  Created by Jess Rascal on 24/07/2016.
//  Copyright © 2016 JustOneJess. All rights reserved.
//

import UIKit

class CircleView: UIImageView {

    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
}
