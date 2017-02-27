//
//  ViewController.swift
//  FlipControlTest
//
//  Created by SangChan Lee on 2/13/17.
//  Copyright © 2017 SangChan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var flipControl: FlipControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.flipControl.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.flipControl.fliped()
        self.flipControl.endTime = Date(timeInterval: TimeInterval(3610), since: Date())
        self.flipControl.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonClicked(_ sender: Any) {
        self.flipControl.stop()
        let random = arc4random() % 640
        self.flipControl.startWith(endTime: Date(timeInterval: TimeInterval(random), since: Date()))
    }

}

extension ViewController: FlipControlDelegate {
    func flipControl(flipControl: FlipControl, isDoneAt: Date) {
        print("Boom!")
    }
}

