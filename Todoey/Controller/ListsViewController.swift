//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class ListsViewController: SwipeTableViewController {
    
    let dataService: DataService = DataService.instance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem()
        barButton.title = ""
        navigationItem.backBarButtonItem = barButton
        
        view.backgroundColor = UIColor(named: "mainColor")
        
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar, let navItem = navigationController?.navigationItem else {
            fatalError("No navbar for lists controller")
        }
        
        let color = UIColor(named: "mainColor")!
        let contrast = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        
        let attributes = [ NSAttributedString.Key.foregroundColor:  contrast]
        navBar.titleTextAttributes = attributes
        navBar.largeTitleTextAttributes = attributes
        
        navBar.backgroundColor = color
        navBar.barTintColor = color
        
        navBar.prefersLargeTitles = true
        
        navItem.largeTitleDisplayMode = .always
    }
    
    //MARK: - DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataService.getLists().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let list = dataService.getLists()[indexPath.row]
        cell.textLabel?.text = list.name
        cell.backgroundColor = UIColor(hexString: list.backgroundColor)
        
        return cell
    }
    
    //MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = dataService.getLists()[indexPath.row]
        performSegue(withIdentifier: "TodoListDetails", sender: list)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TodoListViewController, let list = sender as? TodoList {
            vc.list = list
        }
    }
    
    
    //MARK: - Add new lists
    
    @IBAction func onAddNewTodoListPressed(_ sender: UIBarButtonItem) {
        
        
        var alertTextField: UITextField?
        let alertController = UIAlertController(title: "Add new Todo list", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add list", style: .default) { (alert) in
            if let listName = alertTextField?.text {
                self.dataService.addList(with: listName)
                self.tableView.reloadData()
            }
        }
        alertController.addAction(alertAction)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "New list name"
            alertTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
    
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ListsViewController: SwipeTableViewControllerDelegate {
    
    func swipeTableView(_ tableView: UITableView, deleteCellAtRow indexPath: IndexPath) {
        let list = dataService.getLists()[indexPath.row]
        dataService.deleteList(list)
    }
}
