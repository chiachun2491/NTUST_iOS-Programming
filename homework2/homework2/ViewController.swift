//
//  ViewController.swift
//  homework2
//
//  Created by Jeffery Ho on 2020/3/26.
//  Copyright © 2020 Jeffery Ho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var imageName: String?
    var itemName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        segueDataProcess(imageName: imageName, itemName: itemName)
    }
    
    func segueDataProcess(imageName: String?, itemName: String?) {
        textLabel.text = "飲料名稱：\(itemName!)"
        image.image = UIImage(named: imageName!)
    }


}

