//
//  ViewController.swift
//  d-a-s-h-e-s
//
//  Created by Kacy James on 1/22/17.
//  Copyright © 2017 Student Driver. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bannerText: CLTypingLabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerText.charInterval = 0.2
        bannerText.text = "hello "
        // Thread.sleep(forTimeInterval: bannerText.charInterval * 5)
        // bannerText.text = StringManipulator.dashify(bannerText.text)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

