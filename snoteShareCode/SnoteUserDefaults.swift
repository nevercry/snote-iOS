//
//  snoteUserDefaults.swift
//  snote
//
//  Created by nevercry on 3/21/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit

let accessTokenKey = "accessToken"


public class SnoteUserDefaults {
    static let defaults = NSUserDefaults(suiteName: SnoteConfig.appGroupID)!
    
    public static var isLogon = defaults.stringForKey(accessTokenKey) == nil ? false:true
    
    // 保存token
    public class func storeToken(token: String) {
        defaults.setObject(token, forKey: accessTokenKey)
    }
    
    // 清除token
    public class func clearToken() {
        defaults.removeObjectForKey(accessTokenKey)
    }
    
    // token值
    public static var token = defaults.stringForKey(accessTokenKey) ?? ""
    
}