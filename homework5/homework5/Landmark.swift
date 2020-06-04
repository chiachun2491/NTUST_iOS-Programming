//
//  Landmark.swift
//  homework5
//
//  Created by Jeffery Ho on 2020/6/2.
//  Copyright © 2020 jeffery. All rights reserved.
//

import UIKit
import CoreLocation

class Landmark: NSObject {
    var name: String?
    var openTime: String?
    var tel: String?
    var fax: String?
    var url: URL?
    
    var dist: String?
    var address: String?
    var coordinate: CLLocation?
    
    var distance: Double = 0
    
    override init() {
        self.name = ""
        self.openTime = ""
        self.tel = ""
        self.fax = ""
        
        self.dist = ""
        self.address = ""
        self.coordinate = CLLocation()
        self.distance = 0
    }
    
    func getDistance() -> Double {
        let myUserDefaults = UserDefaults.standard
        // 取得目前使用者座標
        // 取得目前使用者座標
        let userLatitude = myUserDefaults.object(forKey: "userLatitude") as? Double
        let userLongitude = myUserDefaults.object(forKey: "userLongitude") as? Double
        let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
        
        self.distance = (self.coordinate?.distance(from: userLocation))!
        return self.distance
    }
}

extension Landmark: Comparable {
    
    static public func == (lhs: Landmark, rhs: Landmark) -> Bool {
        return lhs.getDistance() == rhs.getDistance()
    }
    
    public static func < (lhs: Landmark, rhs: Landmark) -> Bool {
        return lhs.getDistance() < rhs.getDistance()
    }
}


