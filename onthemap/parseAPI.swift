//
//  parseAPI.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/21/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation

protocol loadPositionDelegate {
    func didFinishedLoadMap(student:[StudentInformation])
    func didFinishedPostMap(objID:String, status:Int)
}

class parseAPI {
    
    let parseID:String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let restAPI:String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    let parseURL:String = "https://api.parse.com/1/classes/StudentLocation"
    
    var delegate:loadPositionDelegate?
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;

    
    func getStudentLocations(count:Int)
    {
        var students: [StudentInformation] = []

        let request = NSMutableURLRequest(URL: NSURL(string: parseURL+"?limit=10&skip=\(count)")!)
        request.addValue(parseID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restAPI, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                let alert = UIAlertView()
                alert.delegate = self
                alert.message = error.localizedDescription
                alert.addButtonWithTitle("OK")
                alert.show()
                return
            }
            
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
           
            for user in parsedResult.valueForKey("results") as! NSArray{
                var student:StudentInformation = StudentInformation(firstName: user["firstName"] as! NSString, lastName: user["lastName"] as! NSString, latitude: user["latitude"] as! Double, longitude: user["longitude"] as! Double, mapString:user["mapString"] as! NSString,mediaURL: user["mediaURL"] as! NSString, createdAt:user["createdAt"] as! NSString, updatedAt:(user["updatedAt"] as? NSString)!)
                students.append(student)
            }

            dispatch_async(dispatch_get_main_queue(), {
                self.delegate?.didFinishedLoadMap(students)
            })
        }
        task.resume()
    }
    
    func getMyLocation(uniqueID:String,callback:(jsonData:NSDictionary) -> ())
    {
        let urlString = "\(parseURL)?where=%7B%22uniqueKey%22%3A%22\(uniqueID)%22%7D"
        println(urlString)
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(parseID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restAPI, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { /* Handle error */
                let alert = UIAlertView()
                alert.delegate = self
                alert.message = error.localizedDescription
                alert.addButtonWithTitle("OK")
                alert.show()
                return }
            
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            callback(jsonData: parsedResult)
        }
        task.resume()
    }
    
    func postStudentLocations(firstName:String, lastName:String, location:NSString, url:NSString,lat:Double,long:Double,objectId:String = "")
    {
        let chkLogin:sharePreference = sharePreference()
        println("url : \(parseURL+objectId)")
        let request:NSMutableURLRequest
        
        if(objectId.isEmpty){
            request = NSMutableURLRequest(URL: NSURL(string: parseURL)!)
            request.HTTPMethod = "POST"
            
        } else {
            request = NSMutableURLRequest(URL: NSURL(string: parseURL+"/"+objectId)!)
            request.HTTPMethod = "PUT"
        }
        
        request.HTTPBody = "{\"uniqueKey\": \"\(chkLogin.getKey())\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(url)\",\"latitude\": \(lat), \"longitude\": \(long)}".dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue(parseID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restAPI, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                let alert = UIAlertView()
                alert.delegate = self
                alert.message = error.localizedDescription
                alert.addButtonWithTitle("OK")
                alert.show()
                return
            }
            
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if(objectId.isEmpty){
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.didFinishedPostMap(parsedResult.valueForKey("objectId") as! String, status: 0)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.didFinishedPostMap(parsedResult.valueForKey("updatedAt") as! String, status: 1)
                })
            }
        }
        task.resume()
    }
}
