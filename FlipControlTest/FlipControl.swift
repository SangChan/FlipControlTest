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
    
    var timer : Timer!
    
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
        
        mPanel = FlipPanel(panelType: .minute, frame: CGRect(x:panelWidth , y: panelOriginY, width: panelWidth, height: panelWidth))
        
        sPanel = FlipPanel(panelType: .second, frame: CGRect(x:panelWidth * 2, y: panelOriginY, width: panelWidth, height: panelWidth))
        
        self.addSubview(hPanel)
        self.addSubview(mPanel)
        self.addSubview(sPanel)
    }
    
    func start() {
        let startTime = Date()
        let secondForTimer : Int = Calendar.current.dateComponents([.second], from: startTime, to: self.endTime).second ?? 0
        
        let hourCounter   = secondForTimer / 3600
        let minuteCounter = secondForTimer / 60
        let secondCounter = secondForTimer - (hourCounter * 3600) - (minuteCounter * 60)
        
        self.hPanel.value = hourCounter
        self.mPanel.value = minuteCounter
        self.sPanel.value = secondCounter
        
        self.hPanel.start()
        self.mPanel.start()
        self.sPanel.start()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(secondForTimer), target: self, selector: #selector(stop), userInfo: nil, repeats: false)
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
    var value : Int!
    var superFlipPanel : FlipPanel?
    var timer : Timer?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    convenience init(panelType : FlipPanelType,frame: CGRect) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.panelType = panelType
        self.value = 0
        self.initializer()
    }
    
    func initializer() {
        let label = UILabel(frame: CGRect(x:0, y: 0, width: self.frame.size.width, height: self.frame.size.height * 0.2))
        label.textAlignment = .center
        label.text = string(fromPanelType: self.panelType)
        label.font = UIFont.systemFont(ofSize: label.frame.size.height * 0.6)
        self.addSubview(label)
        doFlip()
    }
    
    func start() {
        guard self.value > 0 else { return }
        doFlip()
        timer = Timer.scheduledTimer(timeInterval: self.timeInterval(fromPanelType: self.panelType), target: self, selector: #selector(doFlip), userInfo: nil, repeats: true)
    }
    
    func stop() {
        guard timer != nil else { return }
        timer?.invalidate()
    }
    
    func doFlip() {
        for prevFlipView in self.subviews {
            if prevFlipView is FlipView {
                prevFlipView.removeFromSuperview()
            }
        }
        let flipOrigin = self.bounds.size.height * 0.2
        let flipSize   = self.bounds.size.height * 0.8
        
        
        let flipView = FlipView(text: String(format: "%02d", value), frame:CGRect(x: flipOrigin/2, y: flipOrigin, width: flipSize, height: flipSize))
        self.addSubview(flipView)
        value = decreaseValue()
    }
    
    func decreaseValue() -> Int{
        var tempValue : Int = value
        tempValue -= 1
        if tempValue < 0 {
            tempValue = 59
        }
        return tempValue
    }
    
    func timeInterval(fromPanelType:FlipPanelType) -> TimeInterval {
        switch fromPanelType {
        case FlipPanelType.second:
            return 1.0
        case FlipPanelType.minute:
            return 60.0
        default:
            return 3600.0
        }
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
    }
    
    convenience init(text: String, frame: CGRect) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.clear
        initializer(text: text)
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
        
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
    }
}
