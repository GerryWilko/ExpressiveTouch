//
//  RotationRngEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 26/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class RotationRngEvalVC: UIViewController {
    private var messageStack:[String]
    private var maxValue:Float
    private var minValue:Float
    private var recording:Bool
    
    private let csvBuilder:CSVBuilder
    
    @IBOutlet weak var dominantHand: UISegmentedControl!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressWheel: UIActivityIndicatorView!
    
    required init(coder aDecoder: NSCoder) {
        messageStack = [
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Swap the sensor onto your left wrist.\nThen press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Press and hold again.",
            "Now rotate as far as you can to the right.\nThen back to the left, keep your finger held down.",
            "Evaluation Complete. Thank you."
        ]
        
        maxValue = 0.0
        minValue = 0.0
        recording = false
        
        csvBuilder = CSVBuilder(fileNames: ["rotationRange.csv","rotationData.csv"], headerLines: ["Dominant Hand,Wrist,Max Angle,Min Angle", "Time,ax,ay,az,gx,gy,gz,mx,my,mz,gravx,gravy,gravz,yaw,pitch,roll"])
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("rotationRngInstructions", sender: self)
        WaxProcessor.getProcessor().dataCache.subscribe(dataCallback)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!messageStack.isEmpty && dominantHand.selectedSegmentIndex != UISegmentedControlNoSegment) {
            MadgwickAHRSreset()
            progressWheel.startAnimating()
            recording = true
            instructionLbl.text = messageStack[0]
            messageStack.removeAtIndex(0)
            progressBar.setProgress(Float(Float(41 - messageStack.count) / 41.0), animated: true)
        }
    }
    
    func dataCallback(data:WaxData) {
        if (recording) {
            if (self.maxValue < data.getYawPitchRoll().roll) {
                self.maxValue = data.getYawPitchRoll().roll
            }
            
            if (self.minValue > data.getYawPitchRoll().roll) {
                self.minValue = data.getYawPitchRoll().roll
            }
        }
        
        csvBuilder.appendRow(data.print(), index: 1)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!messageStack.isEmpty && dominantHand.selectedSegmentIndex != UISegmentedControlNoSegment) {
            progressWheel.stopAnimating()
            recording = false
            
            let dh = dominantHand.selectedSegmentIndex == 0 ? "Left" : "Right"
            
            if (messageStack.count > 20) {
                csvBuilder.appendRow("\(dh),Right,\(maxValue),\(minValue)", index: 0)
                maxValue = 0.0
                minValue = 0.0
            } else if (messageStack.count > 0) {
                csvBuilder.appendRow("\(dh),Left,\(maxValue),\(minValue)", index: 0)
                maxValue = 0.0
                minValue = 0.0
            }
            
            instructionLbl.text = messageStack[0]
            messageStack.removeAtIndex(0)
            progressBar.setProgress(Float(Float(41 - messageStack.count) / 41.0), animated: true)
            
            if (messageStack.isEmpty) {
                WaxProcessor.getProcessor().dataCache.clearSubscriptions()
                csvBuilder.emailCSV(self, subject: "Rotation Range Evaluation")
            }
        }
    }
}