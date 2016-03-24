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
    static let defaults = NSUserDefaults(suiteName: SnoteConfig.appGroupID)!
    
    static let isLogin = defaults.stringForKey(accessTokenKey) ? true : false
}