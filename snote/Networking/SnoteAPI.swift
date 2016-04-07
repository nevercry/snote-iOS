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
let SnoteProvider = MoyaProvider<Snote>(endpointClosure: endpointClosure)

enum Snote {
    case CreateUser(name: String, passwod: String)
    case Login(name: String, password: String)
    case Notes
    case Categories
    case CreateCategory(name: String)
}

extension Snote: TargetType {
    var baseURL: NSURL { return NSURL(string: "http://10.0.1.15:3000/api/v1")! }
    var path: String {
        switch self {
        case .CreateUser(_, _):
            return "/user/signup"
        case .Login(_, _):
            return "/user/login"
        case .Notes:
            return "/notes/"
        case .Categories:
            return "/categories/"
        case .CreateCategory(_):
            return "/categories/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .CreateUser, .Login, .CreateCategory:
            return .POST
        case .Notes, .Categories:
            return .GET
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .CreateUser(let name, let password):
            return ["name": name, "password": password]
        case .Login(let name, let password):
            return ["name": name, "password": password]
        case .Notes, .Categories:
            return nil
        case .CreateCategory(let name):
            return ["name": name]
        }
    }
    
    var sampleData: NSData {
        switch self {
        case .CreateUser:
            return "{\"token\":abcdefg.higklmn.opqrst}".UTF8EncodedData
        case .Login:
            return "{\"token\":abcdefg.higklmn.opqrst}".UTF8EncodedData
        case .Notes:
            return "{\"token\":abcdefg.higklmn.opqrst}".UTF8EncodedData
        case .Categories:
            return "{\"token\":abcdefg.higklmn.opqrst}".UTF8EncodedData
        case .CreateCategory:
            return "{\"token\":abcdefg.higklmn.opqrst}".UTF8EncodedData
        }
    }
}

let endpointClosure = { (target: Snote) -> Endpoint<Snote> in
    let endpoint: Endpoint<Snote> =  Endpoint<Snote>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
    
    switch target {
    case .CreateUser, .Login:
        return endpoint
    default:
        return endpoint.endpointByAddingHTTPHeaderFields(["x-access-token":SnoteUserDefaults.token])
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