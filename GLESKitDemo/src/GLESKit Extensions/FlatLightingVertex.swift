//
//  FlatLightingVertex.swift
//  GLESKitDemo
//
//  Created by SuXinDe on 2021/7/30.
//  Copyright © 2021 su xinde. All rights reserved.
//

import Foundation
import GLESKit


class FlatLightingVertex: GLVertex {
    
    public static var attributeLayouts: [GLMemoryLayout] {
        return [GLMemoryLayout(location: 0,
                                              memorySize: GLKVector4.memorySize),
                GLMemoryLayout(location: 1,
                                              memorySize: GLKVector2.memorySize)]
    }
    
    public static var memorySize: Int {
        return MemoryLayout<GLKVector4>.size + MemoryLayout<GLKVector2>.size
    }
    
    public var primitiveSequence: [GLfloat] {
        var sequence = position.primitiveSequence
        sequence.append(contentsOf: textureCoordinates.primitiveSequence)
        return sequence
    }
    
    let position: GLKVector4
    let textureCoordinates: GLKVector2
    
    init(position: GLKVector4, textureCoordinates: GLKVector2) {
        self.position = position
        self.textureCoordinates = textureCoordinates
    }
}

