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
import RxCocoa
import RxSwift

class GroceryItemVC: UIViewController, EasyAlert {

  @IBOutlet weak var titleLab: EditableLabel!
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var imgUploadBut: PKDownloadButton!
  @IBOutlet weak var amountLab: EditableLabel!
  @IBOutlet weak var descriptionTextView: TextView!
  @IBOutlet weak var detailView: UIView!
  
  @IBOutlet var imgConstrNormal: [NSLayoutConstraint]!
  @IBOutlet var imgContsrExpanded: [NSLayoutConstraint]!

  @IBOutlet weak var descriptionHeighConstr: NSLayoutConstraint!
  @IBOutlet weak var  imgHeightConstr: NSLayoutConstraint!
  
  fileprivate var isEditMode = false
  
  fileprivate let disposeBag = DisposeBag()
  
  fileprivate let uploadImgSubj = PublishSubject<UIImage>()
  
  var viewModel:GroceryItemVM!
 
//  MARK: VC lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    setupDownloadButton(imgUploadBut)
    setupImgViewGR(imgView: imgView)
    setupEditBut()
    
    viewModel.title.drive(titleLab.rx.texttt).disposed(by: disposeBag)
    viewModel.amount.drive(amountLab.rx.texttt).disposed(by: disposeBag)
    viewModel.description.drive(descriptionTextView.rx.text).disposed(by: disposeBag)
    
    let tapGR = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
    detailView.addGestureRecognizer(tapGR)
    
    titleLab.textInput.subscribe{ t in
      
    }.disposed(by: disposeBag)
    
    viewModel.imgURL.drive(onNext: { [weak self] imgURL in
      
      self?.imgView.sd_setImage(with: imgURL, placeholderImage: .placeholderImage, options:[.progressiveDownload])
      { [weak self] img,err,_,_ in
        if let img = img{
          self?.updateImgViewConstraint(forImage: img)
        }
      }
      
    }).disposed(by: disposeBag)
    

  }
  
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    updateImgViewConstraint(forImage: .placeholderImage)
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
    
    if isEditMode {
        bindEditingStaff()
        titleLab.enableEditMode()
        amountLab.enableEditMode()
        descriptionTextView.enableEditMode()
      
    }else{
        viewModel.saveEditedData()
        view.endEditing(true)
        titleLab.disableEditMode()
        amountLab.disableEditMode()
        descriptionTextView.disableEditMode()
    }
    
  }
  
  fileprivate func bindEditingStaff()
  {
    
    let uploadImgProgressObservable = viewModel.startEditing(title: titleLab.textInput, amount: amountLab.textInput, description: descriptionTextView.rx.text.asObservable(), imageUploadEvent: uploadImgSubj.asObservable())
    
    uploadImgProgressObservable.subscribe(onNext: { progress in
      
        self.imgUploadBut.stopDownloadButton.progress = CGFloat(progress)
      
      }, onError: { error in
        
        self.imgView.image = UIImage.placeholderImage
        self.imgUploadBut.state = .startDownload
        var mess = "Failed to upload image."
        if case ImageUploadError.failedWithMessage(let errorMess) = error{
          mess += " The error is: \(errorMess)"
        }
        self.showAlert("Warning", message: mess, alertActions: [.ok])
        
      }, onCompleted: {
        
        self.imgUploadBut.state = .startDownload
        
    }).disposed(by: disposeBag)

  }
  
  
  fileprivate func uploadImage(_ image:UIImage)
  {
    uploadImgSubj.onNext(image)
    imgView.image = image
    imgUploadBut.state = .downloading
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
      
      case .startDownload:
        showImagePickerVC()
        
      case .downloading:
        uploadImgSubj.onError(ImageUploadError.cancelled)
        downloadButton.state = .startDownload
        imgView.image = UIImage.placeholderImage
      
      default:
        break
    }
  }
}
