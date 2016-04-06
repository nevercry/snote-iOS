//
//  SettingViewController.swift
//  snote
//
//  Created by nevercry on 3/28/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit
import RealmSwift

class SettingViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIButton!
    
    // 登出账户
    @IBAction func logout(sender: UIButton) {
        SnoteUserDefaults.clearToken()
        
        // 清除数据
        let manager = NSFileManager.defaultManager()
        let realmPath = Realm.Configuration.defaultConfiguration.path! as NSString
        let realmPaths = [
            realmPath as String,
            realmPath.stringByAppendingPathExtension("lock")!,
            realmPath.stringByAppendingPathExtension("log_a")!,
            realmPath.stringByAppendingPathExtension("log_b")!,
            realmPath.stringByAppendingPathExtension("note")!
                          ]
        for path in realmPaths {
            do {
                try manager.removeItemAtPath(path)
            } catch {
                print(error)
                self.alertViewShow("删除数据库出错", andMessage: "请重试")
                return
            }
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate?.startSignUpAndLogin()
    }
    

    
}
