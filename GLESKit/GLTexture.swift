//
//  Texture.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES

/// <#Description#>
internal protocol GLTexture {
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func enableNPOTSupport()
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - size: <#size description#>
    ///   - scale: <#scale description#>
    /// - Returns: <#return value description#>
    func bitmapContextWith(size: CGSize,
                           scale: CGFloat) -> CGContext?
}

// MARK: - <#Description#>
internal extension GLTexture {
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - size: <#size description#>
    ///   - scale: <#scale description#>
    /// - Returns: <#return value description#>
    func bitmapContextWith(size: CGSize,
                           scale: CGFloat) -> CGContext? {
        let BitsPerComponent = 8
        let ColorSizeInMemory = 4
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: BitsPerComponent,
                                bytesPerRow: ColorSizeInMemory * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        context?.scaleBy(x: scale,
                         y: scale)
        return context
    }
}
