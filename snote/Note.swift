//
//  Note.swift
//  snote
//
//  Created by nevercry on 1/25/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import Foundation

struct Note {
    var title = ""
    var url = ""
    var content = ""
    var note = ""
    var identifier = ""
    var categories:[String] = []
    
    /* 
        title:
        url:
        content:
        note:
    */
    
    func toParameters() -> [String: String] {
        return ["title": title, "url": url, "content": content, "note": note]
    }
}


struct Category {
    var name = ""
    var notes:[String] = []
    var identifer = ""
}