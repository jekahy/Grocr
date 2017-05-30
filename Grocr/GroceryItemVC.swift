//
//  GroceryItemVC.swift
//  Grocr
//
//  Created by Eugene on 30.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class GroceryItemVC: UIViewController {

  @IBOutlet weak var titleLab: UILabel!
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var amountLab: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var detailView: UIView!
  
  @IBOutlet var imgConstrNormal: [NSLayoutConstraint]!
  @IBOutlet var imgContsrExpanded: [NSLayoutConstraint]!

  @IBOutlet weak var descriptionHeighConstr: NSLayoutConstraint!
  @IBOutlet weak var  imgHeightConstr: NSLayoutConstraint!
  var item:GroceryItem!
 
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    titleLab.text = item.name
//    descriptionTextView.text = item.description
    amountLab.text = item.amount

    descriptionTextView.layoutIfNeeded()
    descriptionHeighConstr.constant = descriptionTextView.contentSize.height
    
    if let img = imgView.image {
      imgView.layoutIfNeeded()
      let aRatio = img.size.width/img.size.height
      imgHeightConstr.constant = self.view.frame.size.width/aRatio
      
    }
    
    let tapGR = UITapGestureRecognizer(target: self, action: #selector(toggleImage))
    imgView.addGestureRecognizer(tapGR)
    
  }
  
  @objc fileprivate func toggleImage()
  {
    let shouldExpand = imgConstrNormal[0].isActive
    if shouldExpand{
      NSLayoutConstraint.deactivate(imgConstrNormal)
      NSLayoutConstraint.activate(imgContsrExpanded)
    }else{
      NSLayoutConstraint.deactivate(self.imgContsrExpanded)
      NSLayoutConstraint.activate(self.imgConstrNormal)
    }
    UIView.animate(withDuration: 0.25, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    self.toggleShadowOfDetailView(!shouldExpand)
  }
  
  
  fileprivate func toggleShadowOfDetailView(_ show:Bool){
    
    CATransaction.begin()
    
    let anim = CABasicAnimation(keyPath: "shadowOpacity")
    var start:Float = 0.0
    var end:Float = 0.5
    if !show{
      start = 0.5
      end = 0.0
    }
    anim.fromValue = start
    anim.toValue = end
    anim.duration = 0.25
    
    CATransaction.setCompletionBlock { [weak self] in
      self?.detailView.layer.shadowOpacity = end
    }
    detailView.layer.add(anim, forKey: "shadowOpacity")
    
    CATransaction.commit()
    
  }

}
