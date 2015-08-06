//
//  SRProximityRecordDelegate.swift
//  SRProximityRecord
//
//  Created by Stephen Radford on 05/08/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import Foundation
import Photos
import AVFoundation

@objc public protocol SRProximityRecordDelegate {

    /// Called when the proximity state of the device has changed
    optional func proximityChanged(sensorEnabled sensorEnabled: Bool)

    /// Called when the recording has started
    optional func recordingStarted()

    /// Called when the recording has stopped
    optional func recordingStopped()

    /// Called when the photo permission has changed
    optional func photoPermissionChanged(status status: PHAuthorizationStatus)

    /// Called when the camera permission has changed
    optional func cameraPermissionChanged(status status: AVAuthorizationStatus)

    /// Called when the audio permission had changed
    optional func audioPermissionChanged(status status: AVAudioSessionRecordPermission)

}
