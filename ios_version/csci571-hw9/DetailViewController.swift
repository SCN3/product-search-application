//
//  DetailViewController.swift
//  csci571-hw9
//
//  Created by scn3 on 4/16/19.
//  Copyright © 2019 scn3. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftyJSON

class DetailViewController: UITabBarController {

    let imgFacebook = UIImage(named: "facebook")
    let imgWishListEmpty = UIImage(named: "wishListEmpty")
    let imgWishListFilled = UIImage(named: "wishListFilled")
    
    var itemId: String = ""
    var itemImgUrl: String = ""
    var itemTitle: String = ""
    var itemPrice: String = ""
    var itemShipping: String = ""
    var itemZipcode: String = ""
    var itemConditionId: String = ""
    var itemUrl: String = ""
    var itemInWishList: Bool = false
    
    var item: JSON = JSON()
    var similarItems: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var itemIds: [String] = []
        if UserDefaults.standard.array(forKey: "itemIds") != nil {
            itemIds = UserDefaults.standard.array(forKey: "itemIds") as! [String]
        }
        itemInWishList = itemIds.contains(itemId)
        
        let imgWishList = itemInWishList ? imgWishListFilled: imgWishListEmpty
        let btnFacebook = UIBarButtonItem(image: imgFacebook, style: .plain, target: self, action: #selector(didTapbtnFacebook(_:)))
        let btnWishList = UIBarButtonItem(image: imgWishList, style: .plain, target: self, action: #selector(didTapbtnWishList(_:)))
        
        navigationItem.rightBarButtonItems = [btnWishList, btnFacebook]
        
        // Do any additional setup after loading the view.
    }
    
    @objc func didTapbtnFacebook(_ sender: Any) {
        var facebookUrl = "https://www.facebook.com/v3.2/dialog/share?app_id=660476781053903&channel_url=https%3A%2F%2Fstaticxx.facebook.com%2Fconnect%2Fxd_arbiter%2Fr%2Fd_vbiawPdxB.js%3Fversion%3D44%23cb%3Df185ed468472cb%26domain%3Dlocalhost%26origin%3Dhttp%253A%252F%252Flocalhost%253A63342%252Ff2c7a6d16b16156%26relation%3Dopener&locale=en_US&sdk=joey&version=v3.2"
        let customAllowedSet = NSCharacterSet(charactersIn: "&").inverted.intersection(.urlQueryAllowed)
        let quote: String = "Buy " + itemTitle + " for $" + itemPrice + " from Ebay!"
        facebookUrl += "&quote=" + quote.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        facebookUrl += "&href=" + itemUrl.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        let hashtag: String = "#CSCI571Spring2019Ebay"
        facebookUrl += "&hashtag=" + hashtag.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        UIApplication.shared.open(URL(string: facebookUrl)!)
    }
    
    @objc func didTapbtnWishList(_ sender: UIBarButtonItem) {
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
            sender.image = imgWishListEmpty
            switch selectedIndex {
            case 0:
                let vc = selectedViewController as! InfoTabViewController
                vc.mainView.makeToast(itemTitle + " was removed from wishList")
            case 1:
                let vc = selectedViewController as!ShippingTabViewController
                vc.mainView.makeToast(itemTitle + " was removed from wishList")
            case 2:
                let vc = selectedViewController as! PhotosTabViewController
                vc.mainView.makeToast(itemTitle + " was removed from wishList")
            case 3:
                let vc = selectedViewController as! SimilarTabViewController
                vc.mainView.makeToast(itemTitle + " was removed from wishList")
            default:
                break
            }
        } else {
            itemInWishList = true
            var itemIds: [String] = []
            if UserDefaults.standard.array(forKey: "itemIds") != nil {
                itemIds = UserDefaults.standard.array(forKey: "itemIds") as! [String]
            }
            itemIds.append(itemId)
            UserDefaults.standard.set(itemIds, forKey: "itemIds")
            UserDefaults.standard.set(itemImgUrl, forKey: itemId + "imgUrl")
            UserDefaults.standard.set(itemTitle, forKey: itemId + "title")
            UserDefaults.standard.set(itemPrice, forKey: itemId + "price")
            UserDefaults.standard.set(itemShipping, forKey: itemId + "shipping")
            UserDefaults.standard.set(itemZipcode, forKey: itemId + "zipcode")
            UserDefaults.standard.set(itemConditionId, forKey: itemId + "conditionId")
            sender.image = imgWishListFilled
            switch selectedIndex {
            case 0:
                let vc = selectedViewController as! InfoTabViewController
                vc.mainView.makeToast(itemTitle + " was added to the wishList")
            case 1:
                let vc = selectedViewController as!ShippingTabViewController
                vc.mainView.makeToast(itemTitle + " was added to the wishList")
            case 2:
                let vc = selectedViewController as! PhotosTabViewController
                vc.mainView.makeToast(itemTitle + " was added to the wishList")
            case 3:
                let vc = selectedViewController as! SimilarTabViewController
                vc.mainView.makeToast(itemTitle + " was added to the wishList")
            default:
                break
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
