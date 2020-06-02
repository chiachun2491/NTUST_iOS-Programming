//
//  Tree.swift
//  homework5
//
//  Created by Jeffery Ho on 2020/6/2.
//  Copyright © 2020 jeffery. All rights reserved.
//

import UIKit
import CoreLocation

class Tree: NSObject {
    var treeID: String?
    var diameter: Double = 0
    var dist: String?
    var region: String?
    var regionRemark: String?
    var surveyDate: Date?
    var treeHeight: Double = 0
    var treeType: String?
    var coordinate: Coordinate?
    
    override init() {
        self.treeID = ""
        self.diameter = 0
        self.dist = ""
        self.region = ""
        self.regionRemark = ""
        self.surveyDate = Date()
        self.treeHeight = 0
        self.treeType = ""
        self.coordinate = Coordinate()
    }
}

public class Coordinate: NSObject {
    
    var latitude: Double
    var longitude: Double
    
    override init() {
        self.latitude = 0
        self.longitude = 0
    }
    
    convenience init(twd97X: Double, twd97Y: Double) {
        self.init()
        let a = 6378137.0
        let b = 6356752.314245
        let lng0 = 121 * Double.pi / 180
        let k0 = 0.9999
        let dx = 250000.0
        
        let dy = 0.0
        let e = pow((1 - pow(b, 2) / pow(a, 2)), 0.5)

        let x = twd97X - dx
        let y = twd97Y - dy

        let M = y / k0

        let mu = M / (a * (1.0 - pow(e, 2) / 4.0 - 3 * pow(e, 4) / 64.0 - 5 * pow(e, 6) / 256.0))
        let e1 = (1.0 - pow((1.0 - pow(e, 2)), 0.5)) / (1.0 + pow((1.0 - pow(e, 2)), 0.5))

        let J1 = (3 * e1 / 2 - 27 * pow(e1, 3) / 32.0)
        let J2 = (21 * pow(e1, 2) / 16 - 55 * pow(e1, 4) / 32.0)
        let J3 = (151 * pow(e1, 3) / 96.0)
        let J4 = (1097 * pow(e1, 4) / 512.0)

        let fp = mu + J1 * sin(2 * mu) + J2 * sin(4 * mu) + J3 * sin(6 * mu) + J4 * sin(8 * mu)

        let e2 = pow((e * a / b), 2)
        let C1 = pow(e2 * cos(fp), 2)
        let T1 = pow(tan(fp), 2);
        let R1 = a * (1 - pow(e, 2)) / pow((1 - pow(e, 2) * pow(sin(fp), 2)), (3.0 / 2.0))
        let N1 = a / pow((1 - pow(e, 2) * pow(sin(fp), 2)), 0.5)
        
        let D = x / (N1 * k0)

        let Q1 = N1 * tan(fp) / R1
        let Q2 = (pow(D, 2) / 2.0)
        let Q3 = (5 + 3 * T1 + 10 * C1 - 4 * pow(C1, 2) - 9 * e2) * pow(D, 4) / 24.0
        let Q4 = (61 + 90 * T1 + 298 * C1 + 45 * pow(T1, 2) - 3 * pow(C1, 2) - 252 * e2) * pow(D, 6) / 720.0
        var lat = fp - Q1 * (Q2 - Q3 + Q4)

        let Q5 = D
        let Q6 = (1 + 2 * T1 + C1) * pow(D, 3) / 6;
        let Q7 = (5 - 2 * C1 + 28 * T1 - 3 * pow(C1, 2) + 8 * e2 + 24 * pow(T1, 2)) * pow(D, 5) / 120.0;
        var lng = lng0 + (Q5 - Q6 + Q7) / cos(fp);

        lat = (lat * 180) / Double.pi;
        lng = (lng * 180) / Double.pi;
        
        self.latitude = lat
        self.longitude = lng
    }
    
    func getDistance() -> Double {
        let myUserDefaults = UserDefaults.standard
        // 取得目前使用者座標
        let userLatitude = myUserDefaults.object(forKey: "userLatitude") as? Double
        let userLongitude = myUserDefaults.object(forKey: "userLongitude") as? Double
        let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
        
        let treeLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        return treeLocation.distance(from: userLocation)
    }
}

extension Tree: Comparable {
    
    static public func == (lhs: Tree, rhs: Tree) -> Bool {
        return lhs.coordinate == rhs.coordinate
    }
    
    public static func < (lhs: Tree, rhs: Tree) -> Bool {
        return lhs.coordinate! < rhs.coordinate!
    }
}

extension Coordinate: Comparable {
    
    static public func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        let myUserDefaults = UserDefaults.standard
        
        // 是否取得定位權限
        let locationAuth = myUserDefaults.object(forKey: "locationAuth") as? Bool
        
        if locationAuth != nil && locationAuth! {
            // 取得目前使用者座標
            let userLatitude = myUserDefaults.object(forKey: "userLatitude") as? Double
            let userLongitude = myUserDefaults.object(forKey: "userLongitude") as? Double
            let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
            
            // 兩點的座標
            let lLocation = CLLocation(latitude: lhs.latitude, longitude: lhs.longitude)
            let rLocation = CLLocation(latitude: rhs.latitude, longitude: rhs.longitude)

            return lLocation.distance(from: userLocation) == rLocation.distance(from: userLocation)
        } else {
            return lhs.latitude == rhs.latitude && lhs.longitude == rhs.latitude
        }

    }
    
    public static func > (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return !(lhs < rhs) && !(lhs == rhs) 
    }
    
    public static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
        let myUserDefaults = UserDefaults.standard

        // 是否取得定位權限
        let locationAuth = myUserDefaults.object(forKey: "locationAuth") as? Bool

        if locationAuth != nil && locationAuth! {
            // 取得目前使用者座標
            let userLatitude = myUserDefaults.object(forKey: "userLatitude") as? Double
            let userLongitude = myUserDefaults.object(forKey: "userLongitude") as? Double
            let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
            
            // 兩點的座標
            let lLocation = CLLocation(latitude: lhs.latitude, longitude: lhs.longitude)
            let rLocation = CLLocation(latitude: rhs.latitude, longitude: rhs.longitude)
            
            return lLocation.distance(from: userLocation) < rLocation.distance(from: userLocation)
        } else {
            if (lhs.latitude == rhs.latitude) {
                return lhs.longitude < rhs.longitude
            } else {
                return lhs.latitude < rhs.latitude
            }
        }
    }
}


