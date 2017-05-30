//
//  GRListVC.swift
//  Grocr
//
//  Created by Eugene on 29.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import ObjectMapper

class GroceryListVC: UITableViewController {

  fileprivate let ref = Database.database().reference(withPath: "grocery-lists")
  fileprivate let cellIdentifier = "listCell"
  fileprivate let toGRVCSegueID = "toGRListVC"
  fileprivate var listItems = [Grocery]()
    override func viewDidLoad()
    {
      super.viewDidLoad()

      let dataChangeClosure:(DataSnapshot)->() = {[weak self] snapshot in
        
        let ls = snapshot.children.flatMap({Grocery(snapshot: $0 as! DataSnapshot)})
        self?.listItems = ls
        self?.tableView.reloadData()
      }
      
      ref.observe(.value, with: dataChangeClosure)
    }
  
  //MARK: IBActions
  @IBAction func addTapped(_ sender: Any)
  {
    let alert = UIAlertController(title: "Grocery list",
                                  message: "Add a new list",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
      
      guard let textField = alert.textFields?.first,
          let text = textField.text else { return }
      
      let grListRef = self.ref.childByAutoId()
      
      let grList = Grocery(name: text, ref: grListRef)
      grListRef.setValue(grList.jsonStr)

    }
    
    alert.addTextField()
    
    alert.addAction(saveAction)
    alert.addAction(.cancel)
    
    present(alert, animated: true, completion: nil)
  }
  
//  MARK: Prepare for segue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let listVC = segue.destination as? GroceryVC, let item = sender as? Grocery {
      listVC.grocery = item
    }
  }
}

extension GroceryListVC {
  
  override func numberOfSections(in tableView: UITableView) -> Int
  {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return listItems.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    UITableViewCell
  {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GRListsCell else{
      return UITableViewCell()
    }
    let item = listItems[indexPath.row]
    cell.configure(item)
    return cell
  }

  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    tableView.deselectRow(at: indexPath, animated: true)
    let item = listItems[indexPath.row]
    performSegue(withIdentifier: toGRVCSegueID, sender: item)
  }
}

