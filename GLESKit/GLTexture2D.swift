//
//  Texture2D.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit

/// <#Description#>
public class GLTexture2D: GLObject,
    GLTexture,
    GLUsable,
    GLSizeable {
   
    /// <#Description#>
    private var bitmapContext: CGContext?
    
    /// <#Description#>
    private(set) public var size: CGSize = .zero
    
    /// <#Description#>
    ///
    /// - Throws: <#throws value description#>
    private init() throws {
        var name: GLuint = 0
        glGenTextures(1, &name)
        try super.init(name: name)
        
        use()
        enableNPOTSupport()
    }
    
    /// <#Description#>
    ///
    /// - Parameter sizeInPixels: <#sizeInPixels description#>
    /// - Throws: <#throws value description#>
    public convenience init(sizeInPixels: CGSize) throws {
        try self.init()
        size = GLCGGeometryConverter.points(from: sizeInPixels)
        try validate(size: size)
        
        glTexStorage2D(GLenum(GL_TEXTURE_2D),
                       1,
                       GLenum(GL_RGBA8),
                       GLsizei(sizeInPixels.width),
                       GLsizei(sizeInPixels.height))
    }
 
    /// <#Description#>
    ///
    /// - Parameter size: <#size description#>
    /// - Throws: <#throws value description#>
    public convenience init(size: CGSize) throws {
        try self.init()
        try validate(size: size)
        self.size = size
        
        let realSize = GLCGGeometryConverter.pixels(from: size)
        glTexStorage2D(
            GLenum(GL_TEXTURE_2D),
            1,
            GLenum(GL_RGBA8),
            GLsizei(realSize.width),
            GLsizei(realSize.height)
        )
        
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - resourceName: <#resourceName description#>
    ///   - bundle: <#bundle description#>
    /// - Throws: <#throws value description#>
    public init(resourceName: String,
                bundle: Bundle = Bundle.main) throws {
        guard let filePath = bundle.path(forResource: resourceName, ofType: nil) else {
            throw GLResource.LoadingError.fileNotFound(fileName: resourceName)
        }
        
        let textureInfo = try GLKTextureLoader.texture(withContentsOfFile: filePath,
                                                       options: nil)
        try super.init(name: textureInfo.target)
        size = CGSize(width: CGFloat(textureInfo.width),
                      height: CGFloat(textureInfo.height))
        try validate(size: size)
    }
    
    /// <#Description#>
    public func enableNPOTSupport() {
        glTexParameteri(
            GLenum(GL_TEXTURE_2D),
            GLenum(GL_TEXTURE_WRAP_S),
            GL_CLAMP_TO_EDGE
        )
        
        glTexParameteri(
            GLenum(GL_TEXTURE_2D),
            GLenum(GL_TEXTURE_WRAP_T),
            GL_CLAMP_TO_EDGE
        )
        
        glTexParameteri(
            GLenum(GL_TEXTURE_2D),
            GLenum(GL_TEXTURE_MAG_FILTER),
            GL_NEAREST
        )
        
        glTexParameteri(
            GLenum(GL_TEXTURE_2D),
            GLenum(GL_TEXTURE_MIN_FILTER),
            GL_NEAREST
        )
        
        
    }
    
    /// <#Description#>
    public func use() {
        glBindTexture(GLenum(GL_TEXTURE_2D), name)
    }
    
    /// <#Description#>
    ///
    /// - Parameter view: <#view description#>
    /// - Throws: <#throws value description#>
    public func update(withContentsOf view: UIView) throws {
        if view.bounds.size.width != size.width ||
            view.bounds.size.height != size.height {
            let errMsg = "Attempt to update texture with a view the size of which (w: \(view.bounds.size.width), h: \(view.bounds.size.width)) exceeds acceptable size (w: \(size.width), h: \(size.width))"
            throw GLObject.SizeError.invalidSize(details: errMsg)
        }
        
        let realSize = GLCGGeometryConverter.pixels(from: view.bounds.size)
        if let context = bitmapContext {
            let size = CGSize(width: context.width,
                              height: context.height)
            let rect = CGRect(origin: .zero,
                              size: size)
            context.clear(rect)
        } else {
            bitmapContext = bitmapContextWith(size: realSize,
                                              scale: UIScreen.main.scale)
        }
        
        guard let context = bitmapContext else {
            return
        }
        
        use()
        
        view.layer.render(in: context)
        
        glTexSubImage2D(
            GLenum(GL_TEXTURE_2D),
            0,
            0,
            0,
            GLsizei(realSize.width),
            GLsizei(realSize.height),
            GLenum(GL_RGBA),
            GLenum(GL_UNSIGNED_BYTE),
            context.data
        )
    }
    
    
    deinit {
        glDeleteTextures(1, &name)
    }
}
