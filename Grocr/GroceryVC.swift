/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import FirebaseDatabase
import FirebaseAuth

class GroceryVC: UITableViewController {
  
  // MARK: Constants
  fileprivate let ref = Database.database().reference(withPath: "grocery-items")
  
  // MARK: Properties
  var grocery:Grocery!
  var items: [GroceryItem] = []

  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    tableView.allowsMultipleSelectionDuringEditing = false
    
    ref.observe(.value, with: {[weak self] snapshot in
      
      self?.items = snapshot.children.flatMap{GroceryItem(snapshot: $0 as! DataSnapshot)}
      self?.tableView.reloadData()
      
    })
  }
  
  // MARK: Add Item
  
  @IBAction func addButtonDidTouch(_ sender: AnyObject)
  {
    let alert = UIAlertController(title: "Grocery Item",
                                  message: "Add an Item",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { [unowned self] _ in
        guard let textField = alert.textFields?.first,
          let text = textField.text else { return }
        
        let groceryItemRef = self.ref.childByAutoId()

        let groceryItem = GroceryItem(name: text,
                                      addedByUser: Auth.auth().currentUser?.email,
                                      groceryID:self.grocery.key,
                                      ref: groceryItemRef)
        
        groceryItemRef.setValue(groceryItem.jsonStr)
        let itemsRef = self.grocery.ref.child("items")
        itemsRef.updateChildValues([groceryItem.key : true])
    }
    
    alert.addTextField()
    alert.addAction(saveAction)
    alert.addAction(.cancel)
    
    present(alert, animated: true, completion: nil)
  }
  
}


extension GroceryVC {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
    let groceryItem = items[indexPath.row]
    
    cell.textLabel?.text = groceryItem.name
    cell.detailTextLabel?.text = groceryItem.addedByUser
    
    toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == .delete {
      let groceryItem = items[indexPath.row]
      groceryItem.ref?.removeValue()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let groceryItem = items[indexPath.row]
    let toggledCompletion = !groceryItem.completed
    
    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
    
    groceryItem.ref?.updateChildValues([
      "completed": toggledCompletion
      ])
  }
  
  fileprivate func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool)
  {
    if !isCompleted {
      cell.accessoryType = .none
      cell.textLabel?.textColor = UIColor.black
      cell.detailTextLabel?.textColor = UIColor.black
    } else {
      cell.accessoryType = .checkmark
      cell.textLabel?.textColor = UIColor.gray
      cell.detailTextLabel?.textColor = UIColor.gray
    }
  }
}

