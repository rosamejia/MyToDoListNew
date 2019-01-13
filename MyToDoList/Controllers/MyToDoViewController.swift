//
//  ViewController.swift
//  MyToDoList
//
//  Created by Rosa Mejia on 1/4/19.
//  Copyright © 2019 Rosa Mejia. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class MyToDoViewController: SwipeTableViewController {
    //Results is a realm Result
    var todoItems: Results<Item>?
    let realm = try!Realm()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    var defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
    }

    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let hexColor = selectedCategory?.backgroundColor else {fatalError()}
        UpdateNavBar(withHexCode: hexColor)
//        if let hexColor = selectedCategory?.backgroundColor {
//            title = selectedCategory!.name
//            guard let navBar = navigationController?.navigationBar else {
//                fatalError("Navigation controller does not exists.")
//            }
//            if let navBarColor = UIColor(hexString: hexColor){
//                navBar.barTintColor = navBarColor
//                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
//                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
//                searchBar.barTintColor = navBarColor
//            }
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UpdateNavBar(withHexCode: "34495E")
    }
    
    //MARK: Nav Bar Setup
    func UpdateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exists.")
        }
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    //MARK table view source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            let categoryColor = UIColor.init(hexString: (selectedCategory?.backgroundColor)!)
            if let color = categoryColor?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                print(CGFloat(indexPath.row) / CGFloat(todoItems!.count))
                }
        
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Found"
        }
        
        return cell
    }
    
    
    //MARK table view delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("selected row" + itemArray[indexPath.row])
        
        if let item = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch{
                    print("Error saving done status, \(error)")
                }
            }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Item?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory{
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("error adding item, \(error)")
                }
            }
            self.tableView.reloadData()
        }
            //self.defaults.set(self.itemArray, forKey: "MyToDoListArray")
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
//                    item.done = !item.done
                }
            } catch{
                print("Error saving done status, \(error)")
            }
        }
    }
}
    
//MARK: - Search bar methods
extension MyToDoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

