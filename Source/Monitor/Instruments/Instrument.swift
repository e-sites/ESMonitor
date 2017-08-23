//
//  Instrument.swift
//  GoalsApp
//
//  Created by Bas van Kuijck on 21/06/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import Foundation
import UIKit

public protocol Instrument {
    var currentValue:Double { get }
    var abbreviation:String { get }
    var maximumValue:Double? { get }
    var color:UIColor? { get }
    
    func start()
    func stop()
}
