//
//  geoLocationView.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/25/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation
import MapKit

class geoLocationView:UIViewController, loadPositionDelegate
{
    var positionMap:NSString!
    let login:udacityAPI = udacityAPI()
    let userData:sharePreference = sharePreference()
    let parseMap:parseAPI = parseAPI()
    let geoCode:CLGeocoder = CLGeocoder()
    var coordinate:CLLocationCoordinate2D?
    
    var delegate:loadPositionDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareLocation: UITextField!
    @IBOutlet weak var topUrlView: UIView!
    
    override func viewDidLoad() {
        
        var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(actInd)
        actInd.startAnimating()

        self.parseMap.delegate = self
        
        geoCode.geocodeAddressString(self.positionMap as String, completionHandler: { (places, error) -> Void in
            if((error) != nil)
            {
                let alert = UIAlertView()
                alert.title = "Error Problem"
                alert.message = "\(error)"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                actInd.stopAnimating()
            }
            
            else if let place = places[0] as? CLPlacemark{
                
                UIView.animateWithDuration(0.7, delay: 1.0, usingSpringWithDamping: 0.7,initialSpringVelocity: 7.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.topUrlView.hidden = false
                    self.topUrlView.frame = CGRectMake(0, 200, self.topUrlView.frame.width, self.topUrlView.frame.height)
                    }, completion: { finished in
                        actInd.stopAnimating()
                })

                let place:CLPlacemark = places[0] as! CLPlacemark
                let mapCoordinate:CLLocationCoordinate2D = place.location.coordinate
                self.coordinate = mapCoordinate

                let point:MKPointAnnotation = MKPointAnnotation()
                point.coordinate = mapCoordinate
                point.title = self.positionMap as String
                
                self.mapView.addAnnotation(point)
                self.mapView.centerCoordinate = mapCoordinate
                self.mapView.selectAnnotation(point, animated: true)
            }
        })
    }
    
    @IBAction func sendPosition(sender: UIButton) {
        //Call API
        if !self.shareLocation.text.isEmpty{
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
            alert.title = "Please fill all information"
            alert.message = "URL to share could not be empty"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    //Mark Delegate after Post map
    func didFinishedPostMap(objID:String, status:Int) {
        
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
        var viewController = storyboard.instantiateViewControllerWithIdentifier("loggedView") as! mainView
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func didFinishedLoadMap(student: [StudentInformation]) {
        println("do nothing")
    }
}

