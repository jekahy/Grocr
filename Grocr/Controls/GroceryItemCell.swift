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

class GroceryItemCell: UITableViewCell {
  
  fileprivate var disposeBag = DisposeBag()
  var viewModel:GroceryItemVMType!{
    didSet {
      guard let vm = viewModel else {
        return
      
      }
      vm.title.drive(nameLab.rx.text).disposed(by: disposeBag)
      vm.completed.drive(checkBut.driveChecked).disposed(by: disposeBag)
      checkBut.updateCompleted.bind(to: vm.updateCompleted).disposed(by: disposeBag)
    }
  }
  
  @IBOutlet weak var checkBut: CheckButton!
  @IBOutlet weak var nameLab: UILabel!

  override func prepareForReuse()
  {
    disposeBag = DisposeBag()
  }
}
