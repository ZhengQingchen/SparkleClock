//
//  ViewController.swift
//  SparkleClock
//
//  Created by Aaron Douglas on 12/5/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import Alamofire

let IS_IOS7 = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0
let IS_IOS8 = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0

class ViewController: UIViewController ,CLLocationManagerDelegate{
    var timer: NSTimer!
    var dateFormatter: NSDateFormatter!
    var dateFormatter2: NSDateFormatter!
    let locationManager:CLLocationManager = CLLocationManager()
    var temp:Double!
    
    @IBOutlet var backView: UIView!
    @IBOutlet var clockLabel: UILabel!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var shimmeringView: FBShimmeringView!
  
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var shimmeringViewDate: FBShimmeringView!
    @IBOutlet weak var dateLable: UILabel!
    
    @IBOutlet weak var shimmeringViewTemp: FBShimmeringView!
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBAction func swipeGesture(sender: AnyObject) {
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            let randomColor = self.randomColor()
            self.backView.backgroundColor = randomColor
        })
        
    }
    
    @IBAction func doubleTapGesture(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.backView.backgroundColor = UIColor.blackColor()
        })
    }

  @IBAction func didTapView() {
    shimmeringView.shimmering = !shimmeringView.shimmering
    shimmeringViewDate.shimmering = !shimmeringViewDate.shimmering
    tapGestureRecognizer.enabled = false
    
    UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseIn, animations: {
        self.clockLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)
        self.dateLable.transform = CGAffineTransformMakeScale(1.2, 1.2)
        self.tempLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)
        
      }, completion: { (finished) -> Void in
        UIView.animateWithDuration(0.25, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
            self.clockLabel.transform = CGAffineTransformIdentity
            self.dateLable.transform = CGAffineTransformIdentity
            self.tempLabel.transform = CGAffineTransformIdentity
          }, completion: {
            (finished) -> Void in
            self.tapGestureRecognizer.enabled = true
        })
    })
  }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateUI"), userInfo: nil, repeats: true)
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        shimmeringView.contentView = clockLabel
        shimmeringView.shimmering = true
        
        
        shimmeringViewDate.contentView = dateLable
        shimmeringViewDate.shimmering = true
        
        shimmeringViewTemp.contentView = tempLabel
        shimmeringViewTemp.shimmering = true
        
        
        shimmeringViewDate.shimmeringSpeed = 230.0 / (shimmeringView.frame.width / shimmeringViewDate.frame.width)
        dateFormatter2 = NSDateFormatter()
        dateFormatter2.dateStyle = NSDateFormatterStyle.FullStyle
        
        
        tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
        
        if IS_IOS8 {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        if IS_IOS7 {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func randomColor() -> UIColor {
        
        var hue = (CGFloat)(arc4random() % 256) / 256.0
        var saturation = (CGFloat)(arc4random() % 128) / 256.0 + 0.5
        var brightness = (CGFloat)(arc4random() % 128) / 256.0 + 0.5
        
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    override func viewWillAppear(animated: Bool) {

        //判断是4S的设备，修改字体大小，使之能够正常显示；
        if backView.frame.size.width == 480.0 {
            clockLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 80.0)
            
//            println("a****")
        }
        updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func updateUI() {
        var timeToDisplay = dateFormatter.stringFromDate(NSDate())
        var dateToDisplay = dateFormatter2.stringFromDate(NSDate())
        clockLabel.text = timeToDisplay
        dateLable.text = dateToDisplay
        dateLable.sizeToFit()
        
    }
    
    
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        let params = ["lat":latitude, "lon":longitude]
//        println(params)
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (request, response, json, error) in
                if(error != nil) {
                    println("Error: \(error)")
                    println(request)
                    println(response)
//                    self.loading.text = "Internet appears down!"
                }
                else {
                    println("Success: \(url)")
                    println(request)
                    var json = JSON(json!)
//                    self.updateUISuccess(json)
                    
                    self.temp = json["list"][0]["main"]["temp"].double
                    println("temp = *********")
                    println(self.temp)
                    
                    //设置double输出的格式
                    let tem = self.temp - 273.15
                    let str = NSString(format: "%.1f", tem)
                    self.tempLabel.text = "\(str) ℃"
                    self.tempLabel.hidden = false 
                }
        }
    }
    
    
    
    //MARK: - CLLocationManagerDelegate 
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
//        self.loading.text = "Can't get your location!"
    }
    
}

