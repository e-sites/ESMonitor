//
//  ThreadCountInstrument.swift
//  iBandPlus
//
//  Created by Bas van Kuijck on 22/08/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import Foundation
import UIKit
import ESMonitorThreadCount

public class ThreadCountInstrument: Instrument {
    public var currentValue: Double {
        return Double(ThreadCount.get())
    }

    public var maximumValue: Double? {
        return 50
    }

    public var abbreviation: String {
        return "THR"
    }

    public var color: UIColor? {
        return UIColor.cyan
    }


    public func start() {

    }

    public func stop() {

    }
}
