//
//  Note.swift
//  MyNotes
//
//  Created by Sergey Golovin on 10.03.2021.
//  Copyright © 2021 GoldenWindGames LLC. All rights reserved.
//

import UIKit
import RealmSwift

class Note: Object {
    @objc dynamic var title = ""
    @objc dynamic var body = ""
    @objc dynamic var textStyle = ""
    @objc dynamic var image: Data? = nil
}
