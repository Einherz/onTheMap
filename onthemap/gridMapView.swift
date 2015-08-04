//
//  gridMapView.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/24/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import Foundation
import UIKit

class gridMapView:UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    let cellReuseIdentifier = "cellCollection"
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    @IBOutlet weak var gridList: UICollectionView!
    
    override func viewDidLoad() {
        
        self.gridList.delegate = self
        self.gridList.dataSource = self
    }
    
    //Mark Collection view
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.studentList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = self.gridList.dequeueReusableCellWithReuseIdentifier(self.cellReuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        
        let obj:StudentInformation = appDelegate.studentList[indexPath.row]

        if((cell.viewWithTag(47)) != nil){
            cell.viewWithTag(47)?.removeFromSuperview()
        }
        cell.backgroundView = UIImageView(image: UIImage(named: "human.png"))
        var title:UILabel = UILabel(frame: CGRectMake(0, cell.bounds.size.height-60, cell.bounds.size.width, 80))
        title.text = (obj.getFirstName() as String) + " " + (obj.getLastName() as String)
        title.numberOfLines = 0
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.grayColor()
        title.tag = 47;
        cell.contentView.addSubview(title)

        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let obj:StudentInformation = appDelegate.studentList[indexPath.row];
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: obj.getMedia() as String)!)
    }
    
}