//
//  SRProximityRecord.swift
//  SRProximityRecord
//
//  Created by Stephen Radford on 05/08/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

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

    /// Reference to the video input
    private var videoInput: AVCaptureDeviceInput?

    /// Reference to the audio input
    private var audioInput: AVCaptureDeviceInput?

    public override init() {
        super.init()
        setupProximitySensor()
        setupCaptureSession()
    }

    // MARK: - Permissions

    /// Request permissions for camera, microphone and photo library if we need to
    public func requestPermissions() {
        checkCameraPermission()
        checkMicrophonePermission()
        if autoSave {
            checkPhotoLibraryPermission()
        }
    }

    /// Check we have access to the camera and if not, request it
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        print(status)
        switch status {
            case .NotDetermined, .Restricted:
                PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                    self.delegate?.photoPermissionChanged?(status: status)
                })
            default:
                self.delegate?.photoPermissionChanged?(status: status)
        }
    }

    /// Check we have access to the camera and if not, request it
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch status {
            case .Restricted:
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                    if granted {
                        self.delegate?.cameraPermissionChanged?(status: .Authorized)
                    }
                })
            default:
                self.delegate?.cameraPermissionChanged?(status: status)
        }
    }

    /// Check we have access to the microphone and if not, request it
    private func checkMicrophonePermission() {
        let status = AVAudioSession.sharedInstance().recordPermission()

        switch status {
            case AVAudioSessionRecordPermission.Denied:
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) -> Void in
                    if granted {
                        self.delegate?.audioPermissionChanged?(status: .Granted)
                    }
                })
            default:
                self.delegate?.audioPermissionChanged?(status: status)
        }
    }

    // MARK: - Proximity Sensor

    /// ### Setup the proximity sensor
    /// Enables the current device to start sensing and configures an observer to monitor changes
    private func setupProximitySensor() {
        device.proximityMonitoringEnabled = true
        notificationCenter.addObserver(self, selector: "proximityChanged:", name: UIDeviceProximityStateDidChangeNotification, object: device)
    }

    /// Proximity state has changed
    public func proximityChanged(sender: UIDevice) {

        let state = device.proximityState
        delegate?.proximityChanged?(sensorEnabled: state)

        if startRecordingAutomatically && state {
            startRecording()
        } else if startRecordingAutomatically && !state {
            stopRecording()
        }

    }


    // MARK: - Recording

    /// Start recording. This will automatically happen if `startRecordingAutomatically` is set to true
    public func startRecording() {
        if videoInput != nil && audioInput != nil {
            captureSession.startRunning()
            captureOutput.startRecordingToOutputFileURL(NSURL(fileURLWithPath: outputPath), recordingDelegate: self)

        } else {
            print("ERROR: Could not start recording")
        }
    }

    /// Stop recording. This will automatically happen if `startRecordingAutomatically` is set to true
    public func stopRecording() {
        if videoInput != nil && audioInput != nil {
            captureSession.stopRunning()
            captureOutput.stopRecording()
        } else {
            print("ERROR: Could not stop recording")
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

        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice!)
        } catch {
            videoInput = nil
            print("ERROR: Creating deviceInput")
        }

        if videoInput != nil {
            captureSession.addInput(videoInput)
        }

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
