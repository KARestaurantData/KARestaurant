//
//  EditRestaurantTableViewController.swift
//  KARestaurant
//
//  Created by Kokpheng on 5/27/16.
//  Copyright © 2016 KARestaurant. All rights reserved.
//

import UIKit
import PhotosUI
import BSImagePicker
import AssetsLibrary

class EditRestaurantTableViewController: UITableViewController,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UICollectionViewDelegate,UICollectionViewDataSource {
    
    // MARK: Properties
    
    @IBOutlet weak var menuSelectedLabel: UILabel!
    @IBOutlet weak var browseButton:UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var imgarray = [UIImage]()
    let rest  = ["KFC","KOI","KOI","KFC"]
    let images = [UIImage (named: "meal2.png"),UIImage (named: "meal3.png"),UIImage (named: "meal3.png"),UIImage (named: "meal3.png")]
    /*
     This value is either passed by `RestaurantTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new meal.
     */
    var meal: Restaurant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate=self
        self.collectionView.dataSource=self
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            photoImageView.image = meal.photo
            //            ratingControl.rating = meal.rating
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidMealName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Navigation
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            //            let rating = ratingControl.rating
            
            // Set the meal to be passed to MealListTableViewController after the unwind segue.
            meal = Restaurant(name: name, photo: photo, rating: 0)
            print("saved!")
        }
    }
    
    //MARK: PHasset
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.defaultManager()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.synchronous = true
        manager.requestImageForAsset(asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .AspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    
    // MARK: Actions
    @IBAction func showImagePicker(sender: UITapGestureRecognizer) {
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 6
        
        bs_presentImagePickerController(vc, animated: true,
                                        select: { (asset: PHAsset) -> Void in
                                            print("Selected image:\(asset)")
                                            self.photoImageView.image = self.getAssetThumbnail(asset)
                                            self.imgarray.append(self.getAssetThumbnail(asset))
                                            print(self.imgarray.count)
                                            
                                            
                                            self.collectionView.reloadData()
                                            
            }, deselect: { (asset: PHAsset) -> Void in
                print("Deselected: \(asset)")
            }, cancel: { (assets: [PHAsset]) -> Void in
                print("Cancel: \(assets)")
            }, finish: { (assets: [PHAsset]) -> Void in
                print("Finish: \(assets)")
                
                
            }, completion:nil)
    }
    
    
    func reloadTable(){
        self.collectionView.reloadData()
        
        
    }
    
    //MARK: collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgarray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier("imgcell", forIndexPath: indexPath) as! CustomCell
        cell.myImage.image=self.imgarray[indexPath.row]
        return cell
        
        
        
    }
    
    //MARK: UITableViewDelegate
    //    override func tableView(tableView: UITableView,
    //                            numberOfRowsInSection section: Int) -> Int {
    //        return imgarray.count
    //    }
    //
    //    override func tableView(tableView: UITableView,
    //                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //
    //        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
    //                                                               forIndexPath: indexPath)
    //
    //        return cell
    //    }
    //    override func tableView(tableView: UITableView,
    //                            willDisplayCell cell: UITableViewCell,
    //                                            forRowAtIndexPath indexPath: NSIndexPath) {
    //
    //        guard let tableViewCell = cell as? CustomTableViewCell else { return }
    //
    //        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    //    }
    
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    //MARK: delete action
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.imgarray.removeAtIndex(indexPath.row)
        self.collectionView.deleteItemsAtIndexPaths([indexPath])
        self.collectionView.reloadData()
        
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        
        
    }
    
}

