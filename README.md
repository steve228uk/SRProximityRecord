# SRProximityRecord

`SRProximityRecord` is a small class and delegate to record video (or audio) by covering the proximity sensor. It's based on the idea used by [Beme](http://beme.com).

[Read more on my Blog](http://stephenradford.me/replicating-bemes-record-with-the-proximity-sensor/)

[View example project](https://github.com/steve228uk/SRProximityRecord-Example)

> Used `SRProximityRecord` in a project? Let me know [@steve228uk](http://twitter.com/steve228uk)

## Requirements

Swift 2.0 — Currently this requires the latest Xcode Beta. It could probably be converted down to 1.2 very easily.

## Installation

Installation can be done via CocoaPods or manually.

### CocoaPods

Make sure your project is set to use frameworks by adding `use_frameworks!` to your Podfile. Then, include the following to install SRProximityRecord to your target.

`pod 'SRProximityRecord'`

### Manually

Clone the repo into your project and manually assign the Target Membership to your target

![Target Membership](http://sht.tl/V6Hn4f)

## Usage

Using SRProximityRecord is easy and you only need to call the shared instance once to get it all working.

````swift
let SRP = SRProximityRecord.sharedInstance
SRP.requestPermissions()
SRP.delegate = self
````
Requesting permissions will request access to camera, microphone and photo library.

Setting the delegate will allow you to use the methods outlined below.

> If you're using CocoaPods, make sure your import the module into your classes using `import SRProximityRecord`

## methods

There are a few public methods that you can use.

Method | Description
-------|------------
`requestPermissions()` | Request permissions for camera, microphone and photo library if we need to
`startRecording()` | Start recording audio/video
`stopRecording()` | Stop recording audio/video

## Properties

There are a number of properties that can be overriden to change the default behaviour of `SRProximityRecord`.

Property                      | Type   | Description
------------------------------|--------|----------------
`startRecordingAutomatically` | `Bool` | By default recording will be started automatically when the proximity sensor is covered. If you'd like to do this manually to say show an interim screen, change this to false.
`captureDevice` | `AVCaptureDevice` | Reference to the back camera or nil if the device used doesn't have a camera.
`audioDevice` | `AVCaptureDevice` | Reference to the microphone or nil if the device used doesn't have a microphone.
`captureOutput` | `AVCaptureOutput` | The output type. This can be video, image or audio. By default it's `AVCaptureMovieFileOutput`
`outputPath` | `String` | Path to where the output file will be recorded.
`autoSave` | `Bool` | If you want to automatically save the temporary file to the camera roll. Default is true.
`delegate` | `SRProximityRecordDelegate` | Optional delegate
`sharedInstance` | `SRProximityRecord` | Static reference to an instance of the class

## `SRProximityRecordDelegate`

The delegate bundled with SRProximityRecord has 3 (optional) methods that are called when various events occur.

Method                  | Description
------------------------|---------------------------
`proximityChanged(sensorEnabled:)` | Called when the proximity state of the device has changed. The `proximityState` is passed to the delegate method as a `Bool`
`recordingStarted()` | Called when the recording has started
`recordingStopped()` | Called when the recording has stopped
`photoPermissionChanged(status:)` | Called when the photo permission has changed
