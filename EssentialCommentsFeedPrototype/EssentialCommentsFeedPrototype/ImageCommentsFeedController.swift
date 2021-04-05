//
//  ImageCommentsFeedController.swift
//  EssentialCommentsFeedPrototype
//
//  Created by Wilmer Barrios on 04/04/21.
//

import Foundation
import UIKit

struct ImageCommentsFeedViewModel {
    let author: String
    let createdAt: String
    let comment: String
}

class ImageCommentsFeedController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImageCommentsFeedViewModel.prototypedFeed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell")!
    }
}
