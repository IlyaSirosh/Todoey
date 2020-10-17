//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Illya Sirosh on 10.10.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let dataService = DataService.instance
    var list: TodoList! {
        didSet{
            items = dataService.getItems(of: list)
        }
    }
    var items: [TodoListItem] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = list.name!
        
        searchBar.delegate = self
    }
    
    //MARK: - DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        
        return cell
    }
    
    func updateCheckMark(_ cell: UITableViewCell, isChecked: Bool){
        cell.accessoryType = isChecked ? .checkmark : .none
    }
    
    //MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.done = !item.done
        
        dataService.update(item)
        self.tableView.reloadData()
        if let cell = tableView.cellForRow(at: indexPath) {
            updateCheckMark(cell, isChecked: item.done)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add item
    
    @IBAction func onAddItemPressed(_ sender: UIBarButtonItem) {
        
        var alertTextField = UITextField()
        let alertController = UIAlertController(title: "Add new item to \(list.name!)", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let item = alertTextField.text {
                let savedItem = self.dataService.add(to: self.list, itemTitle: item)
                self.items.append(savedItem)
                self.tableView.reloadData()
            }
        }
        
        alertController.addAction(alertAction)
        alertController.addTextField { (textField) in
            textField.placeholder = "Type what you want to do"
            alertTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension TodoListViewController: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        items = dataService.getItems(of: list, thatContain: searchBar.text)
        tableView.reloadData()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        items = dataService.getItems(of: list, thatContain: searchText)

        if searchText.isEmpty {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
        tableView.reloadData()
    }
}
