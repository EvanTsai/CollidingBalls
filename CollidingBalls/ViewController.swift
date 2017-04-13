//
//  ViewController.swift
//  CollidingBalls
//
//  Created by Evan on 2017/4/13.
//  Copyright © 2017年 Evan. All rights reserved.
//

import UIKit

struct Data {
    static let numberOfBalls = 5
    static let spacingX: CGFloat = 40
    static let originX = floor((UIScreen.main.bounds.width - spacingX * CGFloat(numberOfBalls - 1)) / 2)
}


class LineView: UIView {
    fileprivate lazy var points = [(CGPoint, CGPoint)]()
    override func draw(_ rect: CGRect) {
        let p = UIBezierPath()
        for pt in points {
            p.move(to: pt.0)
            p.addLine(to: pt.1)
        }
        UIColor.darkGray.setStroke()
        p.stroke()
    }
    
    func addPoints(_ points:[(CGPoint, CGPoint)]) {
        self.points.removeAll()
        self.points.append(contentsOf: points)
        setNeedsDisplay()
    }
}


class ViewController: UIViewController {
    
    fileprivate lazy var lineView: LineView = {
        let v = LineView(frame: self.view.frame)
        v.isUserInteractionEnabled = false
        v.backgroundColor = UIColor.clear
        self.view.addSubview(v)
        return v
    }()
    
    
    fileprivate lazy var animator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        addRoundViewsAndBehaviors()
    }
    
    fileprivate func configView() {
        view.backgroundColor = UIColor.white
    }
    
    
    fileprivate var ballViews = [RoundView]()
    fileprivate var anchorPoints = [CGPoint]()
    fileprivate var ballCenterPoints = [CGPoint]()
    fileprivate var itemBehavior: UIDynamicItemBehavior!
    
    fileprivate func addRoundViewsAndBehaviors() {
        for i in 0..<Data.numberOfBalls {
            let anchorPoint = CGPoint(x: Data.originX + CGFloat(i) * Data.spacingX, y: 100)
            let ballCenter = CGPoint(x: anchorPoint.x, y: anchorPoint.y + 90)
            let ballView = RoundView(frame: CGRect(x: 0, y: 0, width: Data.spacingX, height: Data.spacingX))
            ballView.backgroundColor = UIColor.green
            ballView.center = ballCenter
            view.addSubview(ballView)
            
            ballCenterPoints.append(ballCenter)
            ballViews.append(ballView)
            anchorPoints.append(anchorPoint)
            
            let attachmentBehavior = UIAttachmentBehavior(item: ballView, attachedToAnchor: anchorPoint)
            animator.addBehavior(attachmentBehavior)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(beginPan(_:)))
            ballView.addGestureRecognizer(pan)
        }
        
        let gravityBehavior = UIGravityBehavior(items: ballViews)
        animator.addBehavior(gravityBehavior)
        
        itemBehavior = UIDynamicItemBehavior(items: ballViews)
        itemBehavior.action = {
            [unowned self] in
            self.ballCenterPoints = self.ballViews.map{ $0.center }
            self.redrawLineView()
        }
        itemBehavior.elasticity = 0.8
        itemBehavior.allowsRotation = false
        itemBehavior.resistance = 0.4
        animator.addBehavior(itemBehavior)
        
        
        let collisionBehavior = UICollisionBehavior(items: ballViews)
        collisionBehavior.collisionMode = .items
        animator.addBehavior(collisionBehavior)
        
        view.sendSubview(toBack: lineView)
        redrawLineView()
        
//        self.animator.perform(Selector(("setDebugEnabled:")), with:true)
    }
    
    
    //MARK: Redraw lines
    fileprivate func redrawLineView() {
        let zippedPoints = zip(anchorPoints, ballCenterPoints)
        let pointsToDraw = zippedPoints.map{$0}
        lineView.addPoints(pointsToDraw)
    }
    
    fileprivate var userPushBehavior: UIPushBehavior?
    
    func beginPan(_ pan: UIPanGestureRecognizer) {
        guard let targetView = pan.view else { return }
        switch pan.state {
        case .began:
            print("Began")
        case .changed:
            let tranlationPoint = pan.translation(in: view)
            if let _userPushBehavior = userPushBehavior {
                _userPushBehavior.pushDirection = CGVector(dx: tranlationPoint.x / 20, dy: 0)
            }
            else {
                //the force has to be continuous in order to keep it steady
                let pushBehavior = UIPushBehavior(items: [targetView], mode: .continuous)
                pushBehavior.pushDirection = CGVector(dx: tranlationPoint.x / 20, dy: 0)
                self.animator.addBehavior(pushBehavior)
                userPushBehavior = pushBehavior
            }
        case .ended, .cancelled:
            self.animator.removeBehavior(userPushBehavior!)
            userPushBehavior = nil
            print("Ended Or Cancelled")
        default:
            print("Default")
        }
        
    }
}


