//
//  RippleView.swift
//  Minamo
//
//  Created by yukiasai on 2016/01/21.
//  Copyright (c) 2016 yukiasai. All rights reserved.
//

import UIKit

public protocol RippleViewDelegate: class {
    func rippleViewTapped(_ view: RippleView)
}

open class RippleView: UIView {
    static let defaultSize = CGSize(width: 24, height: 24)
    static let defaultRingWidth = CGFloat(3)
    
    open var delegate: RippleViewDelegate?
    open var size: CGSize = RippleView.defaultSize
    open var contentInset: CGFloat = 0
    
    fileprivate var coreLayer = CAShapeLayer()
    
    open var ringScale: Float = 2 {
        didSet { restartAnimation() }
    }
    
    open var duration: TimeInterval = 1.5 {
        didSet { restartAnimation() }
    }
    
    open var coreImage: UIImage? {
        didSet { imageView.image = coreImage }
    }
    
    init() {
        super.init(frame: CGRect.zero)
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
    
    fileprivate func commonInit() {
        tintColor = nil
        
        layer.addSublayer(ringLayer)
        layer.addSublayer(coreLayer)
        addSubview(imageView)
        
        isUserInteractionEnabled = false
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        coreLayer.frame = contentFrame
        coreLayer.path = UIBezierPath(ovalIn: coreLayer.bounds).cgPath
        ringLayer.frame = contentFrame
        ringLayer.path = UIBezierPath(ovalIn: ringLayer.bounds).cgPath
        imageView.frame = contentFrame
    }
    
    fileprivate var contentFrame: CGRect {
        return CGRect(x: contentInset, y: contentInset, width: bounds.width - contentInset * 2, height: bounds.height - contentInset * 2)
    }
    
    fileprivate lazy var ringLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = RippleView.defaultRingWidth
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    open lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.contentFrame)
        imageView.contentMode = .center
        return imageView
    }()
}

extension RippleView {
    override open var isUserInteractionEnabled: Bool {
        get { return super.isUserInteractionEnabled }
        set {
            if newValue {
                addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RippleView.viewTapped(_:))))
            } else {
                gestureRecognizers?.forEach { removeGestureRecognizer($0) }
            }
            super.isUserInteractionEnabled = newValue
        }
    }
    
    override open var tintColor: UIColor! {
        get { return super.tintColor }
        set {
            super.tintColor = newValue ?? UIApplication.shared.keyWindow?.tintColor
            coreLayer.fillColor = tintColor.cgColor
            ringLayer.strokeColor = tintColor.cgColor
        }
    }
    
    public var coreHidden: Bool {
        get { return coreLayer.isHidden }
        set { coreLayer.isHidden = newValue }
    }
    
    public var ringHidden: Bool {
        get { return ringLayer.isHidden }
        set { ringLayer.isHidden = newValue }
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
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.fromValue = NSNumber(value: 1 as Float)
            animation.toValue = NSNumber(value: ringScale as Float)
            animation.duration = duration
            return animation
        }(())
        
        let opacityAnimation = { Void -> CAAnimation in
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.fromValue = NSNumber(value: 1 as Float)
            animation.toValue = NSNumber(value: 0 as Float)
            animation.duration = duration
            return animation
        }(())
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.repeatCount = Float.infinity
        group.duration = duration
        
        ringLayer.add(group, forKey: "ring_animation")
    }
    
    public func restartAnimation() {
        if let animationCount = ringLayer.animationKeys()?.count, animationCount <= 0 {
            return
        }
        startAnimation()
    }
}

// MARK: Appear and Disappear

public extension RippleView {
    public func appearAtView(_ view: UIView, offset: CGPoint = CGPoint.zero) {
        appearInView(view.superview, point: view.center + offset)
    }
    
    public func appearAtBarButtonItem(_ buttonItem: UIBarButtonItem, offset: CGPoint = CGPoint.zero) {
        guard let unmanagedView = buttonItem.perform(#selector(getter: UITouch.view)),
            let view = unmanagedView.takeUnretainedValue() as? UIView else {
                return
        }
        appearAtView(view, offset: offset)
    }
    
    public func appearInView(_ view: UIView?, point: CGPoint) {
        bounds = CGRect(origin: CGPoint.zero, size: size)
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
    @objc func viewTapped(_ gesture: UITapGestureRecognizer) {
        delegate?.rippleViewTapped(self)
    }
}

func +(l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPoint(x: l.x + r.x, y: l.y + r.y)
}
