//
//  TodoList.swift
//  Todoey
//
//  Created by Illya Sirosh on 17.10.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class TodoList: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var backgroundColor: String = ""
    let items = List<TodoListItem>()
}
