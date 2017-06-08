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

import RxSwift
import RxCocoa

class GroceryVC: UIViewController {
  
  // MARK: Constants
  fileprivate let ref = Database.database().reference(withPath: "grocery-items")
  fileprivate let toGroceryItemVC = "toGroceryItemVC"
  fileprivate let cellIdentifier = "itemCell"
  // MARK: Properties
  var groceryID:String!{
    didSet{
      self.viewModel = GroceryVM(self.groceryID)
    }
  }
  
  fileprivate var viewModel:GroceryVMType!
  fileprivate var disposeBag:DisposeBag! = DisposeBag()

  @IBOutlet weak var tableView: UITableView!

  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    tableView.allowsMultipleSelectionDuringEditing = false
    
    viewModel.itemVMs.bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: GroceryItemCell.self)){
      (index, groceryItemModel, cell) in
      
      cell.viewModel = groceryItemModel

      
    }.disposed(by: disposeBag)
    
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
          self.viewModel.addItem(text)
    }
    
    alert.addTextField()
    alert.addAction(saveAction)
    alert.addAction(.cancel)
    
    present(alert, animated: true, completion: nil)
  }
  
//  MARK: Prepare for segue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if segue.identifier == toGroceryItemVC, let itemVC = segue.destination as? GroceryItemVC, let item = sender as? GroceryItem {
      itemVC.item = item
    }
  }
 
  deinit {
    disposeBag = nil
  }
}

