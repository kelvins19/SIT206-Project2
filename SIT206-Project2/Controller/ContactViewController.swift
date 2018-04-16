//
//  ContactViewController.swift
//  SIT206-Project2
//
//  Created by Kelvin Salim on 15/4/18.
//  Copyright © 2018 Kelvin Salim. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
}
