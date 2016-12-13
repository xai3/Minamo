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
        let view = RippleView()
        view.tintColor = UIColor(red: 0.3, green: 0.7, blue: 1, alpha: 1)
        view.coreImage = UIImage(named: "q")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !rippleView.appeared, let buttonItem = navigationItem.rightBarButtonItems?.first {
            rippleView.appearAtBarButtonItem(buttonItem, offset: CGPoint(x: -10, y: 10))
            rippleView.delegate = self
            rippleView.isUserInteractionEnabled = true
        }
    }
}

extension ViewController: RippleViewDelegate {
    func rippleViewTapped(_ view: RippleView) {
        view.disappear()
    }
}

