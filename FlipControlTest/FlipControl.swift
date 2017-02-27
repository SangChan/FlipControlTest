//
//  FlipControl.swift
//  FlipControlTest
//
//  Created by SangChan Lee on 2/23/17.
//  Copyright © 2017 SangChan. All rights reserved.
//

import UIKit

protocol FlipControlDelegate : class {
    func flipControl(flipControl: FlipControl, isDoneAt: Date)
}

class FlipControl: UIView {
    weak var delegate : FlipControlDelegate?
    var endTime : Date!
    var totalCounter : Int = 0
    
    fileprivate var timer : Timer!
    fileprivate var hPanel : FlipPanel!
    fileprivate var mPanel : FlipPanel!
    fileprivate var sPanel : FlipPanel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initializer()
        
    }
    
    fileprivate func initializer() {
        self.backgroundColor = UIColor.clear
        
        let panelWidth = self.frame.size.width / 3
        let panelOriginY =  (self.frame.size.height/2) - (panelWidth/2)
        
        hPanel = FlipPanel(panelType: .hour, frame: CGRect(x: 0, y: panelOriginY, width: panelWidth, height: panelWidth))
        mPanel = FlipPanel(panelType: .minute, frame: CGRect(x:panelWidth , y: panelOriginY, width: panelWidth, height: panelWidth), superFlipPanel : hPanel)
        sPanel = FlipPanel(panelType: .second, frame: CGRect(x:panelWidth * 2, y: panelOriginY, width: panelWidth, height: panelWidth), superFlipPanel : mPanel)
        
        self.addSubview(hPanel)
        self.addSubview(mPanel)
        self.addSubview(sPanel)
    }
    
    func start() {
        let startTime = Date()
        totalCounter = Calendar.current.dateComponents([.second], from: startTime, to: self.endTime).second ?? 0
        
        let hourCounter   = totalCounter / 3600
        let minuteCounter = (totalCounter - (hourCounter * 3600)) / 60
        let secondCounter = totalCounter - (hourCounter * 3600) - (minuteCounter * 60)
        
        self.hPanel.value = hourCounter
        self.mPanel.value = minuteCounter
        self.sPanel.value = secondCounter
        
        self.hPanel.start()
        self.mPanel.start()
        self.sPanel.start()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(doFlip), userInfo: nil, repeats: true)
    }
    
    func doFlip() {
        totalCounter -= 1
        
        let hourCounter   = totalCounter / 3600
        let minuteCounter = (totalCounter - (hourCounter * 3600)) / 60
        let secondCounter = totalCounter - (hourCounter * 3600) - (minuteCounter * 60)
        
        if self.hPanel.value != hourCounter {
            self.hPanel.value = hourCounter
            self.hPanel.doFlip()
        }
        if self.mPanel.value != minuteCounter {
            self.mPanel.value = minuteCounter
            self.mPanel.doFlip()
        }
        if self.sPanel.value != secondCounter {
            self.sPanel.value = secondCounter
            self.sPanel.doFlip()
        }
        
        if totalCounter <= 0 {
            stop()
        }
    }
    
    func stop() {
        self.timer.invalidate()
        self.hPanel.stop()
        self.mPanel.stop()
        self.sPanel.stop()
        self.delegate?.flipControl(flipControl: self, isDoneAt: Date())
    }
}

enum FlipPanelType {
    case hour
    case minute
    case second
}

private class FlipPanel: UIView {
    fileprivate var panelType : FlipPanelType!
    fileprivate var superFlipPanel : FlipPanel?
    var value : Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    convenience init(panelType : FlipPanelType, frame: CGRect, superFlipPanel: FlipPanel? = nil) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.panelType = panelType
        self.value = 0
        self.superFlipPanel = superFlipPanel
        self.initializer()
    }
    
    func initializer() {
        let label = UILabel(frame: CGRect(x:0, y: 0, width: self.frame.size.width, height: self.frame.size.height * 0.2))
        label.textAlignment = .center
        label.text = string(fromPanelType: self.panelType)
        label.font = UIFont.systemFont(ofSize: label.frame.size.height * 0.6)
        self.addSubview(label)
        
        let flipOrigin = self.bounds.size.height * 0.2
        let flipSize   = self.bounds.size.height * 0.8
        
        let newBackFlipView = FlipView(text: String(format: "%02d", value), frame:CGRect(x: flipOrigin/2, y: flipOrigin, width: flipSize, height: flipSize))
        self.addSubview(newBackFlipView)
    }
    
    func start() {
        if let frontFlipView = self.getFlipView() {
            frontFlipView.removeFromSuperview()
        }
        doFlip()
    }
    
    func stop() {
    }
    
    
    func doFlip() {
        let flipOrigin = self.bounds.size.height * 0.2
        let flipSize   = self.bounds.size.height * 0.8
        
        let newBackFlipView = FlipView(text: String(format: "%02d", value), frame:CGRect(x: flipOrigin/2, y: flipOrigin, width: flipSize, height: flipSize))
        
        if let frontFlipView = self.getFlipView() {
            self.bringSubview(toFront: frontFlipView)
            
            var skewedIdentityTransform : CATransform3D = CATransform3DIdentity
            skewedIdentityTransform.m34 = 1.0 / -1000;
            
            frontFlipView.prepareToswingTopFlip()
            let copiedTopFlipFromBackView = UIImageView(image: newBackFlipView.topFlip.image)
            copiedTopFlipFromBackView.frame = newBackFlipView.topFlip.frame
            frontFlipView.insertSubview(copiedTopFlipFromBackView, belowSubview: frontFlipView.topFlip)
            
            newBackFlipView.prepareToswingBottomFlip()
            let copiedBottomFlipFromFrontView = UIImageView(image: frontFlipView.bottomFlip.image)
            copiedBottomFlipFromFrontView.frame = frontFlipView.bottomFlip.frame
            newBackFlipView.insertSubview(copiedBottomFlipFromFrontView, belowSubview: frontFlipView.bottomFlip)
            
            newBackFlipView.bottomFlip.layer.transform = CATransform3DRotate(skewedIdentityTransform, CGFloat(M_PI_2), 1, 0, 0)
            
            UIView.animate(withDuration: 0.15, animations: {
                frontFlipView.topFlip.layer.transform = CATransform3DRotate(skewedIdentityTransform, -CGFloat(M_PI_2), 1, 0, 0)
            }) { (end) in
                self.addSubview(newBackFlipView)
                UIView.animate(withDuration: 0.15, animations: {
                    newBackFlipView.bottomFlip.layer.transform = CATransform3DRotate(skewedIdentityTransform,0, 1, 0, 0)
                }) { (end) in
                    frontFlipView.removeFromSuperview()
                    if (end) {
                        copiedBottomFlipFromFrontView.removeFromSuperview()
                    }
                }
                
            }
            
        }else {
            self.addSubview(newBackFlipView)
        }
        
    }
    
    func getFlipView() -> FlipView? {
        for prevFlipView in self.subviews {
            if prevFlipView is FlipView {
                return prevFlipView as? FlipView
            }
        }
        return nil
    }
    
    func string(fromPanelType:FlipPanelType) -> String {
        switch fromPanelType {
        case FlipPanelType.second:
            return "SEC"
        case FlipPanelType.minute:
            return "MIN"
        default:
            return "HOUR"
        }
    }
    
}

private class FlipView: UIView {
    
    var topFlip : UIImageView!
    var bottomFlip : UIImageView!
    var text : String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
    }
    
    convenience init(text: String, frame: CGRect) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.text = text
        initializer(text: text)
    }
    
    func prepareToswingTopFlip() {
        topFlip.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        topFlip.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    }
    
    func prepareToswingBottomFlip() {
        bottomFlip.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        bottomFlip.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    }
    
    fileprivate func initializer(text: String) {
        // Drawing code
        let upperView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height/2))
        let gradient = CAGradientLayer()
        gradient.frame = upperView.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0).cgColor]
        upperView.layer.insertSublayer(gradient, at: 0)

        self.addSubview(upperView)
        
        let lowerView = UIView(frame: CGRect(x: 0, y: frame.size.height/2, width: frame.size.width, height: frame.size.height/2))
        lowerView.backgroundColor = UIColor.white
        self.addSubview(lowerView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        label.font = UIFont.systemFont(ofSize: frame.size.height * 0.5)
        label.textAlignment = .center
        label.text = text
        label.textColor = UIColor.black
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
        
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
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
