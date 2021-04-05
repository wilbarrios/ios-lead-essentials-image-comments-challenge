//
//  ImageCommentCell.swift
//  EssentialCommentsFeedPrototype
//
//  Created by Wilmer Barrios on 04/04/21.
//

import Foundation
import UIKit

final class ImageCommentCell: UITableViewCell {
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    func configure(with model: ImageCommentsFeedViewModel) {
        authorNameLabel.text = model.author
        createdAtLabel.text = model.createdAt
        commentLabel.text = model.comment
    }
}
