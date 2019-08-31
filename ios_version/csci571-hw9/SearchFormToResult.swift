//
//  SearchFormToResult.swift
//  csci571-hw9
//
//  Created by scn3 on 4/15/19.
//  Copyright © 2019 scn3. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class SearchFormToResult: UIStoryboardSegue {
    override func perform() {
        let srcVC = self.source as! SearchFormViewController
        let dstVC = self.destination as! SearchResultViewController
        srcVC.navigationController?.pushViewController(dstVC, animated: true)
        
        SwiftSpinner.show("Searching...")
        let parameters = srcVC.parameters
        Alamofire.request("http://backend-dot-csci571-hw8-235604.appspot.com/search", parameters: parameters).validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let items = json["findItemsAdvancedResponse"][0]["searchResult"][0]["item"].array {
                        dstVC.items = items
                        dstVC.tableItem.reloadData()
                        SwiftSpinner.hide()
                    } else {
                        dstVC.items = []
                        dstVC.tableItem.reloadData()
                        SwiftSpinner.hide()
                        let alert = UIAlertController(title: "No Results!", message: "Failed to fetch search results", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        dstVC.present(alert, animated: true, completion: nil)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
}
