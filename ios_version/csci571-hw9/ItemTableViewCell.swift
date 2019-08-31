//
//  ItemTableViewCell.swift
//  csci571-hw9
//
//  Created by scn3 on 4/15/19.
//  Copyright © 2019 scn3. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
import Toast_Swift

class ItemTableViewCell: UITableViewCell {

    let imgWishListEmpty = UIImage(named: "wishListEmpty")
    let imgWishListFilled = UIImage(named: "wishListFilled")
    
    var itemId: String = ""
    var imgUrl: String = ""
    var title: String = ""
    var price: String = ""
    var shipping: String = ""
    var zipcode: String = ""
    var conditionId: String = ""
    var inWishList: Bool = false
    var itemInWishList: Bool = false
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblShipping: UILabel!
    @IBOutlet weak var lblZipcode: UILabel!
    @IBOutlet weak var lblCondition: UILabel!
    @IBOutlet weak var btnWishList: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setContent(itemId: String, imgUrl: String, title: String, price: String, shipping: String, zipcode: String, conditionId: String, inWishList: Bool) {
        self.itemId = itemId
        self.imgUrl = imgUrl
        self.title = title
        self.price = price
        self.shipping = shipping
        self.zipcode = zipcode
        self.conditionId = conditionId
        self.inWishList = inWishList
        
        Alamofire.request(imgUrl).responseImage { response in
            if let image = response.result.value {
                self.img.image = image
            }
        }
        lblTitle.text = title
        lblPrice.text = "$" + price
        if shipping == "0.0" {
            lblShipping.text = "FREE SHIPPING"
        } else {
            lblShipping.text = "$" + shipping
        }
        lblZipcode.text = zipcode
        if conditionId == "1000" {
            lblCondition.text = "NEW"
        } else if conditionId == "2000" || conditionId == "2500" {
            lblCondition.text = "REFURBISHED"
        } else if conditionId == "3000" || conditionId == "4000" || conditionId == "5000" || conditionId == "6000" {
            lblCondition.text = "USED"
        } else {
            lblCondition.text = "NA"
        }
        if inWishList {
            btnWishList.isHidden = true
            itemInWishList = true
        } else {
            var itemIds: [String] = []
            if UserDefaults.standard.array(forKey: "itemIds") != nil {
                itemIds = UserDefaults.standard.array(forKey: "itemIds") as! [String]
            }
            if itemIds.contains(itemId) {
                btnWishList.setImage(imgWishListFilled, for: UIControl.State.normal)
                itemInWishList = true
            } else {
                btnWishList.setImage(imgWishListEmpty, for: UIControl.State.normal)
                itemInWishList = false
            }
        }
    }
    
    @IBAction func toggleWishList(_ sender: UIButton) {
        if itemInWishList {
            itemInWishList = false
            var itemIds: [String] = []
            if UserDefaults.standard.array(forKey: "itemIds") != nil {
                itemIds = UserDefaults.standard.array(forKey: "itemIds") as! [String]
            }
            itemIds.remove(at: itemIds.firstIndex(of: itemId)!)
            UserDefaults.standard.set(itemIds, forKey: "itemIds")
            UserDefaults.standard.removeObject(forKey: itemId + "imgUrl")
            UserDefaults.standard.removeObject(forKey: itemId + "title")
            UserDefaults.standard.removeObject(forKey: itemId + "price")
            UserDefaults.standard.removeObject(forKey: itemId + "shipping")
            UserDefaults.standard.removeObject(forKey: itemId + "zipcode")
            UserDefaults.standard.removeObject(forKey: itemId + "conditionId")
            sender.setImage(imgWishListEmpty, for: UIControl.State.normal)
            self.superview?.superview?.makeToast(title + " was removed from wishList")
        } else {
            itemInWishList = true
            var itemIds: [String] = []
            if UserDefaults.standard.array(forKey: "itemIds") != nil {
                itemIds = UserDefaults.standard.array(forKey: "itemIds") as! [String]
            }
            itemIds.append(itemId)
            UserDefaults.standard.set(itemIds, forKey: "itemIds")
            UserDefaults.standard.set(imgUrl, forKey: itemId + "imgUrl")
            UserDefaults.standard.set(title, forKey: itemId + "title")
            UserDefaults.standard.set(price, forKey: itemId + "price")
            UserDefaults.standard.set(shipping, forKey: itemId + "shipping")
            UserDefaults.standard.set(zipcode, forKey: itemId + "zipcode")
            UserDefaults.standard.set(conditionId, forKey: itemId + "conditionId")
            sender.setImage(imgWishListFilled, for: UIControl.State.normal)
            self.superview?.superview?.makeToast(title + " was added to the wishList")
        }
    }
}
