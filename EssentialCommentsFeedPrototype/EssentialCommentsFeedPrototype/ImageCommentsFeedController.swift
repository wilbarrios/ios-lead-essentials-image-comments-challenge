//
//  ImageCommentsFeedController.swift
//  EssentialCommentsFeedPrototype
//
//  Created by Wilmer Barrios on 04/04/21.
//

import Foundation
import UIKit

class ImageCommentsFeedController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell")!
    }
}
