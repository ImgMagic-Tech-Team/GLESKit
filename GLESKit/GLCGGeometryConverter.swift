//
//  GLMathConverter
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit

/// <#Description#>
internal struct GLCGGeometryConverter {

    /// <#Description#>
    ///
    /// - Parameter size: <#size description#>
    /// - Returns: <#return value description#>
    internal static func pixels(from size: CGSize) -> CGSize {
        let scale = UIScreen.main.nativeScale
        return CGSize(width: size.width * scale,
                      height: size.height * scale)
    }
    
    /// <#Description#>
    ///
    /// - Parameter size: <#size description#>
    /// - Returns: <#return value description#>
    internal static func points(from size: CGSize) -> CGSize {
        let scale = UIScreen.main.nativeScale
        return CGSize(width: size.width / scale,
                      height: size.height / scale)
    }
    
    /// <#Description#>
    ///
    /// - Parameter rect: <#rect description#>
    /// - Returns: <#return value description#>
    internal static func pixels(from rect: CGRect) -> CGRect {
        let scale = UIScreen.main.nativeScale
        return CGRect(x: rect.origin.x * scale,
                      y: rect.origin.y * scale,
                      width: rect.size.width * scale,
                      height: rect.size.height * scale)
    }
    
    /// <#Description#>
    ///
    /// - Parameter rect: <#rect description#>
    /// - Returns: <#return value description#>
    internal static func points(from rect: CGRect) -> CGRect {
        let scale = UIScreen.main.nativeScale
        return CGRect(x: rect.origin.x / scale,
                      y: rect.origin.y / scale,
                      width: rect.size.width / scale,
                      height: rect.size.height / scale)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - rect: <#rect description#>
    ///   - size: <#size description#>
    /// - Returns: <#return value description#>
    internal static func inverted(rect: CGRect,
                                  relativeTo size: CGSize) -> CGRect {
        var rect = rect
        rect.origin.y = size.height - rect.size.height - rect.origin.y
        return rect
    }
}
