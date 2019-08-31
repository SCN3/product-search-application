//
//  PhotosTabViewController.swift
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

class PhotosTabViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblNotFound: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SwiftSpinner.show("Fetching Google Images...")
        scrollView.isHidden = true
        lblNotFound.isHidden = true
        let detailViewController = tabBarController as! DetailViewController
        var itemTitle = detailViewController.itemTitle
        let customAllowedSet = NSCharacterSet(charactersIn: "&").inverted.intersection(.urlQueryAllowed)
        itemTitle = itemTitle.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        Alamofire.request("http://backend-dot-csci571-hw8-235604.appspot.com/photos?productTitle=" + itemTitle).validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let items = json["items"].array
                    let itemCount = items?.count
                    if itemCount == 0 {
                        self.lblNotFound.isHidden = false
                        SwiftSpinner.hide()
                        return
                    }
                    var photos: [UIImage] = Array(repeating: UIImage(), count: itemCount!)
                    let group = DispatchGroup()
                    for i in 0..<itemCount! {
                        group.enter()
                        Alamofire.request(items![i]["link"].string!).responseImage { response in
                            if let image = response.result.value {
                                photos[i] = image
                            }
                            group.leave()
                        }
                    }
                    group.notify(queue: DispatchQueue.main) {
                        for i in 0..<photos.count {
                            let imageView = UIImageView()
                            imageView.image = photos[i]
                            imageView.frame = CGRect(x: 0, y: 400*i, width: 345, height: 370)
                            self.scrollView.addSubview(imageView)
                        }
                        self.scrollView.contentSize = CGSize(width: 345, height: 400*photos.count-30)
                        self.scrollView.delegate = self
                        self.scrollView.isHidden = false
                        SwiftSpinner.hide()
                    }
                    SwiftSpinner.hide()
                case .failure(let error):
                    print(error)
                    self.lblNotFound.isHidden = false
                    SwiftSpinner.hide()
                    return
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
