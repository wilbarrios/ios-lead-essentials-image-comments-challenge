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
    private let feed = ImageCommentsFeedViewModel.prototypedFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell", for: indexPath) as! ImageCommentCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}
