//
//  NewPostViewController.swift
//  Rant App
//
//  Created by block7 on 3/1/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit
import CoreLocation

class NewPostViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    
    let backendless = Backendless.sharedInstance()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var id = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    let locationManager = CLLocationManager()
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    @IBOutlet weak var RantTextView: UITextView!
    
    @IBOutlet weak var TagTextField: UITextField!
    
    @IBOutlet weak var ColorPickerView: UIPickerView!
    
    @IBOutlet weak var PostButton: UIButton!
    let red = UIColor.redColor()
    let purple = UIColor.purpleColor()
    let black = UIColor.blackColor()
    let brown = UIColor.brownColor()
    let blue = UIColor.blueColor()
    let green = UIColor.greenColor()
    let yellow = UIColor.yellowColor()
    let orange = UIColor.orangeColor()
    
    let pickerData = ["black", "red", "purple", "brown", "blue", "green", "yellow", "orange"]
    
    var color = "black"
    var uicolor: UIColor!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let borderColor: UIColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        RantTextView.layer.borderColor = borderColor.CGColor
        RantTextView.layer.borderWidth = 1.0
        RantTextView.layer.cornerRadius = 5.0
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.locationManager.requestAlwaysAuthorization()
        
        RantTextView?.delegate = self
        RantTextView.textColor = UIColor.lightGrayColor()
        
        RantTextView.contentInset = UIEdgeInsetsMake(-50.0,0.0,0,0.0)
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        ColorPickerView.delegate = self
        ColorPickerView.dataSource = self
        

    }
    func dismissKeyboard(){
        view.endEditing(true)
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        latitude = locValue.latitude
        longitude = locValue.longitude
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func PostButtonClicked(sender: AnyObject) {
        let postText = RantTextView.text
        let tagText = TagTextField.text
        let tagArray = tagText!.componentsSeparatedByString(" ")
        //add tags code, save tags by postid
        let posts = Posts()
        posts.post = postText
        posts.id = id
        posts.likes = "0"
        posts.color = color
        
        let geoPoint = GeoPoint.geoPoint(GEO_POINT(latitude: latitude, longitude: longitude)) as! GeoPoint
        posts.coordinates = geoPoint
        
        
        let dataStore = backendless.data.of(Posts.ofClass())
        
        var error: Fault?
        let result = dataStore.save(posts, fault: &error) as? Posts
        let postid = result!.objectId
        if error == nil {
            print("Post has been saved: \(result!.objectId)")
        }
        else {
            print("Server reported an error: \(error)")
        }
        
        let tags = Tags()
        let st = SavedTags()
        for x in tagArray{
            tags.postid = postid
            tags.tag = x
            st.tag = x
            let storeTags = backendless.data.of(Tags.ofClass())
            
            var err: Fault?
            let finish = storeTags.save(tags, fault: &err) as? Tags
            if err == nil {
                print("Tag saved: \(finish!.objectId)")
            }
            else {
                print("server reported an error: \(err)")
            }
            
            checkTagAndSave(x)
        }

    }
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        color = pickerData[row]
        if color == "red"{
            uicolor = red
        } else if color == "blue"{
            uicolor = blue
        } else if color == "brown"{
            uicolor = brown
        } else if color == "black"{
            uicolor = black
        } else if color == "purple"{
            uicolor = purple
        } else if color == "green"{
            uicolor = green
        } else if color == "yellow"{
            uicolor = yellow
        } else if color == "orange"{
            uicolor = orange
        }
        RantTextView.textColor = uicolor

    }
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor(){
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    func checkTagAndSave(tagCheck: String!){
        let wc = "tag = '\(tagCheck)'"
        let dq = BackendlessDataQuery()
        dq.whereClause = wc
        let tagForCheck = self.backendless.persistenceService.of(SavedTags.ofClass()).find(dq)
        let cp = tagForCheck.getCurrentPage()
        for tag in cp as! [SavedTags]{
            if tag.tag == nil || tag.tag == ""{
                let saveTags = backendless.data.of(SavedTags.ofClass())
                var error: Fault?
                let isDone = saveTags.save(tag.tag, fault: &error) as? SavedTags
                if error == nil{
                    print("Tag saved: \(isDone!.objectId)")
                }
                else{
                    print("Error: \(error)")
                }
            }
            else{
                print("Tag already exists: \(tag.objectId)")
            }
        }
    }

}
