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
            loadData()
        }
    }
    var items: [TodoListItem] = []
    var searchString: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = list.name
        
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
        
        dataService.toggle(item)
        self.tableView.reloadData()
        if let cell = tableView.cellForRow(at: indexPath) {
            updateCheckMark(cell, isChecked: item.done)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add item
    
    @IBAction func onAddItemPressed(_ sender: UIBarButtonItem) {
        
        var alertTextField = UITextField()
        let alertController = UIAlertController(title: "Add new item to \(list.name)", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let item = alertTextField.text {
                self.dataService.add(to: self.list, itemTitle: item)
                self.loadData()
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
    
    private func loadData(){
        items = dataService.getItems(of: list, thatContain: searchString)
        tableView.reloadData()
    }
    
}

extension TodoListViewController: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchString = searchBar.text
        loadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        
        if searchText.isEmpty {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
        loadData()
    }
}
