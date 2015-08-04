//
//  loginInfo.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/21/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation

struct loginInfo {
    var udaKey:NSString
    var register:Int
    var expiration:NSString
    var userID:NSString
    
    init(udaKey:NSString, register:Int, expiration:NSString, userID:NSString)
    {
        self.udaKey = udaKey
        self.register = register
        self.expiration = expiration
        self.userID = userID
    }
    
    func getKey() -> NSString
    {
        return self.udaKey;
    }
    
    func getRegister() -> Int
    {
        return self.register;
    }
    
    func getExp() -> NSString
    {
        return self.expiration;
    }
    
    func getID() -> NSString
    {
        return self.userID;
    }
}
