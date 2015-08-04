//
//  udacityAPI.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/21/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation

protocol loginDelegate {
    func didFinishedLogin(jsonData:NSDictionary)
}

class udacityAPI{
    
    let loginAPI:String = "https://www.udacity.com/api/session"
    let userAPI:String = "https://www.udacity.com/api/users/"
   
    
    var delegate:loginDelegate?
    

    func loginUdacity(usernameField:NSString, passwordField:NSString, facebook:String ) {
    let request = NSMutableURLRequest(URL: NSURL(string: loginAPI)!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if(facebook == "0")
    {
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(usernameField)\", \"password\": \"\(passwordField)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
    } else {
        println("Login with Facebook")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(facebook)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        if error != nil { // Handle error…
            println("error sending")
        }
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        println(NSString(data: newData, encoding: NSUTF8StringEncoding))

        var parsingError: NSError? = nil
        let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
        
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.didFinishedLogin(parsedResult)
        })
        }
    task.resume()
    }
    
    // Use another method of callback, not protocol, just to show different way for others who want to study
    func getUserData(userID:String, callback:(jsonData:NSDictionary) -> ()){
        let request = NSMutableURLRequest(URL: NSURL(string: userAPI+userID)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            callback(jsonData: parsedResult)
        }
        task.resume()
    }
}
