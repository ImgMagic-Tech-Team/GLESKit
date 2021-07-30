//
//  WavefrontVertex.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/23.
//  Copyright © 2019 su xinde. All rights reserved.
//

import GLKit
import GLESKit


public class WavefrontVertex: GLVertex {
    
    public static var attributeLayouts: [GLVertexAttributeMemoryLayout] {
        return [GLVertexAttributeMemoryLayout(location: 0, memorySize: GLKVector4.memorySize),
                GLVertexAttributeMemoryLayout(location: 1, memorySize: GLKVector3.memorySize),
                GLVertexAttributeMemoryLayout(location: 2, memorySize: GLKVector3.memorySize)]
    }
    
    public static var memorySize: Int {
        return MemoryLayout<GLKVector4>.size + MemoryLayout<GLKVector3>.size + MemoryLayout<GLKVector3>.size
    }
    
    public var primitiveSequence: [GLfloat] {
        var sequence = position.primitiveSequence
        sequence.append(contentsOf: textureCoordinates.primitiveSequence)
        sequence.append(contentsOf: normal.primitiveSequence)
        return sequence
    }
    
    public var position: GLKVector4
    public var normal: GLKVector3
    public var textureCoordinates: GLKVector3
    
    init(position: GLKVector4 = GLKVector4(v: (0.0, 0.0, 0.0, 1.0)),
         normal: GLKVector3 = GLKVector3(v: (0.0, 0.0, 0.0)),
         textureCoordinates: GLKVector3 = GLKVector3(v: (0.0, 0.0, 0.0))) {
        
        self.position = position
        self.normal = normal
        self.textureCoordinates = textureCoordinates
    }
}
