//
//  TreeListTableViewController.swift
//  homework5
//
//  Created by Jeffery Ho on 2020/6/1.
//  Copyright © 2020 jeffery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class TreeListTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var myUserDefaults :UserDefaults!
    var myLocationManager :CLLocationManager!
    var apiData: [Tree]!
    var tableData: [Tree]!
    
    let apiURL = "https://tppkl.blob.core.windows.net/blobfs/TaipeiTree.json"
    
    // 超過多少距離才重新取得有限數量資料 (公尺)
    let limitDistance = 500.0
    
    // 有限數量資料的個數
    let limitNumber = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 取得儲存的預設資料
        self.myUserDefaults = UserDefaults.standard
        
        self.apiData = []
        self.tableData = []
        
        // 建立一個 CLLocationManager
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "行道樹資料下載中，需要一段時間...")
        self.refreshControl?.addTarget(self, action: #selector(getTreeDataForObjc), for: UIControl.Event.valueChanged)
        self.refreshControl?.beginRefreshingManually()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (CLLocationManager.authorizationStatus() == .denied) {
            // 設置定位權限的紀錄
            self.myUserDefaults.set(false, forKey: "locationAuth")
            self.myUserDefaults.synchronize()
        } else if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            // 設置定位權限的紀錄
            self.myUserDefaults.set(true, forKey: "locationAuth")
            self.myUserDefaults.synchronize()
            
            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 停止定位自身位置
        myLocationManager.stopUpdatingLocation()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "treeCell", for: indexPath)
        let tree = tableData[indexPath.row]
        
        cell.textLabel?.text = "\(tree.treeType ?? "未知樹種")_\(tree.treeID ?? "ID?")"
        cell.detailTextLabel?.text = ""
        if let locationAuth = myUserDefaults.object(forKey: "locationAuth") as? Bool {
            if locationAuth {
                cell.detailTextLabel?.text = String(format: "%.3f km", tree.coordinate!.getDistance() / 1000)
            }
        }
        return cell
    }

    
    // MARK: CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocation = locations[0] as CLLocation
        
        // 取得目前使用者座標
        let userLatitude = myUserDefaults.object(forKey: "userLatitude") as? Double
        let userLongitude = myUserDefaults.object(forKey: "userLongitude") as? Double
        let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
        if userLocation.distance(from: currentLocation) > limitDistance {
            // 更新自身定位座標
            self.myUserDefaults.set(currentLocation.coordinate.latitude, forKey: "userLatitude")
            self.myUserDefaults.set(currentLocation.coordinate.longitude, forKey: "userLongitude")
            self.myUserDefaults.synchronize()
            // 更新 table
//            self.refreshControl?.beginRefreshing()
//            getTreeData {
//                self.resortTreeData()
//                self.refreshControl?.endRefreshing()
//            }
        }
    }
    
    // 更改定位權限時執行
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            // 設置定位權限的紀錄
            self.myUserDefaults.set(false, forKey: "locationAuth")
            self.myUserDefaults.synchronize()
        } else if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            // 設置定位權限的紀錄
            self.myUserDefaults.set(true, forKey: "locationAuth")
            
            // 更新記錄的座標 for 取得有限數量的資料
            self.myUserDefaults.set(0.0, forKey: "treeRecordLatitude")
            self.myUserDefaults.set(0.0, forKey: "treeRecordLongitude")

            self.myUserDefaults.synchronize()

            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Tree Data Process
    
    @objc func getTreeData(completion: @escaping () -> Void) {
        self.refreshControl?.beginRefreshing()
        if self.apiData.isEmpty {
            myUserDefaults.set(Date(), forKey: "treeFetchDate")
            self.myUserDefaults.synchronize()
            AF.request(apiURL, method: .get).responseJSON { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    self.apiData.removeAll()
                    print("Cleaned old data.")
                    if let trees = json.array {
                        for tree in trees {
                            let tempTree = Tree()
                            tempTree.treeID = tree["TreeID"].stringValue
                            tempTree.dist = tree["Dist"].stringValue
                            tempTree.region = tree["Region"].stringValue
                            tempTree.regionRemark = tree["RegionRemark"].stringValue
                            tempTree.treeType = tree["TreeType"].stringValue
                            tempTree.diameter = tree["Diameter"].doubleValue
                            tempTree.treeHeight = tree["TreeHeight"].doubleValue
                            tempTree.surveyDate = self.stringConvertDate(string: tree["SurveyDate"].stringValue)
                            tempTree.coordinate = Coordinate(twd97X: tree["X"].doubleValue, twd97Y: tree["Y"].doubleValue)
                            self.apiData.append(tempTree)
                        }
                        print("Added new data")
                        completion()
                    }
                case .failure(let error):
                    print("get treeData failed with error: \(error)")
                    completion()
                }
            }
        } else {
            print("No need to fetch again")
            completion()
        }

    }
    
    @objc func getTreeDataForObjc() {
        getTreeData {
            self.resortTreeData()
            self.refreshControl?.endRefreshing()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "重新定位中，請稍候...")
        }
    }
    
    func resortTreeData() {
        self.apiData.sort{ (lhs: Tree, rhs: Tree) -> Bool in
            // you can have additional code here
            return lhs.coordinate! < rhs.coordinate!
        }
        self.tableData = Array(self.apiData[0...limitNumber])
        self.tableView.reloadData()
    }
        
    func stringConvertDate(string: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSSSSS") -> Date? {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: string)
        return date
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "treeDetailSegue" {
            let controller = segue.destination as? TreeDetailTableViewController
            
            if let row = tableView.indexPathForSelectedRow?.row {
                controller?.tree = apiData[row]
            }
        }
    }
}

extension UIRefreshControl {

    func beginRefreshingManually() {
        if let tableView = superview as? UITableView {
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y - frame.height), animated: false)
        }
        beginRefreshing()
        sendActions(for: .valueChanged)
    }

}
