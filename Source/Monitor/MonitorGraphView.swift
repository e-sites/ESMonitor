//
//  MonitorGraph.swift
//  GoalsApp
//
//  Created by Bas van Kuijck on 21/06/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import Foundation
import UIKit

class MonitorGraphView : UIView {
    
    fileprivate lazy var _typeLabel:UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 8, weight: .medium)
        self.addSubview(lbl)
        lbl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        lbl.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
        lbl.heightAnchor.constraint(equalToConstant: 10).isActive = true
        lbl.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        return lbl
    }()
    
    fileprivate lazy var _maxValueIndexLabel:UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 6)
        self.addSubview(lbl)
        lbl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -2).isActive = true
        lbl.topAnchor.constraint(equalTo: self.topAnchor, constant: -3).isActive = true
        lbl.heightAnchor.constraint(equalToConstant: 10).isActive = true
        lbl.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        return lbl
    }()
    
    fileprivate lazy var _currentValueLabel:UILabel = {
        let lbl = UILabel()
        lbl.alpha = 0.5
        lbl.textColor = UIColor.black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 6, weight: .bold)
        self.addSubview(lbl)
        lbl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 3).isActive = true
        lbl.heightAnchor.constraint(equalToConstant: 10).isActive = true
        lbl.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self._valueLabelWidthLayoutConstraint = lbl.widthAnchor.constraint(equalToConstant: 10)
        self._valueLabelWidthLayoutConstraint?.isActive = true
        
        return lbl
    }()
    
    private var _valueLabelWidthLayoutConstraint:NSLayoutConstraint?
    
    private(set) var maximumValue:Double = 100.0 {
        didSet {
            _maxValueIndexLabel.text = "\(String(describing: Int(maximumValue)))"
        }
    }
    
    let instrument:Instrument
    
    init(instrument: Instrument) {
        self.instrument = instrument
        super.init(frame: CGRect.zero)
        _typeLabel.text = instrument.abbreviation
        if let maxValue = instrument.maximumValue {
            maximumValue = maxValue
        }
        _currentValueLabel.backgroundColor = instrument.color
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var maximumValueCount:Int = 50
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.clear(rect)
        context.setLineWidth(1.0 / UIScreen.main.scale)
        context.setStrokeColor(UIColor.white.cgColor)
        
        let leftInset:CGFloat = 12
        let topOffset:CGFloat = 2
        
        context.addLines(between: [
            CGPoint(x: leftInset, y: 0),
            CGPoint(x: leftInset, y: rect.size.height),
            CGPoint(x: rect.size.width, y: rect.size.height)
            ])
        
        context.addLines(between: [
            CGPoint(x: leftInset - 2, y: topOffset),
            CGPoint(x: leftInset, y: topOffset)
            ])
        context.drawPath(using: .stroke)
        
        
        context.setLineDash(phase: 0, lengths: [0, 1])
        context.setStrokeColor(UIColor(white: 1, alpha: 0.5).cgColor)
        
        context.addLines(between: [
            CGPoint(x: leftInset, y: topOffset),
            CGPoint(x: rect.size.width, y: topOffset)
            ])
        context.drawPath(using: .stroke)
        
        self.maximumValue = max(values.max() ?? self.maximumValue, self.maximumValue)
        let percentages = values.map { CGFloat(1 - ($0 / self.maximumValue)) }
        let offsets = percentages.map { (topOffset + (CGFloat(rect.size.height - 2.0) * $0)) }
        
        var x = leftInset + 1
        let spacing:CGFloat = (rect.size.width - leftInset) / CGFloat(maximumValueCount)
        var lines:[CGPoint] = []
        for y in offsets {
            x += spacing
            lines.append(CGPoint(x: x, y: y))
        }
        context.setLineWidth(1.0)
        context.setLineDash(phase: 0, lengths: [])
        context.setStrokeColor((instrument.color ?? UIColor.cyan).cgColor)
        context.addLines(between: lines)
        context.drawPath(using: .stroke)
    }
    
    func update() {
        while values.count == maximumValueCount {
            values.removeFirst()
        }
        let value = String(describing: Int(instrument.currentValue))
        if (value != _currentValueLabel.text) {
            _currentValueLabel.text = value
            let size = _currentValueLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: _currentValueLabel.frame.size.height))
            _valueLabelWidthLayoutConstraint?.constant = size.width + 10
        }
        values.append(instrument.currentValue)
        setNeedsDisplay()
    }
    
    var values:[Double] = []
}
