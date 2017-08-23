//
//  MemoryInstrument.swift
//  GoalsApp
//
//  Created by Bas van Kuijck on 21/06/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import Foundation
import UIKit

public class MemoryInstrument: Instrument {
    public var currentValue: Double {
        // Thanks to Jerry: https://stackoverflow.com/questions/27556807/swift-pointer-problems-with-mach-task-basic-info/39048651#39048651
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1000000
        }
        return 0
    }
    
    public var maximumValue: Double? {
        return nil
    }
    
    public var abbreviation: String {
        return "RAM"
    }
    
    public var color: UIColor? {
        return UIColor.magenta
    }
    
    
    public func start() {
        
    }
    
    public func stop() {
        
    }
}
