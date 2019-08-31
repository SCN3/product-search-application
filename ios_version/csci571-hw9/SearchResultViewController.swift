//
//  SearchResultViewController.swift
//  csci571-hw9
//
//  Created by scn3 on 4/15/19.
//  Copyright © 2019 scn3. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class SearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var items: [JSON] = []
    var rowSelected: Int = 0
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tableItem: UITableView!
    @IBOutlet weak var topBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableItem.rowHeight = 100
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        let item = items[indexPath.row]
        print(item)
        cell.setContent(itemId: item["itemId"][0].string!, imgUrl: item["galleryURL"][0].string!, title: item["title"][0].string!, price: item["sellingStatus"][0]["currentPrice"][0]["__value__"].string!, shipping: item["shippingInfo"][0]["shippingServiceCost"][0]["__value__"].string!, zipcode: item["postalCode"][0].string!, conditionId: item["condition"][0]["conditionId"][0].string!, inWishList: false)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowSelected = indexPath.row
        performSegue(withIdentifier: "ResultToDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        if let detailViewController = segue.destination as? DetailViewController {
            let item = items[rowSelected]
            detailViewController.itemId = item["itemId"][0].string!
            detailViewController.itemImgUrl = item["galleryURL"][0].string!
            detailViewController.itemTitle = item["title"][0].string!
            detailViewController.itemPrice = item["sellingStatus"][0]["currentPrice"][0]["__value__"].string!
            detailViewController.itemShipping = item["shippingInfo"][0]["shippingServiceCost"][0]["__value__"].string!
            detailViewController.itemZipcode = item["postalCode"][0].string!
            detailViewController.itemConditionId = item["condition"][0]["conditionId"][0].string!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableItem.reloadData()
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
