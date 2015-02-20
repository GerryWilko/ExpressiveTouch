//
//  InteractionView.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 18/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class InteractionView: UIView {
    var touchDown:Bool
    var start:NSTimeInterval!
    var delegate:UIViewController!
    var timer:NSTimer!
    
    let flickThreshold = 0.15
    
    @IBOutlet weak var rotationLbl: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        touchDown = false
        
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!touchDown) {
            let processor = WaxProcessor.getProcessor()
            start = NSDate.timeIntervalSinceReferenceDate()
            touchDown = true
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("interactionCallback:"), userInfo: nil, repeats: true)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (touchDown) {
            touchDown = false
            timer.invalidate()
            
            let touchUpTime = NSDate.timeIntervalSinceReferenceDate()
            
            detectFlick(start, touchUpTime: touchUpTime)
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchDown = false
        timer.invalidate()
    }
    
    func interactionCallback(timer:NSTimer) {
        rotationLbl.text = String(format: "%.2f", calculateRotation(start, touchUpTime: NSDate.timeIntervalSinceReferenceDate()))
    }
    
    func calculateRotation(touchDownTime:NSTimeInterval, touchUpTime:NSTimeInterval) -> Double {
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.gyroCache.getRangeForTime(touchDownTime, end: touchUpTime)
        
        var totalRotation = 0.0
        
        if (data.count > 1) {
            for i in 1..<data.count {
                totalRotation += data[i].x * Double(NSTimeInterval(data[i].time - data[i-1].time))
            }
        }
        
        return totalRotation
    }
    
    func detectFlick(touchDownTime:NSTimeInterval, touchUpTime:NSTimeInterval) {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("flickCallback:"), userInfo: [touchDownTime, touchUpTime], repeats: false)
    }
    
    func flickCallback(timer:NSTimer) {
        let touchTimes = timer.userInfo as! [NSTimeInterval]
        let processor = WaxProcessor.getProcessor()
        
        let data = processor.accCache.getRangeForTime(touchTimes[1], end: NSDate.timeIntervalSinceReferenceDate())
        
        var flicked = false
        
        if (data.count > 1) {
            for i in 1..<data.count {
                let x = data[i].x * Double(NSTimeInterval(data[i].time - data[i-1].time))
                let y = data[i].y * Double(NSTimeInterval(data[i].time - data[i-1].time))
                let z = data[i].z * Double(NSTimeInterval(data[i].time - data[i-1].time))
                
                let vectorLength = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
                println(vectorLength)
                
                if (vectorLength > 0.06) {
                    flicked = true
                }
            }
        }
        
        let message = flicked ? "Flicked!" : "No Flick"
        
        let flickAlert = UIAlertController(title: "Flicked", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        flickAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        delegate.presentViewController(flickAlert, animated: true, completion: nil)
    }
}