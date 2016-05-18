//
//  RippleView.swift
//  Minamo
//
//  Created by yukiasai on 2016/01/21.
//  Copyright (c) 2016 yukiasai. All rights reserved.
//

import UIKit

public protocol RippleViewDelegate: class {
    func rippleViewTapped(view: RippleView)
}

public class RippleView: UIView {
    static let defaultSize = CGSizeMake(24, 24)
    static let defaultRingWidth = CGFloat(3)
    
    public var delegate: RippleViewDelegate?
    public var size: CGSize = RippleView.defaultSize
    public var contentInset: CGFloat = 0
    
    private var coreLayer = CAShapeLayer()
    
    public var ringScale: Float = 2 {
        didSet { restartAnimation() }
    }
    
    public var duration: NSTimeInterval = 1.5 {
        didSet { restartAnimation() }
    }
    
    public var coreImage: UIImage? {
        didSet { imageView.image = coreImage }
    }
    
    init() {
        super.init(frame: CGRectZero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        tintColor = nil
        
        layer.addSublayer(ringLayer)
        layer.addSublayer(coreLayer)
        addSubview(imageView)
        
        userInteractionEnabled = false
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        coreLayer.frame = contentFrame
        coreLayer.path = UIBezierPath(ovalInRect: coreLayer.bounds).CGPath
        ringLayer.frame = contentFrame
        ringLayer.path = UIBezierPath(ovalInRect: ringLayer.bounds).CGPath
        imageView.frame = contentFrame
    }
    
    private var contentFrame: CGRect {
        return CGRectMake(contentInset, contentInset, bounds.width - contentInset * 2, bounds.height - contentInset * 2)
    }
    
    private lazy var ringLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = RippleView.defaultRingWidth
        layer.fillColor = UIColor.clearColor().CGColor
        return layer
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.contentFrame)
        imageView.contentMode = .Center
        return imageView
    }()
}

public extension RippleView {
    override public var userInteractionEnabled: Bool {
        get { return super.userInteractionEnabled }
        set {
            if newValue {
                addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RippleView.viewTapped(_:))))
            } else {
                gestureRecognizers?.forEach { removeGestureRecognizer($0) }
            }
            super.userInteractionEnabled = newValue
        }
    }
    
    override public var tintColor: UIColor! {
        get { return super.tintColor }
        set {
            super.tintColor = newValue ?? UIApplication.sharedApplication().keyWindow?.tintColor
            coreLayer.fillColor = tintColor.CGColor
            ringLayer.strokeColor = tintColor.CGColor
        }
    }
    
    public var coreHidden: Bool {
        get { return coreLayer.hidden }
        set { coreLayer.hidden = newValue }
    }
    
    public var ringHidden: Bool {
        get { return ringLayer.hidden }
        set { ringLayer.hidden = newValue }
    }
    
    public var ringWidth: CGFloat {
        get { return ringLayer.lineWidth }
        set { ringLayer.lineWidth = newValue }
    }
}

// MARK: Animation

public extension RippleView {
    public func startAnimation() {
        ringLayer.removeAllAnimations()
        
        let scaleAnimation = { Void -> CAAnimation in
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.fromValue = NSNumber(float: 1)
            animation.toValue = NSNumber(float: ringScale)
            animation.duration = duration
            return animation
        }()
        
        let opacityAnimation = { Void -> CAAnimation in
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.fromValue = NSNumber(float: 1)
            animation.toValue = NSNumber(float: 0)
            animation.duration = duration
            return animation
        }()
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.repeatCount = Float.infinity
        group.duration = duration
        
        ringLayer.addAnimation(group, forKey: "ring_animation")
    }
    
    public func restartAnimation() {
        if ringLayer.animationKeys()?.count <= 0 {
            return
        }
        startAnimation()
    }
}

// MARK: Appear and Disappear

public extension RippleView {
    public func appearAtView(view: UIView, offset: CGPoint = CGPointZero) {
        appearInView(view.superview, point: view.center + offset)
    }
    
    public func appearAtBarButtonItem(buttonItem: UIBarButtonItem, offset: CGPoint = CGPointZero) {
        guard let unmanagedView = buttonItem.performSelector(Selector("view")),
            let view = unmanagedView.takeUnretainedValue() as? UIView else {
                return
        }
        appearAtView(view, offset: offset)
    }
    
    public func appearInView(view: UIView?, point: CGPoint) {
        bounds = CGRect(origin: CGPointZero, size: size)
        center = point
        view?.addSubview(self)
        startAnimation()
    }
    
    public func disappear() {
        removeFromSuperview()
    }
    
    public var appeared: Bool {
        return superview != nil
    }
}

extension RippleView: UIGestureRecognizerDelegate {
    func viewTapped(gesture: UITapGestureRecognizer) {
        delegate?.rippleViewTapped(self)
    }
}

func +(l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPointMake(l.x + r.x, l.y + r.y)
}
