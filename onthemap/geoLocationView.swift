//
//  geoLocationView.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/25/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation
import MapKit

class geoLocationView:UIViewController, loadPositionDelegate, UIGestureRecognizerDelegate,UITextFieldDelegate
{
    var positionMap:NSString!
    let login:udacityAPI = udacityAPI()
    let userData:sharePreference = sharePreference()
    let parseMap:parseAPI = parseAPI()
    let geoCode:CLGeocoder = CLGeocoder()
    var coordinate:CLLocationCoordinate2D?
    var flagSubmit:Bool = false
    var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    
    var delegate:loadPositionDelegate?
    
    @IBOutlet weak var mapDisplay: MKMapView!
    @IBOutlet weak var shareLocation: UITextField!
    @IBOutlet weak var topUrlView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var heightLayout: NSLayoutConstraint!
    override func viewDidLoad() {
        
//        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
//        tapGesture.delegate = self
//        self.view.addGestureRecognizer(tapGesture);
        
        self.actInd.center = self.view.center
        self.actInd.hidesWhenStopped = true
        self.actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(actInd)
        self.actInd.startAnimating()

        self.parseMap.delegate = self
        self.shareLocation.delegate = self
        
        self.submitBtn.alpha = 0.5
        self.submitBtn.enabled = false
        
        geoCode.geocodeAddressString(self.positionMap as String, completionHandler: { (places, error) -> Void in
            if((error) != nil)
            {
                let alert = UIAlertView()
                alert.title = "Error Problem"
                alert.message = "\(error)"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                self.actInd.stopAnimating()
                self.topUrlView.hidden = false
               
                self.shareLocation.enabled = false
            }
            
            else if let place = places[0] as? CLPlacemark{
                
                UIView.animateWithDuration(0.7, delay: 1.0, usingSpringWithDamping: 0.7,initialSpringVelocity: 7.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.topUrlView.hidden = false
                    self.topUrlView.frame = CGRectMake(0, 200, self.topUrlView.frame.width, self.topUrlView.frame.height)
                    }, completion: { finished in
                        self.actInd.stopAnimating()
                })
                

                self.flagSubmit = true
                
                let place:CLPlacemark = places[0] as! CLPlacemark
                let mapCoordinate:CLLocationCoordinate2D = place.location.coordinate
                self.coordinate = mapCoordinate

                let point:MKPointAnnotation = MKPointAnnotation()
                point.coordinate = mapCoordinate
                point.title = self.positionMap as String
                
                self.mapDisplay.addAnnotation(point)
                self.mapDisplay.centerCoordinate = mapCoordinate
                self.mapDisplay.selectAnnotation(point, animated: true)
            }
        })
    }
    
    @IBAction func checkSite(sender: UIButton) {
        
        let validateURL = NSURL(string: self.shareLocation.text)

       if (validateURL?.host != nil) && (validateURL != nil){
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: self.shareLocation.text)!)
        } else {
            let alert = UIAlertView()
            alert.title = "Please fill correct information"
            alert.message = "URL to share is not in the right format.  http://www.abc.com"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    @IBAction func sendPosition(sender: UIButton) {
        //Call API
        let validateURL = NSURL(string: self.shareLocation.text)
        
        if flagSubmit{
        if !self.shareLocation.text.isEmpty && (validateURL?.host != nil) && (validateURL != nil){
    
        self.actInd.startAnimating()
            
        self.login.getUserData(userData.getKey(), callback: { (jsonData) -> () in
            let myFirstName = jsonData.valueForKey("user")!.valueForKey("first_name") as! String
            let myLastName = jsonData.valueForKey("user")!.valueForKey("last_name") as! String
            let myLat = self.coordinate!.latitude as Double
            let myLong = self.coordinate!.longitude as Double
            let objID = self.userData.getParseID() as String
            self.parseMap.postStudentLocations(myFirstName, lastName:myLastName, location: self.positionMap, url: self.shareLocation.text, lat: myLat, long: myLong,objectId:objID)
            })
        } else {
            let alert = UIAlertView()
            alert.title = "Please fill correct information"
            alert.message = "URL to share is not in the right format.  http://www.abc.com"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
            
        } else {
            let alert = UIAlertView()
            alert.title = "Please choose the right location"
            alert.message = "Location must not be empty"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Mark Delegate after Post map
    func didFinishedPostMap(objID:String, status:Int) {
        
        self.actInd.stopAnimating()

        let alert = UIAlertView()
        if status == 0 {
            let chkLogin:sharePreference = sharePreference()
            chkLogin.setParseID(objID)
            
            alert.title = "Map saved"
            alert.message = "Your Location Is Saved Into Database"
        } else {
            alert.title = "Map updated"
            alert.message = "Update at : \(objID)"
        }
        
        alert.addButtonWithTitle("OK")
        alert.show()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("mapController") as! mapView
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func didFinishedLoadMap(student: [StudentInformation]) {
        println("do nothing")
    }

    //Mark keyboard hiding
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//        // force keyboard to hide
//        self.view.endEditing(true)
//        return false
//    }
//    
//    func hideKeyBoard()
//    {
//        // force keyboard to hide
//        self.view.endEditing(true);
//    }
    
    
    //add return function to hidekeyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
       
        let validateURL = NSURL(string: textField.text)
        
        if (validateURL?.host != nil) && (validateURL != nil){
            UIView.animateWithDuration(0.7, delay: 1.0, usingSpringWithDamping: 1.0,initialSpringVelocity: 10.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
    
                self.submitBtn.alpha = 1.0
                self.submitBtn.backgroundColor = UIColor.greenColor()
                self.submitBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                self.submitBtn.setNeedsUpdateConstraints()
                
                self.heightLayout.constant = 40
                
                }, completion: { finished in
                   self.submitBtn.layoutIfNeeded()
                   self.submitBtn.enabled = true
            })
    }
    }
}

