//
//  enterLocationView.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/23/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation

class enterLocationView:UIViewController{
    
    
    @IBOutlet weak var locationTxt: UITextField!
    
    @IBAction func sendMapData(sender: UIButton) {
        if locationTxt.text.isEmpty{
            let alert:UIAlertView = UIAlertView()
            
            alert.title = "Please fill out your location"
            alert.message = "Location could not be empty"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        else {
            self.performSegueWithIdentifier("toShare", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toShare"){
            let nextView:geoLocationView = segue.destinationViewController as! geoLocationView
            nextView.positionMap = locationTxt.text as NSString
        }
    }
    @IBAction func cancelAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
