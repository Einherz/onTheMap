//
//  listMapView.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/21/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation
import UIKit

class listMapView:UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let cellReuseIdentifier = "cellTable"
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

    @IBOutlet weak var mapList: UITableView!
    
    override func viewDidLoad() {
        
        self.mapList.delegate = self
        self.mapList.dataSource = self
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
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 1){
            println("cancel")
        } else {
            println("to next View")
            self.performSegueWithIdentifier("toLocation", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  appDelegate.studentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell =  self.mapList.dequeueReusableCellWithIdentifier(self.cellReuseIdentifier) as! UITableViewCell
        
        let obj:StudentInformation = appDelegate.studentList[indexPath.row]
        
        cell.imageView?.image = UIImage(named: "map_pin.png")
        cell.textLabel?.text = (obj.getFirstName() as String) + " " + (obj.getLastName() as String)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let obj:StudentInformation = appDelegate.studentList[indexPath.row];
        
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: obj.getMedia() as String)!)
    }
    
}