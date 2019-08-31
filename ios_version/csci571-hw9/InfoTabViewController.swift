//
//  InfoTabViewController.swift
//  csci571-hw9
//
//  Created by scn3 on 4/16/19.
//  Copyright © 2019 scn3. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import SwiftSpinner

class InfoTabViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imagePageControl: UIPageControl!
    
    @IBOutlet weak var lblItemTitle: UILabel!
    @IBOutlet weak var lblItemPrice: UILabel!
    @IBOutlet weak var imgDescription: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var descriptionTable: UITableView!
    
    var imageUrls: [String] = []
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var itemTitle: String = ""
    var itemPrice: String = ""
    var itemDescription: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTable.allowsSelection = false
        // Do any additional setup after loading the view.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = imageScrollView.contentOffset.x / imageScrollView.frame.size.width
        imagePageControl.currentPage = Int(pageNumber)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDescription.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTableViewCell", for: indexPath) as! DescriptionTableViewCell
        cell.setLabel(lblName: itemDescription[indexPath.row]["Name"].string!, lblValue: itemDescription[indexPath.row]["Value"][0].string!)
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let detailViewController = tabBarController as! DetailViewController
        SwiftSpinner.show("Fetching Product Details...")
        imageScrollView.isHidden = true
        imagePageControl.isHidden = true
        lblItemTitle.isHidden = true
        lblItemPrice.isHidden = true
        imgDescription.isHidden = true
        lblDescription.isHidden = true
        descriptionTable.isHidden = true
        let itemId = detailViewController.itemId
        itemTitle = detailViewController.itemTitle
        itemPrice = detailViewController.itemPrice
        Alamofire.request("http://backend-dot-csci571-hw8-235604.appspot.com/detail?itemId=" + itemId).validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let item = json["Item"]
                    if let description = item["ItemSpecifics"]["NameValueList"].array {
                        self.itemDescription = description
                    } else {
                        self.itemDescription = []
                    }
                    self.imageUrls.removeAll()
                    if let urls = item["PictureURL"].array {
                        for i in 0..<urls.count {
                            self.imageUrls.append(urls[i].string!)
                        }
                    }
                    detailViewController.itemUrl = item["ViewItemURLForNaturalSearch"].string!
                    self.setContent()
                case .failure(let error):
                    print(error)
                    SwiftSpinner.hide()
                }
        }
    }
    
    func setContent() {
        descriptionTable.rowHeight = 24
        imagePageControl.numberOfPages = imageUrls.count
        let group = DispatchGroup()
        var images: [UIImage] = Array(repeating: UIImage(), count: imageUrls.count)
        for i in 0..<imageUrls.count {
            group.enter()
            Alamofire.request(imageUrls[i]).responseImage { response in
                if let image = response.result.value {
                    images[i] = image
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            for i in 0..<images.count {
                self.frame.origin.x = self.imageScrollView.frame.size.width * CGFloat(i)
                self.frame.size = self.imageScrollView.frame.size
                
                let imgView = UIImageView(frame: self.frame)
                imgView.image = images[i]
                self.imageScrollView.addSubview(imgView)
            }
            self.imageScrollView.contentSize = CGSize(width: (self.imageScrollView.frame.size.width * CGFloat(images.count)), height: self.imageScrollView.frame.size.height)
            self.imageScrollView.delegate = self
            self.lblItemTitle.text = self.itemTitle
            self.lblItemPrice.text = "$" + self.itemPrice
            self.descriptionTable.reloadData()
            self.imageScrollView.isHidden = false
            self.imagePageControl.isHidden = false
            self.lblItemTitle.isHidden = false
            self.lblItemPrice.isHidden = false
            if self.itemDescription.count > 0 {
                self.imgDescription.isHidden = false
                self.lblDescription.isHidden = false
                self.descriptionTable.isHidden = false
            }
            SwiftSpinner.hide()
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
