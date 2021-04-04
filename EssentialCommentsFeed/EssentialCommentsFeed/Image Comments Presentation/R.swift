//
//  R.swift
//  EssentialCommentsFeed
//
//  Created by Wilmer Barrios on 03/04/21.
//

import Foundation

internal class R {
    private static let table = "ImageComments"
    
    struct ImmageCommentsFeed {
        static var title: String {
            return get(key: "IMAGE_COMMENTS_VIEW_TITLE")
        }
        
        static var loadError: String {
            return get(key: "IMAGE_COMMENTS_LOAD_ERROR")
        }
        
        private static func get(key: String) -> String {
            NSLocalizedString(key,
                        tableName: table,
                        bundle: Bundle(for: R.self),
                        comment: "")
        }
    }
}
