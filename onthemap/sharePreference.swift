//
//  sharePreference.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/21/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation

class sharePreference{
    
    
    let KEY = "loginKey"
    let KEYID = "key"
    let REGISTER = "register"
    let EXPIRE = "expire"
    let ID = "ID"
    
    let MAPSTR = "mapString"
    let PARSEID = "parseID"
    
    
    func saveLogin(key:NSString,register:Int, expire:NSString, userID:NSString){
        let preference = NSUserDefaults.standardUserDefaults()
        preference.setObject("1", forKey: KEY)
        preference.setObject(key, forKey: KEYID)
        preference.setObject(register, forKey: ID)
        preference.setObject(expire, forKey: EXPIRE)
        preference.setObject(userID, forKey: ID)
    }
    
    func getLogin() -> String{
        let preference = NSUserDefaults.standardUserDefaults()
        if let keyLogin = preference.stringForKey(KEY){
            return keyLogin
        }
        return "0"
    }
    
    func getKey() -> String{
        return NSUserDefaults.standardUserDefaults().stringForKey(KEYID)!
    }
    
    func getRegister() -> String{
        return NSUserDefaults.standardUserDefaults().stringForKey(REGISTER)!
    }
    
    func getExpire() -> String{
        return NSUserDefaults.standardUserDefaults().stringForKey(EXPIRE)!
    }
    
    func getUserID() -> String{
        return NSUserDefaults.standardUserDefaults().stringForKey(ID)!
    }
    
    func clearLogin(){
        let mapApp = NSBundle.mainBundle().bundleIdentifier!
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(mapApp)
    }
    
    func setParseID(objID:String){
        let preference = NSUserDefaults.standardUserDefaults()
        preference.setObject(objID, forKey: PARSEID)
    }
    
    func getParseID() -> String {
        if (NSUserDefaults.standardUserDefaults().stringForKey(PARSEID) != nil){
            return NSUserDefaults.standardUserDefaults().stringForKey(PARSEID)!
        } else {
            return ""
        }
        
        
    }
    
}
