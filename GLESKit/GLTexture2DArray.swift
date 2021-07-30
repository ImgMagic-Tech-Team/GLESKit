//
//  Texture2DArray.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit

/// <#Description#>
///
/// - unacceptableIndex: <#unacceptableIndex description#>
public enum GLTexture2DArrayError: Error {
    case unacceptableIndex(details: String)
}

/// <#Description#>
public class GLTexture2DArray: GLObject,
    GLTexture,
    GLObjectUsable,
    GLObjectSizeable {

    /// <#Description#>
    private(set) public var size: CGSize = .zero
    
    /// <#Description#>
    private(set) public var capacity: UInt = 0
    
    /// <#Description#>
    private var bitmapContext: CGContext?
    
    /// <#Description#>
    ///
    /// - Throws: <#throws value description#>
    public init() throws {
        var name: GLuint = 0
        glGenTextures(1, &name)
        try super.init(name: name)
        use()
        enableNPOTSupport()
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - sizeInPixels: <#sizeInPixels description#>
    ///   - capacity: <#capacity description#>
    /// - Throws: <#throws value description#>
    public convenience init(sizeInPixels: CGSize,
                            capacity: UInt) throws {
        try self.init()
        self.capacity = capacity
        size = GLCGGeometryConverter.points(from: sizeInPixels)
        try validate(size: size)
        
        glTexStorage3D(GLenum(GL_TEXTURE_2D_ARRAY),
                       1,
                       GLenum(GL_RGBA8),
                       GLsizei(sizeInPixels.width),
                       GLsizei(sizeInPixels.height),
                       GLsizei(capacity))
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - size: <#size description#>
    ///   - capacity: <#capacity description#>
    /// - Throws: <#throws value description#>
    public convenience init(size: CGSize,
                            capacity: UInt) throws {
        try self.init()
        try validate(size: size)
        
        self.capacity = capacity
        self.size = size
        
        use()
        enableNPOTSupport()
        
        let realSize = GLCGGeometryConverter.pixels(from: size)
        
        glTexStorage3D(GLenum(GL_TEXTURE_2D_ARRAY),
                       1,
                       GLenum(GL_RGBA8),
                       GLsizei(realSize.width),
                       GLsizei(realSize.height),
                       GLsizei(capacity))
    }
    
    /// <#Description#>
    public func use() {
        glBindTexture(GLenum(GL_TEXTURE_2D_ARRAY),
                      name)
    }
    
    /// <#Description#>
    public func enableNPOTSupport() {
        glTexParameteri(GLenum(GL_TEXTURE_2D_ARRAY),
                        GLenum(GL_TEXTURE_WRAP_S),
                        GL_CLAMP_TO_EDGE)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D_ARRAY),
                        GLenum(GL_TEXTURE_WRAP_T),
                        GL_CLAMP_TO_EDGE)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D_ARRAY),
                        GLenum(GL_TEXTURE_MAG_FILTER),
                        GL_NEAREST)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D_ARRAY),
                        GLenum(GL_TEXTURE_MIN_FILTER),
                        GL_NEAREST)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - index: <#index description#>
    ///   - view: <#view description#>
    /// - Throws: <#throws value description#>
    public func updateTexture(at index: UInt,
                              withContentsOf view: UIView) throws {
        if view.bounds.size.width != size.width ||
            view.bounds.size.height != size.height {
            throw GLObject.SizeError.invalidSize(details: "Attempt to update texture in the texture array with a view the size of which (w: \(view.bounds.size.width), h: \(view.bounds.size.width)) doesn't match acceptable size (w: \(size.width), h: \(size.width))")
        }
        
        if index >= capacity {
            throw GLTexture2DArrayError.unacceptableIndex(details: "Index \(index) exceedes texture array capacity \(capacity)")
        }
        
        let realSize = GLCGGeometryConverter.pixels(from: view.bounds.size)
        
        if bitmapContext == nil {
            bitmapContext = bitmapContextWith(size: realSize,
                                              scale: UIScreen.main.scale)
        }
        
        guard let context = bitmapContext else {
            return
        }
        
        view.layer.render(in: context)
        use()
        
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA),
                    GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        glTexSubImage3D(GLenum(GL_TEXTURE_2D_ARRAY),
                        0,
                        0,
                        0,
                        GLint(index),
                        GLsizei(realSize.width),
                        GLsizei(realSize.height),
                        1,
                        GLenum(GL_RGBA),
                        GLenum(GL_UNSIGNED_BYTE),
                        context.data)
    }
}
