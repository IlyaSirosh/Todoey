//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Illya Sirosh on 10.10.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: SwipeTableViewController {
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
        
        searchBar.delegate = self
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Nav bar is nil")
        }
        
        navigationItem.title = list.name
        navigationItem.largeTitleDisplayMode = .never
        
        if let backgroundColor = UIColor(hexString: list.backgroundColor){
            let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: backgroundColor, isFlat: true)
            
            navBar.barTintColor = backgroundColor
            navBar.tintColor = contrastColor
            let attributes = [ NSAttributedString.Key.foregroundColor:  contrastColor]
            navBar.titleTextAttributes = attributes
            navBar.largeTitleTextAttributes = attributes
            searchBar.barTintColor = backgroundColor
            searchBar.tintColor = contrastColor
//            searchBar.backgroundColor = contrastColor
            tableView.tintColor = contrastColor
        }
        
    
    }
    
    //MARK: - DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        let darkPower: CGFloat = CGFloat(indexPath.row) / CGFloat(items.count)
        if let basicColor = UIColor(hexString: list.backgroundColor),
           let backgroundColor = basicColor.darken(byPercentage: darkPower) {
            cell.backgroundColor = backgroundColor
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: backgroundColor, isFlat: true)
        }

        
        updateCheckMark(cell, isChecked: item.done)
        
        
        return cell
    }
    
    func updateCheckMark(_ cell: UITableViewCell, isChecked: Bool){
        cell.accessoryType = isChecked ? .checkmark : .none
    }
    
    //MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        dataService.toggle(item)
        if let cell = tableView.cellForRow(at: indexPath) {
            updateCheckMark(cell, isChecked: item.done)
        }
        self.tableView.reloadData()
        
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

extension TodoListViewController: SwipeTableViewControllerDelegate {
    func swipeTableView(_ tableView: UITableView, deleteCellAtRow indexPath: IndexPath) {
        let item = items[indexPath.row]
        items.remove(at: indexPath.row)
        dataService.deleteItem(item)
    }
    
    
}
