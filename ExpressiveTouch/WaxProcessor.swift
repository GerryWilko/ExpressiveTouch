//
//  WaxProcessor.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

var waxProcessor:WaxProcessor!

class WaxProcessor {
    internal let accCache:WaxDataCache
    internal let gyroCache:WaxDataCache
    internal let magCache:WaxDataCache
    internal let infoCache:WaxInfoCache
    
    private let accNorm = 1 / 4096.0
    private let gyroNorm = 0.07
    private let magNorm = 0.1
    
    init() {
        assert(waxProcessor == nil)
        
        accCache = WaxDataCache()
        gyroCache = WaxDataCache()
        magCache = WaxDataCache()
        infoCache = WaxInfoCache()
        
        waxProcessor = self
    }
    
    class func getProcessor() -> WaxProcessor { return waxProcessor }
    
    func updateCache(data:NSData) {
        var dataLength = data.length
        
        assert( dataLength == 20 )
        
        var buffer = [UInt8](count: dataLength, repeatedValue: 0)
        
        data.getBytes(&buffer, length: dataLength)
        
        var ax = CShort(buffer[ 3]) << 8 + CShort(buffer[ 2])
        var ay = CShort(buffer[ 5]) << 8 + CShort(buffer[ 4])
        var az = CShort(buffer[ 7]) << 8 + CShort(buffer[ 6])
        
        var gx = CShort(buffer[ 9]) << 8 + CShort(buffer[ 8])
        var gy = CShort(buffer[11]) << 8 + CShort(buffer[10])
        var gz = CShort(buffer[13]) << 8 + CShort(buffer[12])
        
        var mx = CShort(buffer[15]) << 8 + CShort(buffer[14])
        var my = CShort(buffer[17]) << 8 + CShort(buffer[16])
        var mz = CShort(buffer[19]) << 8 + CShort(buffer[18])
        
        MadgwickAHRSupdate(CFloat(gx), CFloat(gy), CFloat(gz), CFloat(ax), CFloat(ay), CFloat(az), CFloat(mx), CFloat(my), CFloat(mz))
        let madgwick = Vector4D(x: q0, y: q1, z: q2, w: q3)
        
        let time = NSDate.timeIntervalSinceReferenceDate()
        
        accCache.add(WaxData(time: time, x: Double(ax) * accNorm, y: Double(ay) * accNorm, z: Double(az) * accNorm))
        gyroCache.add(WaxData(time: time, x: Double(gx) * gyroNorm, y: Double(gy) * gyroNorm, z: Double(gz) * gyroNorm))
        magCache.add(WaxData(time: time, x: Double(mx) * magNorm, y: Double(my) * magNorm, z: Double(mz) * magNorm))
        infoCache.add(WaxInfo(time: time, madgwick: madgwick))
    }
    
    func startRecording() {
        infoCache.startRecording()
    }
    
    func stopRecording() {
        infoCache.stopRecording()
    }
    
    func tapped() {
        infoCache.tapped()
    }
    
    func pinched() {
        infoCache.pinched()
    }
    
    func rotated() {
        infoCache.rotated()
    }
    
    func swiped() {
        infoCache.swiped()
    }
    
    func panned() {
        infoCache.panned()
    }
    
    func edgePan() {
        infoCache.edgePan()
    }
    
    func longPress() {
        infoCache.longPress()
    }
}