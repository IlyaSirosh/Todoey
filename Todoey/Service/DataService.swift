//
//  DataService.swift
//  Todoey
//
//  Created by Illya Sirosh on 10.10.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class DataService {
    public static let instance = DataService()
    private let realm: Realm
    private var lists: [TodoList] = []
    
    private init(){
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        realm = try! Realm()
        loadLists()
    }

    
    public func getLists() -> [TodoList] {
        return lists
    }
    
    
    public func addList(with name: String){
        let list = TodoList()
        list.name = name
        lists.append(list)
        
        save(list)
    }
    
    public func getItems(of list: TodoList, thatContain searchString: String? = nil) -> [TodoListItem] {
    
        if let searchString = searchString, !searchString.isEmpty {
            let predicate = NSPredicate(format: "title CONTAINS %@", searchString)
            
            return loadItems(of: list, with: predicate)
        }
        
        return loadItems(of: list)
    }
    
    public func toggle(_ item: TodoListItem) {
        do {
            try realm.write {
                item.done = !item.done
            }
        } catch {
            print("Error updating item \(item) \(error)")
        }
    }
    
    public func add(to list: TodoList, itemTitle: String) {
        
        do {
            try realm.write {
                let item = TodoListItem()
                item.title = itemTitle
                item.done = false
                
                list.items.append(item)
            }
        } catch {
            print("Error saving '\(itemTitle)' of '\(list.name)' to Realm")
        }
        
    }
    
    public func deleteItem(_ item: TodoListItem){
        delete(item)
    }
    
    public func deleteList(_ list: TodoList){
        delete(list)
        
        lists.removeAll(where: { $0.name == list.name })
    }
    
    private func save(_ object: Object) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Error saving object \(object) to Realm")
        }
        
    }
    
    private func delete(_ object: Object) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting object \(object) to Realm")
        }
    }
    
    
    private func loadLists() {
        let result = realm.objects(TodoList.self)
        lists = result.map { $0 }
    }
    
    private func loadItems(of list: TodoList) -> [TodoListItem]{
        return list.items
            .sorted(byKeyPath: "dateAdded", ascending: true)
            .map { $0 }
    }
    
    private func loadItems(of list: TodoList, with predicate: NSPredicate) -> [TodoListItem]{
        return list.items
            .filter(predicate)
            .sorted(byKeyPath: "dateAdded", ascending: true)
            .map { $0 }
    }
}
