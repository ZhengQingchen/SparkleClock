//
//  ViewController.swift
//  SparkleClock
//
//  Created by Aaron Douglas on 12/5/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
  var timer: NSTimer!
  var dateFormatter: NSDateFormatter!
    var dateFormatter2: NSDateFormatter!
    
    @IBOutlet var backView: UIView!
  @IBOutlet var clockLabel: UILabel!
  @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var shimmeringView: FBShimmeringView!
  
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var shimmeringViewDate: FBShimmeringView!
    @IBOutlet weak var dateLable: UILabel!
    @IBAction func swipeGesture(sender: AnyObject) {
//        println("zhengjie")
        
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            let randomColor = self.randomColor()
//            self.shimmeringView.backgroundColor = randomColor
//            self.shimmeringViewDate.backgroundColor = randomColor
            self.backView.backgroundColor = randomColor
        })
        
    }
    
    @IBAction func doubleTapGesture(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.backView.backgroundColor = UIColor.blackColor()
        })
    }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateClock"), userInfo: nil, repeats: true)
    dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
    
    shimmeringView.contentView = clockLabel
    shimmeringView.shimmering = true

    
    shimmeringViewDate.contentView = dateLable
    shimmeringViewDate.shimmering = true
    
    
    shimmeringViewDate.shimmeringSpeed = 230.0 / (shimmeringView.frame.width / shimmeringViewDate.frame.width)
    println("\(shimmeringViewDate.shimmeringSpeed)")
    dateFormatter2 = NSDateFormatter()
    dateFormatter2.dateStyle = NSDateFormatterStyle.FullStyle
    
    
    tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
  }
  
    
    func randomColor() -> UIColor {
        
        var hue = (CGFloat)(arc4random() % 256) / 256.0
        var saturation = (CGFloat)(arc4random() % 128) / 256.0 + 0.5
        var brightness = (CGFloat)(arc4random() % 128) / 256.0 + 0.5
        
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
  override func viewWillAppear(animated: Bool) {
    updateClock()
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
  
  func updateClock() {
    var timeToDisplay = dateFormatter.stringFromDate(NSDate())
    var dateToDisplay = dateFormatter2.stringFromDate(NSDate())
    clockLabel.text = timeToDisplay
    dateLable.text = dateToDisplay
    dateLable.sizeToFit()
  }
  
  @IBAction func didTapView() {
    shimmeringView.shimmering = !shimmeringView.shimmering
    shimmeringViewDate.shimmering = !shimmeringViewDate.shimmering
    tapGestureRecognizer.enabled = false
    
    UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseIn, animations: {
      self.clockLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)
        self.dateLable.transform = CGAffineTransformMakeScale(1.2, 1.2)
      }, completion: { (finished) -> Void in
        UIView.animateWithDuration(0.25, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
          self.clockLabel.transform = CGAffineTransformIdentity
            self.dateLable.transform = CGAffineTransformIdentity
          }, completion: {
            (finished) -> Void in
            self.tapGestureRecognizer.enabled = true
        })
    })
  }
}

