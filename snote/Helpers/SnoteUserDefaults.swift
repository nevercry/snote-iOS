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
}