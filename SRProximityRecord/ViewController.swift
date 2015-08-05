//
//  ViewController.swift
//  SRProximityRecord
//
//  Created by Stephen Radford on 05/08/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SRProximityRecordDelegate {

    @IBOutlet weak var successLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let PR = SRProximityRecord.sharedInstance
        PR.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: SRProximityRecordDelegate

    func recordingStarted() {
        print("Recording Started!")
    }
    
    func recordingStopped() {
        print("Recording Stopped!")
        successLabel.hidden = false
    }

}

