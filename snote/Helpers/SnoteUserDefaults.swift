//
//  snoteUserDefaults.swift
//  snote
//
//  Created by nevercry on 3/21/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit

let accessTokenKey = "accessToken"


class SnoteUserDefaults {
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    static var isLogon = defaults.stringForKey(accessTokenKey) == nil ? false:true
    
    // 保存token
    class func storeToken(token: String) {
        defaults.setObject(token, forKey: accessTokenKey)
    }
    
    // 清除token
    class func clearToken() {
        defaults.removeObjectForKey(accessTokenKey)
    }
}