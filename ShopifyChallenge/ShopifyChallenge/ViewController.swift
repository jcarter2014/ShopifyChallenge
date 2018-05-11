//
//  ViewController.swift
//  ShopifyChallenge
//
//  Created by John Carter on 5/6/18.
//  Copyright © 2018 Jack Carter. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let url = "https://shopicruit.myshopify.com/admin/orders.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
    
    @IBOutlet weak var ordersByProvinceHeader: UIButton!
    @IBOutlet weak var ordersByYearHeader: UIButton!
    @IBOutlet weak var ordersByProvinceTable: UITableView!    
    @IBOutlet weak var ordersByYearTable: UITableView!
    
    var provinces = [String: Int]()
    var provinceArray = [String]()
    
    var ordersFor2017: Int = 0
    
    var titlesofOrdersIn2017 = [String]()
    
    var ordersInEachProvince = [String: [String]]()
    
    func getAlamofireData() {
        Alamofire.request(url).responseJSON { (response) in
            if let JSON = response.result.value as? [String: Any] {
                //print(JSON)
                if let orders = JSON["orders"] as? [[String: Any]] {
                    //print(orders)
                    for eachItem in orders {
                        
                        let billingAddress = eachItem["billing_address"] as? [String: Any]
                        if let createdAt = eachItem["created_at"] as! String? {
                            if createdAt.hasPrefix("2017") {
                                if let lineItems = eachItem["line_items"] as? [[String: Any]] {
                                    for eachThing in lineItems {
                                        let name = eachThing["name"]!
                                        self.titlesofOrdersIn2017.append(name as! String)
                                    }
                                }
                                self.ordersFor2017 += 1
                            }
                        }
                        if let provinceName = billingAddress?["province"] as? String {
                            if let lineItems = eachItem["line_items"] as? [[String: Any]] {
                                for eachThing in lineItems {
                                    let name = eachThing["name"]!
                                    //print(name)
                                    //print(provinceName)
                                    if self.ordersInEachProvince[provinceName] == nil {
                                        self.ordersInEachProvince[provinceName] = [name as! String]
                                        //print("hello")
                                    } else {
                                        self.ordersInEachProvince[provinceName]?.append(name as! String)
                                    }

                                }
                            }

                            
                            self.provinces[provinceName] = (self.provinces[provinceName] ?? 0) + 1
                            if !self.provinceArray.contains(provinceName) {
                                self.provinceArray.append(provinceName)
                            }
                        }
                    }
                }
            }
            self.ordersByProvinceTable.reloadData()
            self.ordersByYearTable.reloadData()
            self.ordersByYearHeader.setTitle("\(self.ordersFor2017) orders in 2017", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAlamofireData()
        
        ordersByProvinceTable.delegate = self
        ordersByProvinceTable.dataSource = self
        ordersByYearTable.delegate = self
        ordersByYearTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count: Int?
        
        if tableView == ordersByProvinceTable {
            count = provinceArray.count
        }
        if tableView == ordersByYearTable {
            count = titlesofOrdersIn2017.count
        }
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if tableView == ordersByProvinceTable {
            cell = tableView.dequeueReusableCell(withIdentifier: "ProvinceCell", for: indexPath)
            let provinceName = provinceArray[indexPath.row]
            cell?.textLabel?.text = "\(provinceArray[indexPath.row]) has \(provinces[provinceName]!) orders"
        }
        if tableView == ordersByYearTable {
            cell = tableView.dequeueReusableCell(withIdentifier: "YearCell", for: indexPath)
            cell?.textLabel?.text = titlesofOrdersIn2017[indexPath.row]
        }
        return cell!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func test(_ sender: Any) {
        print(provinces)
        print(ordersFor2017)
    }
    
    @IBAction func reloadData(_ sender: Any) {
        self.ordersByProvinceTable.reloadData()
        self.ordersByYearTable.reloadData()
        print(ordersInEachProvince)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewToTable" {
            if let nextViewController = segue.destination as? TableViewController {
                nextViewController.nextProvinceArray = provinceArray
                nextViewController.nextOrdersInEachProvince = ordersInEachProvince
            }
        }
    }
}

