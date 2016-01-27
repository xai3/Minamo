//
//  ViewController.swift
//  MinamoExample
//
//  Created by yukiasai on 2016/01/21.
//  Copyright (c) 2016 yukiasai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let rippleView = { Void -> RippleView in
        let view = RippleView(image: UIImage(named: "q"), tintColor: UIColor(red: 0.3, green: 0.7, blue: 1, alpha: 1))
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !rippleView.appeared, let buttonItem = navigationItem.rightBarButtonItems?.first {
            rippleView.appearAtBarButtonItem(buttonItem, offset: CGPointMake(-10, 10))
            rippleView.delegate = self
        }
    }
}

extension ViewController: RippleViewDelegate {
    func rippleViewTapped(view: RippleView) {
//        view.disappear()
    }
}

