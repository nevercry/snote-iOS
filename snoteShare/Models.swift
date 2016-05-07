//
//  Models.swift
//  snote
//
//  Created by nevercry on 4/5/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import Foundation
import RealmSwift

let realmQueue = dispatch_queue_create("com.Snote.RealmQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY,0))

class Note: Object {
    dynamic var noteID = ""
    dynamic var title = ""
    dynamic var url = ""
    dynamic var note = ""
    dynamic var content = ""
    dynamic var createdAt = NSDate(timeIntervalSince1970: 1)
    dynamic var category: Category?
    
    override static func primaryKey() -> String? {
        return "noteID"
    }
    
    func toParameters() -> [String: String] {
        return ["title": title, "url": url, "content": content, "note": note]
    }
}


class Category: Object {
    dynamic var categoryID = ""
    dynamic var name = ""
    dynamic var createdAt = NSDate(timeIntervalSince1970: 1)
    
    override static func primaryKey() -> String? {
        return "categoryID"
    }
    
    let notes = LinkingObjects(fromType: Note.self, property: "category")
}

