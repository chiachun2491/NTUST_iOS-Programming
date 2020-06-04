//
//  LandmarkListTableViewController.swift
//  homework5
//
//  Created by Jeffery Ho on 2020/6/1.
//  Copyright © 2020 jeffery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class LandmarkListTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var myUserDefaults :UserDefaults!
    var myLocationManager :CLLocationManager!
    var apiData: [Landmark]!
    var showDistance: Double = 2000.0
    
    let apiURL = "https://www.travel.taipei/open-api/zh-tw/Attractions/All"
    
    // 超過多少距離才重新取得有限數量資料 (公尺)
    let limitDistance = 100.0
    
    // 有限數量資料的個數
    let limitNumber = 500

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 取得儲存的預設資料
        self.myUserDefaults = UserDefaults.standard
        
        self.apiData = []
        
        // 建立一個 CLLocationManager
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "資料下載中，請稍候...")
        self.refreshControl?.addTarget(self, action: #selector(getLandmarkDataForObjc), for: UIControl.Event.valueChanged)
        
        if let showDistance = self.myUserDefaults.object(forKey: "showDistance") as? Double {
            self.showDistance = showDistance
        }
        else {
            self.myUserDefaults.set(self.showDistance, forKey: "showDistance")
        }
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
    @IBAction func setDistance(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "設定顯示距離",
            message: "請輸入想要查詢的範圍（單位公尺）",
            preferredStyle: .alert)

        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "顯示距離"
            textField.keyboardType = .numberPad
            if let showDistance = self.myUserDefaults.object(forKey: "showDistance") as? Double {
                textField.text = Int(showDistance).description
            }
        }

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
            let showDistanceField = (alertController.textFields?.first)! as UITextField
            if showDistanceField.text != "" {
                self.showDistance = Double(showDistanceField.text!)!
                self.myUserDefaults.set(self.showDistance, forKey: "showDistance")
                self.myUserDefaults.synchronize()
                // 更新 table
                self.refreshControl!.beginRefreshingManually()
            }
            else {
                let errorMsg = UIAlertController(
                title: "錯誤",
                message: "請輸入數字。",
                preferredStyle: .alert)
                errorMsg.addAction(UIAlertAction(title: "確認", style: .default) { (action) in
                    self.present(alertController, animated: true, completion: nil)
                })
                self.present(errorMsg, animated: true, completion: nil)
            }
            
            print("\(self.showDistance)")
            
            
          }
        alertController.addAction(okAction)

        // 顯示提示框
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return apiData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "treeCell", for: indexPath)
        let landmark = apiData[indexPath.row]
        
        cell.textLabel?.text = "\(landmark.name ?? "name?")"
        cell.detailTextLabel?.text = ""
        if let locationAuth = myUserDefaults.object(forKey: "locationAuth") as? Bool {
            if locationAuth {
                cell.detailTextLabel?.text = String(format: "%.2f km", landmark.getDistance() / 1000)
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
            self.myUserDefaults.set(Double(currentLocation.coordinate.latitude), forKey: "userLatitude")
            self.myUserDefaults.set(Double(currentLocation.coordinate.longitude), forKey: "userLongitude")
            self.myUserDefaults.synchronize()
            // 更新 table
            self.refreshControl?.beginRefreshingManually()
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
            self.myUserDefaults.set(0.0, forKey: "userLatitude")
            self.myUserDefaults.set(0.0, forKey: "userLongitude")

            self.myUserDefaults.synchronize()

            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Landmark Data Process
    
    @objc func getLandmarkData(completion: @escaping () -> Void) {
        var params: Parameters = [
            "page": 1,
        ]
        
        if let locationAuth = myUserDefaults.object(forKey: "locationAuth") as? Bool {
            if locationAuth {
                if let userLatitude = myUserDefaults.object(forKey: "userLatitude") as? Double {
                    params.updateValue(userLatitude, forKey: "nlat")
                }
                if let userLongitude = myUserDefaults.object(forKey: "userLongitude") as? Double {
                    params.updateValue(userLongitude, forKey: "elong")
                }
            }
        }
        var count = 0
        for page in 1...10 {
            params.updateValue(page, forKey: "page")
            AF.request(apiURL, method: .get, parameters: params, headers: ["Accept": "application/json"]).responseJSON { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    if let landmarks = json["data"].array {
                        for landmark in landmarks {
                            let tempLandmark = Landmark()
                            tempLandmark.name = landmark["name"].stringValue
                            tempLandmark.openTime = landmark["open_time"].stringValue
                            tempLandmark.tel = landmark["tel"].stringValue
                            tempLandmark.fax = landmark["fax"].stringValue
                            tempLandmark.url = URL(string: landmark["url"].stringValue)
                            tempLandmark.dist = landmark["distric"].stringValue
                            tempLandmark.address = landmark["address"].stringValue
                            tempLandmark.coordinate = CLLocation(latitude: landmark["nlat"].doubleValue, longitude: landmark["elong"].doubleValue)
                            
                            if tempLandmark.getDistance() <= self.showDistance {
                                self.apiData.append(tempLandmark)
                            }
                        }
                        print("Added new data page \(page)")
                        count += 1
                        if count >= 10 {
                            completion()
                        }
                    }
                case .failure(let error):
                    print("get landmarkData \(page) failed with error: \(error)")
                    completion()
                }
            }
        }
    }
    
    @objc func getLandmarkDataForObjc() {
        self.apiData.removeAll()
        self.tableView.reloadData()
        print("Cleaned old data.")
        getLandmarkData {
            self.resortLandmarkData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func resortLandmarkData() {
        self.apiData.sort(by: <)
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DetailSegue" {
            let controller = segue.destination as? LandmarkDetailTableViewController
            
            if let row = tableView.indexPathForSelectedRow?.row {
                controller?.landmark = apiData[row]
            }
        }
    }
}

extension UIRefreshControl {

    func beginRefreshingManually() {
        
        if let tableView = superview as? UITableView {
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y - frame.height), animated: false)
            if tableView.numberOfRows(inSection: 0) > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            
        }

        beginRefreshing()
        sendActions(for: .valueChanged)
    }

}
