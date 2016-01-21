//
//  RippleView.swift
//  Hamon
//
//  Created by yukiasai on 2016/01/21.
//  Copyright © 2016年 yukiasai. All rights reserved.
//

import UIKit

public class RippleView: UIView {
    static let defaultSize = CGSizeMake(24, 24)
    static let defaultRingWidth = CGFloat(3)
    
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
        userInteractionEnabled = false
        tintColor = nil
        
        layer.addSublayer(ringLayer)
        layer.addSublayer(coreLayer)
        addSubview(imageView)
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
    
    public var ringScale: Float = 2 {
        didSet { restartAnimation() }
    }
    
    public var duration: NSTimeInterval = 1.5 {
        didSet { restartAnimation() }
    }
    
    public var coreImage: UIImage? {
        didSet { imageView.image = coreImage }
    }
    
    private var coreLayer = CAShapeLayer()
    
    private lazy var ringLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = RippleView.defaultRingWidth
        layer.fillColor = UIColor.clearColor().CGColor
        return layer
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .Center
        return imageView
    }()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        coreLayer.frame = bounds
        coreLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        ringLayer.frame = bounds
        ringLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        imageView.frame = bounds
    }
    
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
    
    public func appearAtView(view: UIView, size: CGSize = RippleView.defaultSize) {
        appearInView(view.superview, point: view.center, size: size)
    }
    
    public func appearAtBarButtonItem(buttonItem: UIBarButtonItem, size: CGSize = RippleView.defaultSize) {
        guard let unmanagedView = buttonItem.performSelector("view"),
            let view = unmanagedView.takeUnretainedValue() as? UIView else {
                return
        }
        appearAtView(view, size: size)
    }
    
    public func appearInView(view: UIView?, point: CGPoint, size: CGSize = RippleView.defaultSize) {
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
