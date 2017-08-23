//
//  FramerateInstrument.swift
//  GoalsApp
//
//  Created by Bas van Kuijck on 21/06/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import Foundation
import UIKit

public class FramerateInstrument: NSObject {
    
    private class DisplayLinkDelegate: NSObject {
        weak var instrument:FramerateInstrument?
        
        @objc
        func updateFromDisplayLink(_ displayLink: CADisplayLink) {
            instrument?.updateFromDisplayLink(displayLink)
        }
    }
    
    fileprivate var _fps: Double = 0
    fileprivate var _displayLink: CADisplayLink
    private let _displayLinkDelegate: DisplayLinkDelegate
    
    public override init() {
        self._displayLinkDelegate = DisplayLinkDelegate()
        self._displayLink = CADisplayLink(
            target: self._displayLinkDelegate,
            selector: #selector(DisplayLinkDelegate.updateFromDisplayLink(_:))
        )
        super.init()
        self._displayLinkDelegate.instrument = self
        start()
    }
    
    private var _lastNotificationTime: CFAbsoluteTime = 0.0
    private var _numberOfFrames: Int = 0
    
    fileprivate var _runLoop:RunLoop?
    fileprivate var _runLoopModes: RunLoopMode?
    
    @objc private func updateFromDisplayLink(_ displayLink: CADisplayLink) {
        if _lastNotificationTime == 0.0 {
            _lastNotificationTime = CFAbsoluteTimeGetCurrent()
            return
        }
        
        _numberOfFrames += 1
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = currentTime - _lastNotificationTime
        
        if elapsedTime >= 1.0 {
            _fps = Double(_numberOfFrames) / elapsedTime
            _lastNotificationTime = 0.0
            _numberOfFrames = 0
        }
    }
    
    deinit {
        _runLoopModes = nil
        _runLoop = nil
        _displayLink.invalidate()
    }
}

extension FramerateInstrument : Instrument {
    public var currentValue: Double {
        return _fps
    }
    
    public var maximumValue: Double? {
        return 60.0
    }
    
    public var abbreviation:String {
        return "FPS"
    }
    
    public var color:UIColor? {
        return UIColor.yellow
    }
    
    public func start() {
        stop()
        let runLoop = RunLoop.main
        let runLoopModes = RunLoopMode.commonModes
        
        _runLoop = runLoop
        _runLoopModes = runLoopModes
        
        _displayLink.add(to: runLoop, forMode: runLoopModes)
    }
    
    public func stop() {
        guard let runloop = _runLoop, let mode = _runLoopModes else {
            return
        }

        _displayLink.remove(from: runloop, forMode: mode)
    }
}
