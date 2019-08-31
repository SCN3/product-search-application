//
//  SimilarTabViewController.swift
//  csci571-hw9
//
//  Created by scn3 on 4/16/19.
//  Copyright © 2019 scn3. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import AlamofireImage

class SimilarTabViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var lblSortBy: UILabel!
    @IBOutlet weak var segSortBy: UISegmentedControl!
    @IBOutlet weak var lblOrder: UILabel!
    @IBOutlet weak var segOrder: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var lblNoSimilar: UILabel!
    
    var products: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        products = [[:], [:], [:], [:]]
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCollectionViewCell", for: indexPath)
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 8.0
        let product = products[indexPath.row]
        if let image = product["image"] as? UIImage {
            let imageView = cell.viewWithTag(100) as! UIImageView
            imageView.image = image
        }
        if let title = product["title"] as? String {
            let label = cell.viewWithTag(101) as! UILabel
            label.text = title
        }
        if let shippingCost = product["shippingCost"] as? Float {
            let label = cell.viewWithTag(102) as! UILabel
            label.text = "$" + String(shippingCost)
        }
        if let daysLeft = product["daysLeft"] as? Int {
            let label = cell.viewWithTag(103) as! UILabel
            if daysLeft == 1 {
                label.text = "1 Day Left"
            } else {
                label.text = String(daysLeft) + " Days Left"
            }
        }
        if let price = product["price"] as? Float {
            let label = cell.viewWithTag(104) as! UILabel
            label.text = "$" + String(price)
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SwiftSpinner.show("Fetching Similar Items...")
        lblSortBy.isHidden = true
        segSortBy.isHidden = true
        lblOrder.isHidden = true
        segOrder.isHidden = true
        lblNoSimilar.isEnabled = true
        collectionView.isHidden = true
        segSortBy.selectedSegmentIndex = 0
        segOrder.selectedSegmentIndex = 0
        segOrder.isEnabled = false
        let detailViewController = tabBarController as! DetailViewController
        let itemId = detailViewController.itemId
        Alamofire.request("http://backend-dot-csci571-hw8-235604.appspot.com/similar?itemId=" + itemId).validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let items = json["getSimilarItemsResponse"]["itemRecommendations"]["item"].array {
                        if items.count == 0 {
                            self.lblNoSimilar.isHidden = false
                            SwiftSpinner.hide()
                            return
                        }
                        let group = DispatchGroup()
                        self.products = Array(repeating: [:], count: items.count)
                        for i in 0..<items.count {
                            group.enter()
                            var product: [String: Any] = [:]
                            let item = items[i]
                            product["defaultIndex"] = i
                            if let title = item["title"].string {
                                product["title"] = title
                            }
                            if let price = item["buyItNowPrice"]["__value__"].string {
                                product["price"] = Float(price)
                            }
                            if let shippingCost = item["shippingCost"]["__value__"].string {
                                product["shippingCost"] = Float(shippingCost)
                            }
                            if let timeLeft = item["timeLeft"].string {
                                let indexP = timeLeft.firstIndex(of: "P")!
                                let indexB = timeLeft.index(indexP, offsetBy: 1, limitedBy: timeLeft.endIndex)!
                                let indexD = timeLeft.firstIndex(of: "D")!
                                product["daysLeft"] = Int(String(timeLeft[indexB..<indexD]))
                            }
                            if let linkURL = item["viewItemURL"].string {
                                product["linkURL"] = linkURL
                            }
                            Alamofire.request(item["imageURL"].string!).responseImage { response in
                                if let image = response.result.value {
                                    product["image"] = image
                                }
                                self.products[i] = product
                                group.leave()
                            }
                        }
                        group.notify(queue: DispatchQueue.main) {
                            self.collectionView.reloadData()
                            self.lblSortBy.isHidden = false
                            self.segSortBy.isHidden = false
                            self.lblOrder.isHidden = false
                            self.segOrder.isHidden = false
                            self.collectionView.isHidden = false
                            SwiftSpinner.hide()
                        }
                    }
                    else {
                        self.lblNoSimilar.isHidden = false
                        SwiftSpinner.hide()
                        return
                    }
                case .failure(let error):
                    print(error)
                    self.lblNoSimilar.isHidden = false
                    SwiftSpinner.hide()
                    return
                }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = products[indexPath.row]["linkURL"] as? String{
            UIApplication.shared.open(URL(string: url)!)
        }
    }
    
    @IBAction func sortProducts(_ sender: UISegmentedControl) {
        if segSortBy.selectedSegmentIndex == 0 {
            products.sort(by: { ($0["defaultIndex"] as! Int) < ($1["defaultIndex"] as! Int) })
            segOrder.isEnabled = false
        } else if segSortBy.selectedSegmentIndex == 1 {
            if segOrder.selectedSegmentIndex == 0 {
                products.sort(by: { ($0["title"] as! String) < ($1["title"] as! String) })
            } else {
                products.sort(by: { ($0["title"] as! String) > ($1["title"] as! String) })
            }
            segOrder.isEnabled = true
        } else if segSortBy.selectedSegmentIndex == 2 {
            if segOrder.selectedSegmentIndex == 0 {
                products.sort(by: { ($0["price"] as! Float) < ($1["price"] as! Float) })
            } else {
                products.sort(by: { ($0["price"] as! Float) > ($1["price"] as! Float) })
            }
            segOrder.isEnabled = true
        } else if segSortBy.selectedSegmentIndex == 3 {
            if segOrder.selectedSegmentIndex == 0 {
                products.sort(by: { ($0["daysLeft"] as! Int) < ($1["daysLeft"] as! Int) })
            } else {
                products.sort(by: { ($0["daysLeft"] as! Int) > ($1["daysLeft"] as! Int) })
            }
            segOrder.isEnabled = true
        } else {
            if segOrder.selectedSegmentIndex == 0 {
                products.sort(by: { ($0["shippingCost"] as! Float) < ($1["shippingCost"] as! Float) })
            } else {
                products.sort(by: { ($0["shippingCost"] as! Float) > ($1["shippingCost"] as! Float) })
            }
            segOrder.isEnabled = true
        }
        collectionView.reloadData()
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
