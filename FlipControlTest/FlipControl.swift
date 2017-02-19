//
//  FlipControl.swift
//  FlipControlTest
//
//  Created by SangChan Lee on 2/13/17.
//  Copyright © 2017 SangChan. All rights reserved.
//

import UIKit

class FlipControl: UIView {
    fileprivate var hFlip : FlipView!
    fileprivate var mFlip : FlipView!
    fileprivate var sFlip : FlipView!
    
    let zDepth = 1000
    
    var timer = 1
    var startTime : Date!
    var endTime : Date!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initializer()
        
    }
    
    fileprivate func initializer() {
        self.startTime = Date()
        self.endTime = Date()
        self.backgroundColor = UIColor.black
        
        let frontView = FlipView(text: "\(timer)", frame: CGRect(x: 0, y: 0, width: self.frame.size.width * 0.9, height: self.frame.size.height*0.9))
        frontView.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addSubview(frontView)
        
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 0.5
        
        //let tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tabed(_:)))
        
        //self.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func fliped() {
        self.timer += 1
        let newbackView = FlipView(text: "\(timer)", frame: CGRect(x: 0, y: 0, width: self.frame.size.width * 0.9, height: self.frame.size.height*0.9))
        newbackView.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        
        let frontView = self.subviews.first as! FlipView
        
        self.bringSubview(toFront: frontView)
        
        var skewedIdentityTransform : CATransform3D = CATransform3DIdentity
        skewedIdentityTransform.m34 = 1.0 / -1000;
        
        frontView.prepareToswingTopFlip()
        let copiedTopFlipFromBackView = UIImageView(image: newbackView.topFlip.image)
        copiedTopFlipFromBackView.frame = newbackView.topFlip.frame
        frontView.insertSubview(copiedTopFlipFromBackView, belowSubview: frontView.topFlip)
        
        newbackView.prepareToswingBottomFlip()
        let copiedBottomFlipFromFrontView = UIImageView(image: frontView.bottomFlip.image)
        copiedBottomFlipFromFrontView.frame = frontView.bottomFlip.frame
        newbackView.insertSubview(copiedBottomFlipFromFrontView, belowSubview: newbackView.bottomFlip)
        
        newbackView.bottomFlip.layer.transform = CATransform3DRotate(skewedIdentityTransform, CGFloat(M_PI_2), 1, 0, 0)
        
        UIView.animate(withDuration: 0.5, animations: {
            frontView.topFlip.layer.transform = CATransform3DRotate(skewedIdentityTransform, -CGFloat(M_PI_2), 1, 0, 0)
        }) { (end) in
            self.addSubview(newbackView)
            UIView.animate(withDuration: 0.5, animations: {
                newbackView.bottomFlip.layer.transform = CATransform3DRotate(skewedIdentityTransform,0, 1, 0, 0)
            }) { (end) in
                frontView.removeFromSuperview()
                if end {
                    self.fliped()
                }
            }
            
        }
    }

}

class FlipView : UIView {
    var topFlip : UIImageView!
    var bottomFlip : UIImageView!
    var text : String!
    
    convenience init(text: String, frame:CGRect) {
        self.init(frame:frame)
        self.text = text
        initializer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        initializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.backgroundColor = UIColor.clear
        initializer()
        
    }
    
    func prepareToswingTopFlip() {
        topFlip.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        topFlip.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    }
    
    func prepareToswingBottomFlip() {
        bottomFlip.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        bottomFlip.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    }

    fileprivate func initializer() {
        // Drawing code
        let upperView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height/2))
        upperView.backgroundColor = UIColor.white
        self.addSubview(upperView)
        
        let lowerView = UIView(frame: CGRect(x: 0, y: frame.size.height/2, width: frame.size.width, height: frame.size.height/2))
        lowerView.backgroundColor = UIColor.lightGray
        self.addSubview(lowerView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        label.font = UIFont.systemFont(ofSize: 120)
        label.textAlignment = .center
        label.text = text
        label.textColor = UIColor.darkGray
        label.backgroundColor = UIColor.clear
        self.addSubview(label)
        snapshot()
        
        if topFlip != nil  && bottomFlip != nil {
            upperView.removeFromSuperview()
            lowerView.removeFromSuperview()
            label.removeFromSuperview()
            
            self.addSubview(topFlip)
            self.addSubview(bottomFlip)
        }
    }
    
    fileprivate func snapshot() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.layer.isOpaque, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let renderImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        
        let size = CGSize(width: renderImage.size.width, height: renderImage.size.height/2.0)
        
        UIGraphicsBeginImageContextWithOptions(size, self.layer.isOpaque, 0.0)
        renderImage.draw(at: CGPoint(x: 0, y: 0))
        guard let topImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
        self.topFlip = UIImageView(image: topImage)
        topFlip.frame = CGRect(x: 0, y: 0, width:frame.size.width, height: frame.size.height/2)
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(size, self.layer.isOpaque, 0.0)
        renderImage.draw(at: CGPoint(x: 0, y: -renderImage.size.height / 2.0))
        let bottomImage = UIGraphicsGetImageFromCurrentImageContext()
        self.bottomFlip = UIImageView(image: bottomImage)
        bottomFlip.frame = CGRect(x: 0, y: frame.size.height/2, width: frame.size.width, height: frame.size.height/2)
        UIGraphicsEndImageContext()
    }
}
