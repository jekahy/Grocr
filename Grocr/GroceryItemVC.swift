//
//  GroceryItemVC.swift
//  Grocr
//
//  Created by Eugene on 30.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import ImagePicker
import FirebaseStorage
import FirebaseStorageUI
import DownloadButton

class GroceryItemVC: UIViewController {

  @IBOutlet weak var titleLab: UILabel!
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var imgUploadBut: PKDownloadButton!
  @IBOutlet weak var amountLab: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var detailView: UIView!
  
  @IBOutlet var imgConstrNormal: [NSLayoutConstraint]!
  @IBOutlet var imgContsrExpanded: [NSLayoutConstraint]!

  @IBOutlet weak var descriptionHeighConstr: NSLayoutConstraint!
  @IBOutlet weak var  imgHeightConstr: NSLayoutConstraint!
  
  fileprivate var isEditMode = false
  fileprivate let storageRef = Storage.storage().reference().child("grocery-items-images")
  
  fileprivate var uploadTask:StorageUploadTask?{
    didSet{
      imgUploadBut.state = .downloading
      uploadTask?.observe(.progress) {[unowned self] snapshot in
        if let progress = snapshot.progress?.fractionCompleted {
          self.imgUploadBut.stopDownloadButton.progress = CGFloat(progress)
        }
      }
      
      uploadTask?.observe(.failure){[unowned self] snapshot in
        self.imgUploadBut.state = .startDownload
        
      }
    }
  }
  
  
  var item:GroceryItem!
 
//  MARK: VC lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    setupDownloadButton(imgUploadBut)
    setupImgViewGR(imgView: imgView)
    setupEditBut()
  }
  
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    updateImgViewConstraint(forImage: .placeholderImage)
    fillDataFrom(item)
    updateTextViewContraint(descriptionTextView)
    
  }
  
//  MARK: Methods
  fileprivate func setupDownloadButton(_ but:PKDownloadButton)
  {
    
    but.stopDownloadButton.tintColor = UIColor.blue
    but.stopDownloadButton.filledLineStyleOuter = true
    but.stopDownloadButton.filledLineWidth = 3
    
    
    but.startDownloadButton.cleanDefaultAppearance()
    but.startDownloadButton.backgroundColor = UIColor.clear
    but.startDownloadButton.setImage(UIImage(named: "plus"), for: .normal)
    
    but.state = .startDownload
    but.delegate = self
  }
  
  fileprivate func setupImgViewGR(imgView:UIImageView)
  {
    let tapGR = UITapGestureRecognizer(target: self, action: #selector(toggleImage))
    imgView.addGestureRecognizer(tapGR)
  }
  
  fileprivate func setupEditBut()
  {
    let editBut = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action:  #selector(editTapped))
    
    navigationItem.rightBarButtonItem = editBut
  }
  
  fileprivate func fillDataFrom(_ model:GroceryItem)
  {
    titleLab.text = model.name
    //    descriptionTextView.text = model.description
    amountLab.text = model.amount
    imgView.sd_setImage(with: item.titleImageURL, placeholderImage: .placeholderImage, options:[.progressiveDownload])
    { [weak self] img,err,_,_ in
      if let img = img{
        self?.updateImgViewConstraint(forImage: img)
      }
    }

  }

  
  fileprivate func updateImgViewConstraint(forImage image:UIImage)
  {
    imgView.layoutIfNeeded()
    let aRatio = image.size.width/image.size.height
    imgHeightConstr.constant = self.view.frame.size.width/aRatio
  }
  
  fileprivate func updateTextViewContraint(_ textView:UITextView)
  {
    textView.layoutIfNeeded()
    descriptionHeighConstr.constant = textView.contentSize.height
  }
  
  fileprivate func updateRightBarBut()
  {
    let type:UIBarButtonSystemItem = isEditMode ? .save : .edit
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: type, target: self, action:  #selector(editTapped))
    
  }
  
  @objc fileprivate func toggleImage()
  {
    let shouldExpand = imgConstrNormal[0].isActive
    if shouldExpand{
      NSLayoutConstraint.deactivate(imgConstrNormal)
      NSLayoutConstraint.activate(imgContsrExpanded)
    }else{
      NSLayoutConstraint.deactivate(imgContsrExpanded)
      NSLayoutConstraint.activate(imgConstrNormal)
    }
    UIView.animate(withDuration: 0.25, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    self.toggleShadowOfDetailView(!shouldExpand)
  }
  
  
  fileprivate func toggleShadowOfDetailView(_ show:Bool){
    
    CATransaction.begin()
    
    let anim = CABasicAnimation(keyPath: "shadowOpacity")
    var start = 0.0
    var end = 0.5
    if !show{
      start = 0.5
      end = 0.0
    }
    anim.fromValue = start
    anim.toValue = end
    anim.duration = 0.25
    
    CATransaction.setCompletionBlock { [weak self] in
      self?.detailView.layer.shadowOpacity = Float(end)
    }
    detailView.layer.add(anim, forKey: "shadowOpacity")
    
    CATransaction.commit()
    
  }
  
  @objc fileprivate func editTapped()
  {
    isEditMode = !isEditMode
    updateRightBarBut()
    imgUploadBut.isHidden = !isEditMode
    
  }
  
  
  fileprivate func uploadImage(_ image:UIImage)
  {
    let imgItemRef = item.ref.child("imageID")
    
    let imgID = imgItemRef.childByAutoId().key
    let imgStoreRef = storageRef.child(imgID + ".png")
    
    guard let png = UIImagePNGRepresentation(image) else{
      return
    }
    uploadTask = imgStoreRef.putData(png, metadata: nil) { [weak self](metadata, error) in
      guard let metadata = metadata else {
        return
      }
      // Metadata contains file metadata such as size, content-type, and download URL.
      if let downloadURL = metadata.downloadURL(){
        
        imgItemRef.setValue(downloadURL.absoluteString)
      }
      self?.imgView.image = image
      self?.imgUploadBut.state = .startDownload
      self?.imgUploadBut.isHidden = true
    }
    
  }
  
  fileprivate func showImagePickerVC()
  {
    let imagePickerController = ImagePickerController()
    imagePickerController.imageLimit = 1
    imagePickerController.delegate = self
    
    present(imagePickerController, animated: true, completion: nil)
  }

  
//  MARK: IBActions
  @IBAction func addImgTapped(_ sender: Any)
  {
    let imagePickerController = ImagePickerController()
    imagePickerController.delegate = self
    present(imagePickerController, animated: true, completion: nil)
  }
  
}


extension GroceryItemVC:ImagePickerDelegate {
  
  func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage])
  {
    
  }
  
  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage])
  {
    guard let img = images.first else {
      return
    }
    self.uploadImage(img)
    imagePicker.dismiss(animated: true, completion: nil)
  }
  
  func cancelButtonDidPress(_ imagePicker: ImagePickerController)
  {
    imagePicker.dismiss(animated: true, completion: nil)
  }
  
}


extension GroceryItemVC:PKDownloadButtonDelegate {
  
  func downloadButtonTapped(_ downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState)
  {
    switch state {
    case .pending:
      break
    case .startDownload:
      showImagePickerVC()
      break
    case .downloading:
      uploadTask?.cancel()
      break
    case .downloaded:
      break
    }
  }
}
