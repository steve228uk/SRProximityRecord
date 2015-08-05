//
//  SRProximityRecordDelegate.swift
//  SRProximityRecord
//
//  Created by Stephen Radford on 05/08/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import Foundation

@objc protocol SRProximityRecordDelegate {
    
    /// Called when the proximity state of the device has changed
    optional func proximityChanged(sensorEnabled: Bool)
    
    /// Called when the recording has started
    optional func recordingStarted()
    
    /// Called when the recording has stopped
    optional func recordingStopped()
    
}