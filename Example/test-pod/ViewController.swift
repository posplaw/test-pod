//
//  ViewController.swift
//  test-pod
//
//  Created by Alex Oakley on 12/08/2022.
//  Copyright (c) 2022 Alex Oakley. All rights reserved.
//

import UIKit
import Passbase
import test

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        PassbaseSDK.initialize()
        test.initPassbase()
    }
}

