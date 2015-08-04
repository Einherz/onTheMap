//
//  udacityUser.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/21/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation

struct StudentInformation {
    var createdAt:NSString
    var firstName:NSString
    var lastName:NSString
    var latitude:Double
    var longitude:Double
    var mapString:NSString
    var mediaURL:NSString
    var updatedAt:NSString
   
    init(firstName:NSString, lastName:NSString, latitude:Double, longitude:Double, mapString:NSString, mediaURL:NSString,createdAt:NSString, updatedAt:NSString){
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func getFirstName() -> NSString {
        return self.firstName
    }
    
    func getLastName() -> NSString {
        return self.lastName
    }
    
    func getLat() -> Double {
        return self.latitude
    }
    
    func getLong() -> Double {
        return self.longitude
    }
    
    func getMapStr() -> NSString {
        return self.mapString
    }
    
    func getMedia() -> NSString {
        return self.mediaURL
    }
    
    func getCreate() -> NSString {
        return self.createdAt
    }
    
    func getUpdate() -> NSString {
        return self.updatedAt
    }
    
}
