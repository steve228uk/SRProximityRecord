//
//  SRProximityRecord.swift
//  SRProximityRecord
//
//  Created by Stephen Radford on 05/08/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import AVFoundation

public class SRProximityRecord: NSObject, AVCaptureFileOutputRecordingDelegate {

    /// The default notification center
    private let notificationCenter = NSNotificationCenter.defaultCenter()

    /// Shared instance of the proximity recorder
    public static let sharedInstance = SRProximityRecord()

    /// The current device
    private let device = UIDevice.currentDevice()

    /// The delegate where we can fire off our notifications
    public var delegate: SRProximityRecordDelegate?

    /// Whether recording should be started automatically. Set this to false if you want to handle it yourself using the `proximityChanged` method on the `SRProximityRecordDelegate`
    public var startRecordingAutomatically: Bool = true

    /// The capture session that we'll use to record video
    public let captureSession = AVCaptureSession()

    /// We'll store the back camera here if the device we're using has one
    public var captureDevice: AVCaptureDevice?

    /// We'll store the microphone here
    public var audioDevice: AVCaptureDevice?

    /// The capture session preset we're going to use to record audio and video. By default this is set to High Quality but change it if you need to record in a different format
    public var captureSessionPreset = AVCaptureSessionPresetHigh

    /// Output of the file we'll be capturing
    public var captureOutput = AVCaptureMovieFileOutput()

    /// Path to the output file
    public var outputPath = "\(NSTemporaryDirectory())/proximity.mov"

    /// Auto save the video?
    public var autoSave = true

    public override init() {
        super.init()
        setupProximitySensor()
        setupCaptureSession()
    }

    // MARK: - Proximity Sensor

    /// ### Setup the proximity sensor
    /// Enables the current device to start sensing and configures an observer to monitor changes
    private func setupProximitySensor() {
        device.proximityMonitoringEnabled = true
        notificationCenter.addObserver(self, selector: "proximityChanged:", name: UIDeviceProximityStateDidChangeNotification, object: device)
    }

    /// Proximity state has changed
    private func proximityChanged(sender: UIDevice) {

        let state = device.proximityState
        delegate?.proximityChanged?(state)

        if startRecordingAutomatically && state {
            startRecording()
        } else if startRecordingAutomatically && !state {
            stopRecording()
        }

    }


    // MARK: - Recording

    /// Start recording. This will automatically happen if `startRecordingAutomatically` is set to true
    public func startRecording() {
        if captureDevice != nil {

            captureSession.startRunning()
            captureOutput.startRecordingToOutputFileURL(NSURL(fileURLWithPath: outputPath), recordingDelegate: self)

        } else {
            print("ERROR: Device does not have back camera")
        }
    }

    /// Stop recording. This will automatically happen if `startRecordingAutomatically` is set to true
    public func stopRecording() {
        if captureDevice != nil {
            captureSession.stopRunning()
            captureOutput.stopRecording()
        } else {
            print("ERROR: Device does not have back camera")
        }
    }


    // MARK: - Capture Session

    /// Setup our capture session
    private func setupCaptureSession() {
        captureSession.sessionPreset = captureSessionPreset

        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == .Back {
                    captureDevice = device as? AVCaptureDevice
                }
            }
            if device.hasMediaType(AVMediaTypeAudio) {
                audioDevice = device as? AVCaptureDevice
            }
        }

        configureCaptureSession()
    }

    /// Configure the capture session to add our input and output
    private func configureCaptureSession() {
        captureSession.beginConfiguration()
        captureSession.addOutput(captureOutput)

        let deviceInput: AVCaptureDeviceInput?

        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
        } catch {
            deviceInput = nil
            print("ERROR: Creating deviceInput")
        }

        if deviceInput != nil {
            captureSession.addInput(deviceInput)
        }

        let audioInput: AVCaptureDeviceInput?

        do {
            audioInput = try AVCaptureDeviceInput(device: audioDevice!)
        } catch {
            audioInput = nil
            print("ERROR: Creating audioInput")
        }

        if audioInput != nil {
            captureSession.addInput(audioInput)
        }

        captureSession.commitConfiguration()
    }

    // MARK: - AVCaptureFileRecordingDelegate

    public func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        delegate?.recordingStopped?()
        if autoSave {
            UISaveVideoAtPathToSavedPhotosAlbum(outputPath, self, nil, nil)
        }
    }

    public func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        delegate?.recordingStarted?()
    }

}
