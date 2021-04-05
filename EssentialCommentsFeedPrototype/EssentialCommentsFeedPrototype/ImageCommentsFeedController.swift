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
    private var feed = [ImageCommentsFeedViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.feed.isEmpty {
                self.feed = ImageCommentsFeedViewModel.prototypedFeed
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    // TODO: Refresh controller...
    
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
