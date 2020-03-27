//
//  ViewController.swift
//  homework1
//
//  Created by mac13 on 2020/3/12.
//  Copyright © 2020 mac13. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pressBtn: UIButton!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let symbol = ["🍎","🍐","🍊","🍋","🍉","🍇"]
    var scoreVal = 0
    var col1 = [String]()
    var col2 = [String]()
    var col3 = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for _ in 1...100 {
            col1.append(symbol[(Int)(arc4random() % 6)])
            col2.append(symbol[(Int)(arc4random() % 6)])
            col3.append(symbol[(Int)(arc4random() % 6)])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(title: "登入", message: "請輸入帳號密碼", preferredStyle: .alert)
        
        alert.addTextField {(textField) in
            textField.placeholder = "Login"
        }
        alert.addTextField {(textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let warning = UIAlertController(title: "", message: "請輸入帳號", preferredStyle: .alert)
        
        warning.addAction(UIAlertAction(title: "OK", style: .default) {(action) in
            login()
        })
        
        // cancel action
        alert.addAction(UIAlertAction(title:"取消",style: .cancel) {(action) in
            self.dismiss(animated: true, completion: nil)
        })
        // enter action
        alert.addAction(UIAlertAction(title:"登入",style: .default) {(action) in
            self.dismiss(animated: true, completion: nil)
            let textField = alert.textFields![0].text
            if textField != "" {
                self.welcomeLabel.text = "您好，" + textField!
            }
            else {
                self.present(warning, animated: true, completion: nil)
            }
        })
        
        func login() {
            present(alert, animated: true, completion: nil)
        }
        login()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return col1.count
        }
        else if component == 1 {
            return col2.count
        }
        else {
            return col3.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView  {
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont (name: "Helvetica Neue", size: 80)
        //data source means your ui picker view items array
        if component == 0 {
            label.text = col1[row]
        }
        else if component == 1 {
            label.text = col2[row]
        }
        else {
            label.text = col3[row]
        }
        label.textAlignment = .center
        return label
        
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100.0
    }
     
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat{
        return 100.0
    }
                              
    @IBAction func pressBtnEvent(_ sender: UIButton) {
        let rand1 = Int(arc4random()) % 100
        let rand2 = Int(arc4random()) % 100
        let rand3 = Int(arc4random()) % 100
        pickerView.selectRow(rand1, inComponent: 0, animated: true)
        pickerView.selectRow(rand2, inComponent: 1, animated: true)
        pickerView.selectRow(rand3, inComponent: 2, animated: true)
        
        if col1[rand1] == col2[rand2] && col2[rand2] == col3[rand3] {
            scoreVal += 10
            score.text = String(scoreVal)
        }
    }
    
}

