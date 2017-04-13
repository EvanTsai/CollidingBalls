//
//  RoundView.swift
//  CollidingBalls
//
//  Created by Evan on 2017/4/13.
//  Copyright © 2017年 Evan. All rights reserved.
//

import UIKit

class RoundView: UIView {
    
    override var frame: CGRect {
        didSet {
            setup()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        assert(bounds.width == bounds.height, "error")
        layer.masksToBounds = true
        layer.cornerRadius = bounds.width / 2
        layer.shouldRasterize = true
    }
    
    //MARK: - collisionBoundsType
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}
