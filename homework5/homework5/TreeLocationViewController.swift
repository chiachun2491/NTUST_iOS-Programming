//
//  TreeLocationViewController.swift
//  homework5
//
//  Created by Jeffery Ho on 2020/6/1.
//  Copyright © 2020 jeffery. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TreeLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {
    
    var tree: Tree?
    @IBOutlet weak var myMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(tree?.treeType! ?? "未知樹種")_\(tree?.treeID! ?? "ID?")"
        myMapView.delegate = self
        myMapView.showsUserLocation = true
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
        // Do any additional setup after loading the view.
        let center:CLLocation = CLLocation(latitude: (tree?.coordinate!.latitude)!, longitude: (tree?.coordinate!.longitude)!)
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate, span: currentLocationSpan)
        myMapView.setRegion(currentRegion, animated: true)
        
        // 建立一個地點圖示 (圖示預設為紅色大頭針)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = CLLocation(latitude: (tree?.coordinate!.latitude)!, longitude: (tree?.coordinate!.longitude)!).coordinate
        objectAnnotation.title = self.title
        myMapView.addAnnotation(objectAnnotation)
    }
    

    @IBAction func navigationRoute(_ sender: UIBarButtonItem) {
        // 終點座標
        let targetCoordinate = CLLocation(latitude: (tree?.coordinate!.latitude)!, longitude: (tree?.coordinate!.longitude)!).coordinate
        // 初始化 MKPlacemark
        let targetPlacemark = MKPlacemark(coordinate: targetCoordinate)
        // 透過 targetPlacemark 初始化一個 MKMapItem
        let targetItem = MKMapItem(placemark: targetPlacemark)
        // 使用當前使用者當前座標初始化 MKMapItem
        let userMapItem = MKMapItem.forCurrentLocation()
        // 建立導航路線的起點及終點 MKMapItem
        let routes = [userMapItem,targetItem]
        // 我們可以透過 launchOptions 選擇我們的導航模式，例如：開車、走路等等...
        MKMapItem.openMaps(with: routes, launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
