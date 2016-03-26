//
//  SnoteAPI.swift
//  snote
//
//  Created by nevercry on 3/26/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import Foundation
import Moya

// MARK: - Provider setup
let SnoteProvider = MoyaProvider<Snote>()

enum Snote {
    case CreateUser(name: String, passwod: String)
    case Login(name: String, password: String)
}

extension Snote: TargetType {
    var baseURL: NSURL { return NSURL(string: "http://10.0.1.15:3000/api/v1")! }
    var path: String {
        switch self {
        case .CreateUser(_, _):
            return "/user/signup"
        case .Login(_, _):
            return "/user/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .CreateUser, .Login:
            return .POST
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .CreateUser(let name, let password):
            return ["name": name, "password": password]
        case .Login(let name, let password):
            return ["name": name, "password": password]
        }
    }
    
    var sampleData: NSData {
        switch self {
        case .CreateUser:
            return "{\"token\":abcdefg.higklmn.opqrst}".UTF8EncodedData
        case .Login:
            return "{\"token\":abcdefg.higklmn.opqrst}".UTF8EncodedData
        }
    }
}

public func url(route: TargetType) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString
}



// MARK: - Helpers
private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}