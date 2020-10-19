//
//  TodoListItem.swift
//  Todoey
//
//  Created by Illya Sirosh on 17.10.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class TodoListItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateAdded: Date = Date()
    var list = LinkingObjects(fromType: TodoList.self, property: "items")
}
