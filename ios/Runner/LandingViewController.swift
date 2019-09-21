//
//  LandingViewController.swift
//  Runner
//
//  Created by Raul Rea on 9/5/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let flutterViewController = segue.destination as? FlutterViewController {
            FlutterRepo.shared.setup(flutterViewController: flutterViewController)
            NativeDataSourceRouter.shared.setup(flutterViewController: flutterViewController)
        }
    }
    
    @IBAction func displayNative(_ sender: Any) {
        DispatchQueue.main.async {
            let topGamesView = TopGamesViewController(nibName: "TopGamesViewController", bundle: nil)
            self.showDetailViewController(topGamesView, sender: nil)
        }
    }
}
