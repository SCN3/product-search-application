//
//  ShippingTabViewController.swift
//  csci571-hw9
//
//  Created by scn3 on 4/16/19.
//  Copyright © 2019 scn3. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire

class ShippingTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let strSeller = "Seller"
    let strShippingInfo = "Shipping Info"
    let strReturnPolicy = "Return Policy"
    
    var sectionTitles: [String] = []
    var rowName: [[String]] = []
    var rowValue: [[String]] = []
    var storeUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
//        sectionTitles = [strSeller, strShippingInfo, strReturnPolicy]
//        rowName.append(["Store Name", "Feedback Score", "Popularity", "Feedback Star"])
//        rowName.append(["Shipping Cost", "Global Shipping", "Handling Time"])
//        rowName.append(["Policy", "Refund Mode", "Return Within", "Shipping Cost Paid By"])
//        rowValue.append(["BrightEyed1", "14889", "98.8", "10001"])
//        rowValue.append(["FREE", "No", "1 day"])
//        rowValue.append(["Returns Accepted", "Money Back", "30 Days", "Buyer"])
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowName[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: sectionTitles[section]))
        imageView.frame = CGRect(x: 5, y: 9, width: 28, height: 28)
        view.addSubview(imageView)
        let label = UILabel()
        label.text = sectionTitles[section]
        label.frame = CGRect(x: 38, y: 9, width: 200, height: 28)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(label)
        let topSeparatorView = UIView()
        topSeparatorView.frame = CGRect(x: 5, y: 6, width: 365, height: 1)
        topSeparatorView.backgroundColor = UIColor(white: 224.0/255.0, alpha: 1.0)
        view.addSubview(topSeparatorView)
        let bottomSeparatorView = UIView()
        bottomSeparatorView.frame = CGRect(x: 5, y: 39, width: 365, height: 1)
        bottomSeparatorView.backgroundColor = UIColor(white: 224.0/255.0, alpha: 1.0)
        view.addSubview(bottomSeparatorView)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let lines: Int = (rowValue[indexPath.section][indexPath.row].count - 1) / 20 + 1
        let re = CGFloat(4 + lines * 22)
        return re
//        return 26
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "ShippingInfoTableViewCell")
//        if cell == nil {
//            cell = UITableViewCell(style: .default, reuseIdentifier: "ShippingInfoTableViewCell")
//        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ShippingInfoTableViewCell")
        let lblName = UILabel()
        lblName.text = rowName[indexPath.section][indexPath.row]
        lblName.frame = CGRect(x: 10, y: 3, width: 175, height: 22)
        lblName.textAlignment = .center
        lblName.textColor = UIColor.darkGray
        lblName.font = UIFont.boldSystemFont(ofSize: 16)
        cell.addSubview(lblName)
        if rowName[indexPath.section][indexPath.row] == "Feedback Star" {
            var starColor = rowValue[indexPath.section][indexPath.row]
            var imageName = "starBorder"
            if starColor.range(of: "Shooting") != nil {
                imageName = "star"
                starColor.removeSubrange(starColor.range(of: "Shooting")!)
            }
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.frame = CGRect(x: 266, y: 3, width: 22, height: 22)
            if starColor == "Yellow" {
                imageView.tintColor = UIColor.yellow
            } else if starColor == "Blue" {
                imageView.tintColor = UIColor.blue
            } else if starColor == "Purple" {
                imageView.tintColor = UIColor.purple
            } else if starColor == "Red" {
                imageView.tintColor = UIColor.red
            } else if starColor == "Green" {
                imageView.tintColor = UIColor.green
            } else if starColor == "Turquoise" {
                imageView.tintColor = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
            } else if starColor == "Silver" {
                imageView.tintColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
            }
            cell.addSubview(imageView)
        } else {
            let lblValue = UILabel()
            lblValue.text = rowValue[indexPath.section][indexPath.row]
            lblValue.textAlignment = .center
            lblValue.textColor = UIColor.darkGray
            lblValue.font = UIFont.systemFont(ofSize: 16)
            lblValue.numberOfLines = (rowValue[indexPath.section][indexPath.row].count - 1) / 20 + 1
            lblValue.frame = CGRect(x: 190, y: 3, width: 175, height: 22 * lblValue.numberOfLines)
            if rowName[indexPath.section][indexPath.row] == "Store Name" {
                lblValue.textColor = UIColor.blue
                lblValue.attributedText = NSAttributedString(string: rowValue[indexPath.section][indexPath.row], attributes:
                    [.underlineStyle: NSUnderlineStyle.single.rawValue])
                let tap = UITapGestureRecognizer(target: self, action: #selector(openStoreLink))
                lblValue.isUserInteractionEnabled = true
                lblValue.addGestureRecognizer(tap)
            }
            cell.addSubview(lblValue)
        }
        return cell
    }
    
    @objc func openStoreLink(sender: UITapGestureRecognizer) {
        UIApplication.shared.open(URL(string: storeUrl)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let detailViewController = tabBarController as! DetailViewController
        tableView.isHidden = true
        SwiftSpinner.show("Fetching Shipping Data...")
        let itemId = detailViewController.itemId
        Alamofire.request("http://backend-dot-csci571-hw8-235604.appspot.com/detail?itemId=" + itemId).validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let item = json["Item"]
                    
                    self.sectionTitles.removeAll()
                    self.rowName.removeAll()
                    self.rowValue.removeAll()
                    
                    var sectionSellerName: [String] = []
                    var sectionSellerValue: [String] = []
                    if let storeName = item["Storefront"]["StoreName"].string {
                        sectionSellerName.append("Store Name")
                        sectionSellerValue.append(storeName)
                    }
                    if let storeURL = item["Storefront"]["StoreURL"].string {
                        self.storeUrl = storeURL
                    }
                    if let feedbackScore = item["Seller"]["FeedbackScore"].int {
                        sectionSellerName.append("Feedback Score")
                        sectionSellerValue.append(String(feedbackScore))
                    }
                    if let popularity = item["Seller"]["PositiveFeedbackPercent"].float {
                        sectionSellerName.append("Popularity")
                        sectionSellerValue.append(String(popularity))
                    }
                    if let feedbackStar = item["Seller"]["FeedbackRatingStar"].string {
                        sectionSellerName.append("Feedback Star")
                        sectionSellerValue.append(feedbackStar)
                    }
                    if sectionSellerName.count > 0 {
                        self.sectionTitles.append("Seller")
                        self.rowName.append(sectionSellerName)
                        self.rowValue.append(sectionSellerValue)
                    }
                    
                    var sectionShippingInfoName: [String] = []
                    var sectionShippingInfoValue: [String] = []
                    sectionShippingInfoName.append("Shipping Cost")
                    if detailViewController.itemShipping == "0.0" {
                        sectionShippingInfoValue.append("FREE")
                    } else {
                        sectionShippingInfoValue.append(detailViewController.itemShipping)
                    }
                    if let globalShipping = item["GlobalShipping"].bool {
                        sectionShippingInfoName.append("Global Shipping")
                        if globalShipping {
                            sectionShippingInfoValue.append("Yes")
                        } else {
                            sectionShippingInfoValue.append("No")
                        }
                    }
                    if let handlingTime = item["HandlingTime"].string {
                        sectionShippingInfoName.append("Handling Time")
                        sectionShippingInfoValue.append(handlingTime)
                    }
                    if sectionShippingInfoName.count > 0 {
                        self.sectionTitles.append("Shipping Info")
                        self.rowName.append(sectionShippingInfoName)
                        self.rowValue.append(sectionShippingInfoValue)
                    }
                    
                    var sectionReturnPolicyName: [String] = []
                    var sectionReturnPolicyValue: [String] = []
                    if let returnsAccepted = item["ReturnPolicy"]["ReturnsAccepted"].string {
                        sectionReturnPolicyName.append("Policy")
                        sectionReturnPolicyValue.append(returnsAccepted)
                    }
                    if let refundMode = item["ReturnPolicy"]["Refund"].string {
                        sectionReturnPolicyName.append("Refund Mode")
                        sectionReturnPolicyValue.append(refundMode)
                    }
                    if let returnsWithin = item["ReturnPolicy"]["ReturnsWithin"].string {
                        sectionReturnPolicyName.append("Return Within")
                        sectionReturnPolicyValue.append(returnsWithin)
                    }
                    if let paidBy = item["ReturnPolicy"]["ShippingCostPaidBy"].string {
                        sectionReturnPolicyName.append("Shipping Cost Paid By")
                        sectionReturnPolicyValue.append(paidBy)
                    }
                    if sectionReturnPolicyName.count > 0 {
                        self.sectionTitles.append("Return Policy")
                        self.rowName.append(sectionReturnPolicyName)
                        self.rowValue.append(sectionReturnPolicyValue)
                    }
                    
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                    SwiftSpinner.hide()
                case .failure(let error):
                    print(error)
                    self.tableView.isHidden = false
                    SwiftSpinner.hide()
                }
        }
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
