//
//  GRItemCell.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class GroceryItemCell: UITableViewCell, ViewModelAvailable{
  
  typealias VM = GroceryItemVMType
  
  fileprivate var disposeBag:DisposeBag! = DisposeBag()
  
  weak var viewModel:VM? {
    didSet {
      guard let vm = viewModel else {
        return
      }
      disposeBag = DisposeBag()
    
      vm.title.drive(nameLab.rx.text).disposed(by: disposeBag)
      vm.completed.drive(checkBut.driveChecked).disposed(by: disposeBag)
      checkBut.updateCompleted.bind(to: vm.updateCompleted).disposed(by: disposeBag)
    }
  }
  
  @IBOutlet weak var checkBut: CheckButton!
  @IBOutlet weak var nameLab: UILabel!

  override func prepareForReuse()
  {
    super.prepareForReuse()

    disposeBag = DisposeBag()    
  }

}
