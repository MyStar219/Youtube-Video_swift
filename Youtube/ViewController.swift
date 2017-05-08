//
//  ViewController.swift
//  Youtube
//
//  Created by administrator on 4/10/17.
//  Copyright © 2017 developer. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var youtubewebview: UIWebView!
    var cameraView : UIView! = nil
    let screenSize = UIScreen.main.bounds

    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
//    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    
    var background_task: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var m_bStartTimer: Bool = true
    var displayYoutubeURL: String = "https://www.youtube.com/embed/-lHg3QeCWTk"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let currentWindow : UIWindow = UIApplication.shared.keyWindow!
        cameraView=UIView(frame: CGRect(x: (107.5*mainView.frame.width/375), y: (450*mainView.frame.height/667), width: (160*mainView.frame.width/375), height: (160*mainView.frame.width/375)))
        currentWindow.addSubview(cameraView)
        // Add rounded corners to UIView
        cameraView.backgroundColor=UIColor.blue
        cameraView.layer.cornerRadius=cameraView.frame.width/2
        cameraView.clipsToBounds=true
        cameraView.layer.borderWidth = 2
        cameraView.layer.borderColor = UIColor.red.cgColor
        // Add UIView as a Subview
        //Display rounded imageView
        let camera = getDevice(position: .front)
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetPhoto
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: camera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
//            videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            cameraView.layer.addSublayer(videoPreviewLayer!)
            session!.startRunning()
            // ...
            // The remainder of the session setup will go here...
        }
        self.displayYoutube()
        self.startBackgroundTask()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup your camera here...
        videoPreviewLayer!.frame = cameraView.layer.bounds
    }
    // Get front and back camera device
    func getDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices()! as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    func startBackgroundTask() {
        let application : UIApplication = UIApplication.shared
        background_task = application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(self.background_task)
        })
        
        DispatchQueue.global(qos: .background).async {
            
//            self.m_bStartTimer = true;
            while (true) {
                print("Running in the background!")
                self.backgroundThread()
                Thread.sleep(forTimeInterval: 1.0)
            }
        }
    }
    
    func backgroundThread() {
        let pasteboardString: String? = UIPasteboard.general.string
        let youtubeURL = "https://www.youtube.com/watch?v="
        if pasteboardString != nil {
            if (pasteboardString?.hasPrefix(youtubeURL))! { // true
                let newString = pasteboardString?.replacingOccurrences(of: "https://www.youtube.com/watch?v=", with: "https://www.youtube.com/embed/")
                if self.displayYoutubeURL != newString! {
                    self.displayYoutubeURL = newString!
                    self.displayYoutube()
                }
                print("Prefix exists")
            }
        }
    }
    func tapImageView(_ sender: UITapGestureRecognizer) {
        self.screenShotMethod()
        print("Please Help!")
    }
    //get screen shot
    func screenShotMethod() {
        //Create the UIImage
        UIGraphicsBeginImageContext(youtubewebview.frame.size)
        youtubewebview.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        print("Success")
    }
    // display youtube video
    func displayYoutube() {
        youtubewebview.loadHTMLString("<iframe width=\"\(youtubewebview.frame.width)\" height=\"\(youtubewebview.frame.height)\" src=\"\(displayYoutubeURL)\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
        //Gesture Event
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapImageView(_:)))
        youtubewebview.addGestureRecognizer(tapGesture)
    }
}

