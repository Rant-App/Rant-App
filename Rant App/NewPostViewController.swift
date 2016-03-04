//
//  NewPostViewController.swift
//  Rant App
//
//  Created by block7 on 3/1/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit
import CoreLocation

class NewPostViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
    
    var color = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.locationManager.requestAlwaysAuthorization()
        
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
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
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
        let tagArray = tagText!.componentsSeparatedByString(" @")
        //add tags code, save tags by postid
        let posts = Posts()
        posts.post = postText
        posts.id = id
        posts.likes = "0"
        posts.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        
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
        for x in tagArray{
            tags.postid = postid
            tags.tag = x
            let storeTags = backendless.data.of(Tags.ofClass())
            
            var err: Fault?
            let finish = storeTags.save(tags, fault: &err) as? Tags
            if err == nil {
                print("Tag saved: \(finish!.objectId)")
            }
            else {
                print("server reported an error: \(err)")
            }
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
    }

}
