//
//  GRListVC.swift
//  Grocr
//
//  Created by Eugene on 29.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GroceryListVC:UIViewController {

  fileprivate let cellIdentifier = "listCell"
  fileprivate let viewModel:GroceryListType = GroceryListVM(api: APIManager())
  fileprivate var disposeBag:DisposeBag! = DisposeBag()
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    navigationItem.title = "Groceries"
    
    viewModel.groceryVMs.bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: GroceryCell.self)) { (index, groceryModel: GroceryVMType, cell) in
      cell.viewModel = groceryModel
      }.addDisposableTo(disposeBag)
    
    tableView.rx.modelSelected(GroceryVMType.self).asDriver().drive(onNext: { [weak self] groceryVM in
      
      if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
        self?.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
      }
      self?.perform(.showGroceryVC) { destVC in
        destVC.inject(groceryVM)
      }
      
    }).disposed(by: disposeBag)
    
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
  }
  
  //MARK: IBActions
  @IBAction func addTapped(_ sender: Any)
  {
    let alert = UIAlertController(title: "Grocery list",
                                  message: "Add a new list",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
      
      guard let textField = alert.textFields?.first,
          let text = textField.text else { return }
      
      self?.viewModel.addGrocery(text)
    }
    
    alert.addTextField()
    alert.addAction(saveAction)
    alert.addAction(.cancel)
  
    present(alert, animated: true, completion: nil)
  }

}

extension GroceryListVC:UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let deleteAction = UITableViewRowAction(style: .destructive, title: "Remove") {
      [weak self] _, indexPath in
      
      if let groceryVM:GroceryVMType = try? tableView.rx.model(at: indexPath){
        self?.viewModel.removeGrocery(groceryVM)
      }
    }
    return [deleteAction]
  }
}
