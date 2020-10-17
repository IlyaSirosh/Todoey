//
//  DataService.swift
//  Todoey
//
//  Created by Illya Sirosh on 10.10.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class DataService {
    public static let instance = DataService()
    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    private var lists: [TodoList] = []
    
    private init(){
        loadLists()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }

    
    public func getLists() -> [TodoList] {
        return lists
    }
    
    
    public func addList(with name: String){
        let list = TodoList(context: context)
        list.name = name
        
        lists.append(list)
        saveData()
    }
    
    public func getItems(of list: TodoList, thatContain searchString: String? = nil) -> [TodoListItem] {
        
        let request: NSFetchRequest<TodoListItem> = TodoListItem.fetchRequest()
        
        if let searchString = searchString, !searchString.isEmpty{
            request.predicate = NSPredicate(format: "title CONTAINS %@", searchString)
        }
        
        return loadItems(of: list, with: request)
    }
    
    public func update(_ item: TodoListItem) {
        saveData()
    }
    
    public func add(to list: TodoList, itemTitle: String) -> TodoListItem {
        let item = TodoListItem(context: context)
        item.title = itemTitle
        item.done = false
        item.list = list
        
        saveData()
        
        return item
    }
    
    public func delete(_ item: TodoListItem){
        context.delete(item)
        saveData()
    }
    
    public func delete(_ list: TodoList){
        context.delete(list)
        
        lists.removeAll(where: { $0.name == list.name })
        
        saveData()
    }
    
    private func saveData() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Error saving context \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func loadLists(with request: NSFetchRequest<TodoList> = TodoList.fetchRequest()) {
        do {
            lists = try context.fetch(request)
        } catch {
            print("Error loading data from context \(error)")
        }
    }
    
    private func loadItems(of list: TodoList, with request: NSFetchRequest<TodoListItem> = TodoListItem.fetchRequest()) -> [TodoListItem]{
        
        let predicate = NSPredicate(format: "list.name MATCHES %@", list.name!)
        
        if let additionalPredicate = request.predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, additionalPredicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = predicate
        }
        
        var items = [TodoListItem]()
        do {
            items = try context.fetch(request)
        } catch {
            print("Error loading items of list '\(list.name!)' from context \(error)")
        }
        
        return items
    }
}
