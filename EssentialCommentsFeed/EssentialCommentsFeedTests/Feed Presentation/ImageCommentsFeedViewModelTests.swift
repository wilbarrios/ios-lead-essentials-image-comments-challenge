//
//  ImageCommentsFeedViewModelTests.swift
//  EssentialCommentsFeedTests
//
//  Created by Wilmer Barrios on 03/04/21.
//

import Foundation
import XCTest
@testable import EssentialCommentsFeed

public final class ImageCommentsViewModel {
    public static var title: String {
        return R.ImmageCommentsFeed.title
    }
}

class ImageCommentsFeedViewModelTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsViewModel.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    // MARK: Helpers
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
//        let bundle = Bundle(for: ImageCommentsViewModel.self)
        let bundle = Bundle(for: R.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
