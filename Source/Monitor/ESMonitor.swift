//
//  ESMonitor.swift
//  GoalsApp
//
//  Created by Bas van Kuijck on 21/06/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import Foundation
import UIKit

public extension UIWindow {
    @discardableResult public func addMonitor() -> ESMonitor {
        return ESMonitor(in: self)
    }
}

public class ESMonitor : UIView {
    public enum Position {
        case leftTop
        case centerTop
        case rightTop
        case rightCenter
        case rightBottom
        case centerBottom
        case leftBottom
        case leftCenter
    }
    
    // Constructor
    // --------------------------------------------------------
    
    convenience init(`in` window: UIWindow) {
        self.init(frame: CGRect.zero)
        window.addSubview(self)
        _updateLayout()
        _updateGraphs()
        _updateRefreshrate()
        self.addGestureRecognizer(_panGestureRecognizer)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
        self.becomeFirstResponder()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("You should call init(in:)")
    }

    override public var canBecomeFirstResponder: Bool {
        return true
    }

    override public func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.isHidden = !self.isHidden
        }
    }
    
    // Private variables
    // --------------------------------------------------------
    
    fileprivate lazy var _stackView:UIStackView = {
        let sv = UIStackView(frame: CGRect.zero)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .equalSpacing
        sv.alignment = .top
        sv.axis = .vertical
        sv.spacing = 2
        self.addSubview(sv)
        
        sv.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        sv.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        
        self._topInsetConstraint = sv.topAnchor.constraint(equalTo: self.topAnchor, constant: 5 + self._topInset)
        self._topInsetConstraint?.isActive = true
        return sv
    }()
    
    fileprivate var _refreshTimer:Timer?
    lazy fileprivate var _panGestureRecognizer:UIPanGestureRecognizer = {
        let gr = UIPanGestureRecognizer(target: self, action: #selector(_pan(_:)))
        gr.isEnabled = true
        return gr
    }()
    
    fileprivate var _panGestureTouchPoint: CGPoint?
    fileprivate var _isDragged = false
    fileprivate var _graphViews: [MonitorGraphView] = []
    fileprivate var _positionConstraints: [NSLayoutConstraint] = []
    fileprivate var _constraints: [NSLayoutConstraint] = []
    fileprivate var _topInsetConstraint: NSLayoutConstraint?
    fileprivate var _dropTargetView: UIView?
    
    // Variables
    // --------------------------------------------------------
    
    public var position:Position = .rightTop {
        didSet {
            _isDragged = false
            _updateLayout()
        }
    }
    
    public var refreshRate: TimeInterval = 0.5 {
        didSet {
            _updateRefreshrate()
        }
    }
    
    public var width: CGFloat = 100 {
        didSet {
            _updateLayout()
        }
    }
    
    public var graphHeight: CGFloat = 40 {
        didSet {
            _updateGraphs()
        }
    }
    
    public var instruments: [Instrument] = [ FramerateInstrument(), MemoryInstrument(), ThreadCountInstrument() ] {
        didSet {
            _updateGraphs()
        }
    }
    
    public fileprivate(set) var isPaused:Bool = false
    
    public var isDraggable:Bool = true {
        didSet {
            _panGestureRecognizer.isEnabled = isDraggable
            if (!isDraggable) {
                _isDragged = false
                _updateLayout()
            }
        }
    }
}

// MARK: - Layout
extension ESMonitor {
    
    fileprivate var _topInset: CGFloat {
        if (_isDragged) {
            return 0
        }
        switch (position) {
        case .rightTop, .leftTop, .centerTop:
            return 20
            
        default:
            return 0
        }
    }
    
    fileprivate func _updateLayout() {
        guard let superview = self.superview else {
            return
        }
        
        self.removeConstraints(_constraints)
        _constraints.removeAll()
        _positionConstraints.removeAll()
        _topInsetConstraint?.constant = 5 + _topInset
        
        _constraints.append(self.widthAnchor.constraint(equalToConstant: width))
        
        defer {
            for constraint in _constraints {
                constraint.isActive = true
            }
        }
        
        if (_isDragged) {
            return
        }
        
        switch (position) {
            
        case .leftTop, .leftBottom, .leftCenter:
            _positionConstraints.append(self.leadingAnchor.constraint(equalTo: superview.leadingAnchor))
            
        case .rightTop, .rightBottom, .rightCenter:
            _positionConstraints.append(self.trailingAnchor.constraint(equalTo: superview.trailingAnchor))
            
        case .centerTop, .centerBottom:
            _positionConstraints.append(self.centerXAnchor.constraint(equalTo: superview.centerXAnchor))
        }
        
        switch (position) {
        case .leftTop, .rightTop, .centerTop:
            _positionConstraints.append(self.topAnchor.constraint(equalTo: superview.topAnchor))
            
        case .leftBottom, .rightBottom, .centerBottom:
            _positionConstraints.append(self.bottomAnchor.constraint(equalTo: superview.bottomAnchor))
            
        case .leftCenter, .rightCenter:
            _positionConstraints.append(self.centerYAnchor.constraint(equalTo: superview.centerYAnchor))
        }
        _constraints.append(contentsOf: _positionConstraints)
    }
    
    fileprivate func _updateGraphs() {
        for asv in _stackView.arrangedSubviews {
            _stackView.removeArrangedSubview(asv)
        }
        _graphViews.removeAll()
        
        for instrument in instruments {
            let monitorGraph = MonitorGraphView(instrument: instrument)
            _stackView.addArrangedSubview(monitorGraph)
            monitorGraph.heightAnchor.constraint(equalToConstant: graphHeight).isActive = true
            monitorGraph.trailingAnchor.constraint(equalTo: _stackView.trailingAnchor).isActive = true
            monitorGraph.leadingAnchor.constraint(equalTo: _stackView.leadingAnchor).isActive = true
            _graphViews.append(monitorGraph)
        }
    }
}

extension ESMonitor {
    @objc fileprivate func _pan(_ recognizer: UIPanGestureRecognizer) {
        guard let superview = self.superview else {
            return
        }
        let point = recognizer.location(in: superview)
        
        
        
        switch (recognizer.state) {
        case .began:
            _panGestureTouchPoint = recognizer.location(in: self)
            
        case .changed:
            guard let pgtp = _panGestureTouchPoint else {
                return
            }
            if (!_isDragged) {
                _isDragged = true
                for constraint in _positionConstraints {
                    constraint.isActive = false
                }
                self.removeConstraints(_positionConstraints)
                _positionConstraints.removeAll()
                _topInsetConstraint?.constant = 5
                
                _positionConstraints.append(self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: point.x - pgtp.x))
                _positionConstraints.append(self.topAnchor.constraint(equalTo: superview.topAnchor, constant: point.y - pgtp.y))
                for constraint in _positionConstraints {
                    constraint.isActive = true
                }
            } else {
                _positionConstraints.first?.constant = point.x - pgtp.x
                _positionConstraints.last?.constant = point.y - pgtp.y
            }
            
            
        default:
            _panGestureTouchPoint = nil
        }
        self.layoutIfNeeded()
        
        var snapPoint:CGPoint?
        var snapPosition:Position?
        
        let snappingDistance:CGFloat = 20
        
        if (frame.origin.x < snappingDistance) {
            if (frame.origin.y < snappingDistance) {
                snapPoint = CGPoint.zero
                snapPosition = .leftTop
                
            } else if (frame.origin.y > superview.frame.size.height - snappingDistance - self.frame.size.height) {
                snapPoint = CGPoint(x: 0, y: superview.frame.size.height - self.frame.size.height)
                snapPosition = .leftBottom
                
            } else if (frame.origin.y + (frame.size.height / 2) > (superview.frame.size.height / 2) - (snappingDistance / 2) && frame.origin.y + (frame.size.height / 2) < (superview.frame.size.height / 2) + (snappingDistance / 2)) {
                snapPoint = CGPoint(x: 0, y: (superview.frame.size.height / 2) - (self.frame.size.height / 2))
                snapPosition = .leftCenter
            }
        } else if (frame.origin.x > superview.frame.size.width - snappingDistance - self.frame.size.width) {
            if (frame.origin.y < snappingDistance) {
                snapPoint = CGPoint(x: superview.frame.size.width - self.frame.size.width, y: 0)
                snapPosition = .rightTop
                
            } else if (frame.origin.y > superview.frame.size.height - snappingDistance - self.frame.size.height) {
                snapPoint = CGPoint(x: superview.frame.size.width - self.frame.size.width, y: superview.frame.size.height - self.frame.size.height)
                snapPosition = .rightBottom
            
            } else if (frame.origin.y + (frame.size.height / 2) > (superview.frame.size.height / 2) - (snappingDistance / 2) && frame.origin.y + (frame.size.height / 2) < (superview.frame.size.height / 2) + (snappingDistance / 2)) {
                snapPoint = CGPoint(x: superview.frame.size.width - self.frame.size.width, y: (superview.frame.size.height / 2) - (self.frame.size.height / 2))
                snapPosition = .rightCenter
            }
        } else if (frame.origin.x + (frame.size.width / 2) > (superview.frame.size.width / 2) - (snappingDistance / 2) && frame.origin.x + (frame.size.width / 2) < (superview.frame.size.width / 2) + (snappingDistance / 2)) {
            
            if (frame.origin.y < snappingDistance) {
                snapPoint = CGPoint(x: (superview.frame.size.width / 2) - (self.frame.size.width / 2), y: 0)
                snapPosition = .centerTop
                
            } else if (frame.origin.y > superview.frame.size.height - snappingDistance - self.frame.size.height) {
                snapPoint = CGPoint(x: (superview.frame.size.width / 2) - (self.frame.size.width / 2), y: superview.frame.size.height - self.frame.size.height)
                snapPosition = .centerBottom
            }
        }
        
        if let position = snapPoint, let pp = snapPosition {
            let snapFrame = CGRect(x: position.x, y: position.y, width: self.frame.size.width, height: self.frame.size.height)
            if _dropTargetView == nil {
                let v = UIView(frame: snapFrame)
                v.backgroundColor = UIColor(white: 0, alpha: 0.25)
                superview.insertSubview(v, belowSubview: self)
                _dropTargetView = v
            } else {
                _dropTargetView?.frame = snapFrame
            }
            
            if (recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed) {
                for constraint in _positionConstraints {
                    constraint.isActive = false
                }
                self.removeConstraints(_positionConstraints)
                _positionConstraints.removeAll()
                self.position = pp
                _dropTargetView?.removeFromSuperview()
                _dropTargetView = nil
            }
            
        } else {
            _dropTargetView?.removeFromSuperview()
            _dropTargetView = nil
        }
    }
}

extension ESMonitor {
    public func pause() {
        isPaused = true
        for instrument in instruments {
            instrument.stop()
        }
    }
    
    public func resume() {
        isPaused = false
        for instrument in instruments {
            instrument.start()
        }
    }
    
    fileprivate func _updateRefreshrate() {
        _refreshTimer?.invalidate()
        let timer = Timer(timeInterval: refreshRate, target: self, selector: #selector(_tick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    @objc private func _tick() {
        if let window = self.superview, window.subviews.last != self {
            window.bringSubview(toFront: self)
        }
        if (isPaused) {
            return
        }
        for graphView in _graphViews {
            graphView.update()
        }
    }
}
