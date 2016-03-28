//
//  SettingViewController.swift
//  snote
//
//  Created by nevercry on 3/28/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIButton!
    
    // 登出账户
    @IBAction func logout(sender: UIButton) {
        SnoteUserDefaults.clearToken()
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate?.startSignUpAndLogin()
    }
    

    
}
