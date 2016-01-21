//
//  ViewController.swift
//  HamonExample
//
//  Created by yukiasai on 2016/01/21.
//  Copyright (c) 2016 yukiasai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let rippleView = { Void -> RippleView in
        let view = RippleView()
        view.coreImage = UIImage(named: "q")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !rippleView.appeared, let buttonItem = navigationItem.rightBarButtonItems?.first {
            rippleView.appearAtBarButtonItem(buttonItem)
        }
        
        if !rippleView.appeared {
            rippleView.appearAtView(view)
        }
    }

}

