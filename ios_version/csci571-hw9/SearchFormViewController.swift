//
//  ViewController.swift
//  productSearch
//
//  Created by scn3 on 4/11/19.
//  Copyright © 2019 scn3. All rights reserved.
//

import UIKit
import McPicker
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Toast_Swift

class SearchFormViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var mainView: UIView!
    
    let imgChecked = UIImage(named: "checked")!
    let imgUnchecked = UIImage(named: "unchecked")!
    
    var conditionNew = false
    var conditionUsed = false
    var conditionUnspecified = false
    var shippingPickup = false
    var shippingFreeShipping = false
    
    var zipcodes: [String] = []
    var currentLocation: String = "90001"
    
    var items: [JSON] = []
    var parameters: [String: Any] = [:]
    
    var itemIdSelected: String = ""
    var itemImgUrlSelected: String = ""
    var itemTitleSelected: String = ""
    var itemPriceSelected: String = ""
    var itemShippingSelected: String = ""
    var itemZipcodeSelected: String = ""
    var itemConditionIdSelected: String = ""
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var wishListView: UIView!
    
    @IBOutlet weak var txtKeyword: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtDistance: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet weak var btnNew: UIButton!
    @IBOutlet weak var btnUsed: UIButton!
    @IBOutlet weak var btnUnspecified: UIButton!
    @IBOutlet weak var btnPickup: UIButton!
    @IBOutlet weak var btnFreeShipping: UIButton!
    
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    
    @IBOutlet weak var tableZipcode: UITableView!
    
    @IBOutlet weak var switchLocation: UISwitch!
    
    @IBOutlet weak var lblWishListTotalItems: UILabel!
    @IBOutlet weak var lblWishListTotalDollars: UILabel!
    @IBOutlet weak var lblNoItems: UILabel!
    
    @IBOutlet weak var tableItem: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtCategory.text = "All"
        txtDistance.placeholder = "10"
        txtLocation.placeholder = "Zipcode"
        tableZipcode.layer.borderWidth = 2.0
        tableZipcode.layer.borderColor = UIColor.gray.cgColor
        tableZipcode.layer.cornerRadius = 6.0
        tableZipcode.rowHeight = 30
        tableZipcode.delegate = self
        tableZipcode.dataSource = self
        tableItem.rowHeight = 100
        tableItem.delegate = self
        tableItem.dataSource = self
        
        Alamofire.request("http://ip-api.com/json").validate()
            .responseJSON{response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let zip = json["zip"].string {
                        self.currentLocation = zip
                    }
                case .failure(let error):
                    print(error)
                }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func dealWithCheckBoxes(btn : UIButton, label : inout Bool) {
        if label {
            label = false
            btn.setImage(imgUnchecked, for: UIControl.State.normal)
        } else {
            label = true
            btn.setImage(imgChecked, for: UIControl.State.normal)
        }
        btn.tintColor = UIColor.black
    }
    
    func validateInput(testString: String) -> Bool {
        let range = NSRange(location: 0, length: testString.utf16.count)
        let regex = try! NSRegularExpression(pattern: "\\S")
        return regex.firstMatch(in: testString, options: [], range: range) != nil
    }
    
    @IBAction func toggleView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            searchView.isHidden = false
            wishListView.isHidden = true
        } else {
            searchView.isHidden = true
            wishListView.isHidden = false
            tableItem.reloadData()
        }
    }
    
    @IBAction func touchCheckBoxes(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            dealWithCheckBoxes(btn: sender, label: &conditionNew)
        case 2:
            dealWithCheckBoxes(btn: sender, label: &conditionUsed)
        case 3:
            dealWithCheckBoxes(btn: sender, label: &conditionUnspecified)
        case 4:
            dealWithCheckBoxes(btn: sender, label: &shippingPickup)
        case 5:
            dealWithCheckBoxes(btn: sender, label: &shippingFreeShipping)
        default:
            break
        }
    }
    
    @IBAction func categoryPick(_ sender: Any) {
        McPicker.show(data: [["All", "Art", "Baby", "Books", "Clothing, Shoes & Accesories", "Computer/Tablets & Networking", "Heath & Beauty", "Music", "Video Games & Consoles"]]) {  [weak self] (selections: [Int : String]) -> Void in
            if let category = selections[0] {
                self?.txtCategory.text = category
                self?.txtKeyword.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func locationSwitch(_ sender: UISwitch) {
        if sender.isOn {
            btnSearch.frame.origin = CGPoint(x: 25, y: 460)
            btnClear.frame.origin = CGPoint(x: 200, y: 460)
            txtLocation.isHidden = false
        } else {
            btnSearch.frame.origin = CGPoint(x: 25, y: 420)
            btnClear.frame.origin = CGPoint(x: 200, y: 420)
            txtLocation.isHidden = true
            tableZipcode.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if tableView == tableZipcode {
            numberOfRows = zipcodes.count
        } else {
            if let itemIds = UserDefaults.standard.array(forKey: "itemIds") {
                numberOfRows = itemIds.count
            } else {
                numberOfRows = 0
            }
            if (numberOfRows == 0) {
                lblWishListTotalItems.isHidden = true
                lblWishListTotalDollars.isHidden = true
                tableItem.isHidden = true
                lblNoItems.isHidden = false
            } else {
                lblWishListTotalItems.isHidden = false
                lblWishListTotalDollars.isHidden = false
                tableItem.isHidden = false
                lblNoItems.isHidden = true
                if numberOfRows == 1 {
                    lblWishListTotalItems.text = "WishList Total(1 item):"
                } else {
                    lblWishListTotalItems.text = "WishList Total(" + String(numberOfRows) + " items):"
                }
                var totalPrice: Float = 0.0
                var itemIds: [String] = []
                if UserDefaults.standard.array(forKey: "itemIds") != nil {
                    itemIds = UserDefaults.standard.array(forKey: "itemIds") as! [String]
                }
                for i in 0..<itemIds.count {
                    totalPrice += Float(UserDefaults.standard.string(forKey: itemIds[i] + "price")!)!
                }
                lblWishListTotalDollars.text = "$" + String(totalPrice)
            }
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableZipcode {
            var cell: UITableViewCell = UITableViewCell()
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "autoCompleteCell")
            cell.textLabel?.text = zipcodes[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
            var itemIds: [String] = []
            if UserDefaults.standard.array(forKey: "itemIds") != nil {
                itemIds = UserDefaults.standard.array(forKey: "itemIds") as! [String]
            }
            let itemId = itemIds[indexPath.row]
            cell.setContent(itemId: itemId, imgUrl: UserDefaults.standard.string(forKey: itemId + "imgUrl")!, title: UserDefaults.standard.string(forKey: itemId + "title")!, price: UserDefaults.standard.string(forKey: itemId + "price")!, shipping: UserDefaults.standard.string(forKey: itemId + "shipping")!, zipcode: UserDefaults.standard.string(forKey: itemId + "zipcode")!, conditionId: UserDefaults.standard.string(forKey: itemId + "conditionId")!, inWishList: true)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableZipcode {
            txtLocation.text = zipcodes[indexPath.row]
            tableZipcode.isHidden = true
        } else {
            var itemIds: [String] = []
            if UserDefaults.standard.array(forKey: "itemIds") != nil {
                itemIds = UserDefaults.standard.array(forKey: "itemIds") as! [String]
            }
            itemIdSelected = itemIds[indexPath.row]
            itemImgUrlSelected = UserDefaults.standard.string(forKey: itemIdSelected + "imgUrl")!
            itemTitleSelected = UserDefaults.standard.string(forKey: itemIdSelected + "title")!
            itemPriceSelected = UserDefaults.standard.string(forKey: itemIdSelected + "price")!
            itemShippingSelected = UserDefaults.standard.string(forKey: itemIdSelected + "shipping")!
            itemZipcodeSelected = UserDefaults.standard.string(forKey: itemIdSelected + "zipcode")!
            itemConditionIdSelected = UserDefaults.standard.string(forKey: itemIdSelected + "conditionId")!
            performSegue(withIdentifier: "SearchFormToDetail", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == tableZipcode {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == tableZipcode {
            
        } else {
            if editingStyle == .delete {
                var itemIds: [String] = []
                if UserDefaults.standard.array(forKey: "itemIds") != nil {
                    itemIds = UserDefaults.standard.array(forKey: "itemIds") as! [String]
                }
                let itemId = itemIds[indexPath.row]
                itemIds.remove(at: indexPath.row)
                UserDefaults.standard.set(itemIds, forKey: "itemIds")
                UserDefaults.standard.removeObject(forKey: itemId + "imgUrl")
                UserDefaults.standard.removeObject(forKey: itemId + "title")
                UserDefaults.standard.removeObject(forKey: itemId + "price")
                UserDefaults.standard.removeObject(forKey: itemId + "shipping")
                UserDefaults.standard.removeObject(forKey: itemId + "zipcode")
                UserDefaults.standard.removeObject(forKey: itemId + "conditionId")
                tableItem.reloadData()
            }
        }
    }
    
    @IBAction func getZipcodeAutocomplete(_ sender: Any) {
        let curZipcode: String = self.txtLocation.text!
        if curZipcode.utf16.count == 0 {
            tableZipcode.isHidden = true
            return
        }
        Alamofire.request("http://backend-dot-csci571-hw8-235604.appspot.com/auto-complete", parameters: ["starts_with": curZipcode]).validate()
            .responseJSON{response in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        if let postalCodes = json["postalCodes"].array {
                            self.zipcodes.removeAll()
                            for i in 0..<postalCodes.count {
                                if let zipcode = postalCodes[i]["postalCode"].string {
                                    self.zipcodes.append(zipcode)
                                }
                            }
                            if self.zipcodes.count == 0 {
                                self.tableZipcode.isHidden = true
                                return
                            }
                            self.tableZipcode.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                }
        }
        tableZipcode.isHidden = false
    }
    
    @IBAction func search(_ sender: UIButton) {
        parameters = [:]
        let keyword: String = txtKeyword.text!
        if !validateInput(testString: keyword) {
            mainView.makeToast("Keyword Is Mandatory")
            return
        } else {
            parameters["keyword"] = keyword
        }
        var zipcode: String
        if switchLocation.isOn {
            zipcode = txtLocation.text!
        } else {
            zipcode = currentLocation
        }
        if !validateInput(testString: zipcode) {
            mainView.makeToast("Zipcode Is Mandatory")
            return
        } else {
            parameters["zipcode"] = zipcode
        }
        let category: String = txtCategory.text!
        if category == "All" {
            parameters["category"] = "All Categories"
        } else {
            parameters["category"] = category
        }
        var condition: [String] = []
        if conditionNew {
            condition.append("New")
        }
        if conditionUsed {
            condition.append("Used")
        }
        if conditionUnspecified {
            condition.append("Unspecified")
        }
        if condition.count == 0 {
            condition.append("All")
        }
        parameters["condition"] = condition
        var shipping: [String] = []
        if shippingPickup {
            shipping.append("Pickup")
        }
        if shippingFreeShipping {
            shipping.append("FreeShipping")
        }
        if shipping.count == 0 {
            shipping.append("All")
        }
        parameters["shipping_options"] = shipping
        var distance: String
        if txtDistance.text == "" {
            distance = "10"
        } else {
            distance = txtDistance.text!
        }
        parameters["distance"] = distance
        performSegue(withIdentifier: "SearchFormToResult", sender: nil)
    }
    
    @IBAction func clear(_ sender: UIButton) {
        txtKeyword.text = ""
        txtCategory.text = "All"
        conditionNew = true
        dealWithCheckBoxes(btn: btnNew, label: &conditionNew)
        conditionUsed = true
        dealWithCheckBoxes(btn: btnUsed, label: &conditionUsed)
        conditionUnspecified = true
        dealWithCheckBoxes(btn: btnUnspecified, label: &conditionUnspecified)
        shippingPickup = true
        dealWithCheckBoxes(btn: btnPickup, label: &shippingPickup)
        shippingFreeShipping = true
        dealWithCheckBoxes(btn: btnFreeShipping, label: &shippingFreeShipping)
        txtDistance.text = ""
        switchLocation.isOn = false
        btnSearch.frame.origin = CGPoint(x: 25, y: 420)
        btnClear.frame.origin = CGPoint(x: 200, y: 420)
        txtLocation.isHidden = true
        tableZipcode.isHidden = true
        txtLocation.text = ""
        mainView.hideAllToasts()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view != tableZipcode {
            tableZipcode.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        if segue.identifier == "SearchFormToResult" {
            if let searchResultViewController = segue.destination as? SearchResultViewController {
                    searchResultViewController.items = self.items
            }
        } else {
            if let detailViewController = segue.destination as? DetailViewController {
                detailViewController.itemId = itemIdSelected
                detailViewController.itemImgUrl = itemImgUrlSelected
                detailViewController.itemTitle = itemTitleSelected
                detailViewController.itemPrice = itemPriceSelected
                detailViewController.itemShipping = itemShippingSelected
                detailViewController.itemZipcode = itemZipcodeSelected
                detailViewController.itemConditionId = itemConditionIdSelected
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableItem.reloadData()
    }
}
