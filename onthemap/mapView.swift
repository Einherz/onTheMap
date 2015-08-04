//
//  mapView.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/21/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation
import MapKit

class mapView:UIViewController, MKMapViewDelegate, loadPositionDelegate, UIAlertViewDelegate {
    
    let parseMap:parseAPI = parseAPI()
    var delegate:loadPositionDelegate?
    var annotations = [MKPointAnnotation]()
    var myAnnotation = MKPointAnnotation()

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
   
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.parseMap.delegate = self
        self.parseMap.getStudentLocations()
        
    }
    
    @IBAction func findMe(sender: UIButton) {
        let chkLogin:sharePreference = sharePreference()
        let myID = chkLogin.getKey()
        
        self.parseMap.getMyLocation(myID, callback: { (jsonData) -> () in

            let myData =  jsonData.valueForKey("results") as! NSArray
            let myLat = myData.objectAtIndex(0).valueForKey("latitude") as! Double
            let myLong = myData.objectAtIndex(0).valueForKey("longitude") as! Double
            
            let lat = CLLocationDegrees(myLat)
            let long = CLLocationDegrees(myLong)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            
            let first = myData.objectAtIndex(0).valueForKey("firstName") as! NSString
            let last = myData.objectAtIndex(0).valueForKey("lastName") as! NSString
            let mediaURL = myData.objectAtIndex(0).valueForKey("mediaURL") as! NSString
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            self.myAnnotation.coordinate = coordinate
            self.myAnnotation.title = "\(first) \(last)"
            self.myAnnotation.subtitle = mediaURL as String
            
           self.mapView.removeAnnotations(self.mapView.annotations)
            
           self.mapView.addAnnotation(self.myAnnotation)
           self.mapView.centerCoordinate = coordinate
           self.mapView.selectAnnotation(self.myAnnotation, animated: true)
        })
    }
    
    @IBAction func logOut(sender: AnyObject) {
        let chkLogin:sharePreference = sharePreference()
        chkLogin.clearLogin()
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("login") as! loginView
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    @IBAction func sendPosition(sender: UIBarButtonItem) {
        let userData:sharePreference = sharePreference()
        println("info \(userData.getParseID())")
        if(userData.getParseID().isEmpty){
            self.performSegueWithIdentifier("toLocation", sender: self)
        } else {
            let alert = UIAlertView()
            alert.delegate = self
            alert.message = "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?"
            alert.addButtonWithTitle("Overwrite")
            alert.addButtonWithTitle("Cancel")
            alert.show()
        }
    }
    
    //Mark UIAlertview
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 1){
            println("cancel")
        } else {
             println("to next View")
            self.performSegueWithIdentifier("toLocation", sender: self)
        }
    }
    
    @IBAction func reloadMap(sender: UIBarButtonItem) {
        //Reload Pin again
        self.reloadMapView()
    }
//Mark : Delegate for Load position
    func didFinishedLoadMap(students:[StudentInformation])
    {
        appDelegate.studentList = students
        self.reloadMapView()
    }
    
    func reloadMapView()
    {
        //remove all exist first
        self.mapView.removeAnnotations(self.mapView.annotations)

        
        for student in appDelegate.studentList {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(student.getLat())
            let long = CLLocationDegrees(student.getLong())
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.getFirstName()
            let last = student.getLastName()
            let mediaURL = student.getMedia()
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL as String
            
            // Finally we place the annotation in an array of annotations.
            self.annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(self.annotations)
    }
    
    func didFinishedPostMap(objID:String, status:Int) {
        println("do nothing")
    }

//Mark : MapviewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
}