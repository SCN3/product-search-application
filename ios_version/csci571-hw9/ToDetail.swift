//
//  ToDetail.swift
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

class ToDetail: UIStoryboardSegue {
    override func perform() {
        var srcVC: UIViewController
        if (self.identifier == "SearchFormToDetail") {
            srcVC = self.source as! SearchFormViewController
        } else {
            srcVC = self.source as! SearchResultViewController
        }
        let dstVC = self.destination as! DetailViewController
        srcVC.navigationController?.pushViewController(dstVC, animated: true)
    }
}
