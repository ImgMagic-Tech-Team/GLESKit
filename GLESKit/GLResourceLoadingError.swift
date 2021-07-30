//
//  GLResourceLoadingError.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/23.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit

/// <#Description#>
///
/// - fileNotFound: <#fileNotFound description#>
public enum GLResourceLoadingError: Error {
    case fileNotFound(fileName: String)
}

