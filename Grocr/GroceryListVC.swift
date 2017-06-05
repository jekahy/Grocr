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
  fileprivate let toGRVCSegueID = "toGRListVC"
  fileprivate let viewModel:GroceryListType = GroceryListVM()
  fileprivate let disposeBag = DisposeBag()
  
  @IBOutlet weak var tableView: UITableView!
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    viewModel.groceryVMs.bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: GroceryCell.self)) { (index, groceryModel: GroceryListItemVMType, cell) in
      cell.groceryVM = groceryModel
      }.addDisposableTo(disposeBag)
    
    tableView.rx.modelSelected(GroceryListItemVMType.self).asDriver().drive(onNext: { [weak self] itemVM in
      
      if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
        self?.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
      }
      if let segId = self?.toGRVCSegueID {
        self?.performSegue(withIdentifier:segId , sender: itemVM)
      }
    }).disposed(by: disposeBag)
    
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
  
//  MARK: Prepare for segue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let listVC = segue.destination as? GroceryVC, let item = sender as? GroceryListItemVM {
      listVC.groceryID = item.groceryID
    }
  }
}

