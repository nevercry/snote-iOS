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
}


struct Category {
    var name = ""
    var notes:[String] = []
    var identifer = ""
}