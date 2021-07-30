//
//  WavefrontGeometryReader.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/23.
//  Copyright © 2019 su xinde. All rights reserved.
//

import GLKit

internal enum GeometryDataMarker: NSString {
    case comment = "#"
    case vertex = "v"
    case normal = "vn"
    case textureCoordinates = "vt"
    case object = "o"
    case group = "g"
    case face = "f"
    case smoothShading = "s"
    case materialLibrary = "mtllib"
    case materialName = "usemtl"
}

internal class VertexAttributesIndexSet {
    var positionIndex: Int = 0
    var textureCoordinateIndex: Int?
    var normalIndex: Int?
}

internal class Face {
    let indexSets: [VertexAttributesIndexSet] = [VertexAttributesIndexSet(), VertexAttributesIndexSet(), VertexAttributesIndexSet()]
}

internal class WavefrontGeometryReader: WavefrontFileReader {
    
    func readMarker() throws -> GeometryDataMarker {
        let markerString = try readToken(errorMessage: "Unable to deternime a marker")
        guard let GeometryDataMarker = GeometryDataMarker(rawValue: markerString) else {
            throw ModelLoadingError.invalidData(details: "Marker \(markerString) is unacceptable")
        }
        return GeometryDataMarker
    }
    
    func readVertexPosition() throws -> GLKVector4 {
        let x = try readFloat(errorMessage: "Cannot read vertex X value")
        let y = try readFloat(errorMessage: "Cannot read vertex Y value")
        let z = try readFloat(errorMessage: "Cannot read vertex Z value")
        let w = (try? readFloat()) ?? 1.0
        
        return GLKVector4(v: (x, y, z, w))
    }
    
    func readTextureCoordinates() throws -> GLKVector3  {
        let u = try readFloat(errorMessage: "Cannot read texture U coordinate")
        let v = try readFloat(errorMessage: "Cannot read texture V coordinate")
        let w = (try? readFloat()) ?? 0.0
        
        return GLKVector3(v: (u, v, w))
    }
    
    func readNormal() throws -> GLKVector3  {
        let x = try readFloat(errorMessage: "Cannot read normal X value")
        let y = try readFloat(errorMessage: "Cannot read normal Y value")
        let z = try readFloat(errorMessage: "Cannot read normal Z value")
        
        return GLKVector3(v: (x, y, z))
    }
    
    func readMaterialLibraryName() throws -> String {
        let fullName = try readToken() as String
        guard let nameWithoutExtension = fullName.components(separatedBy: ".").first else { return fullName }
        return nameWithoutExtension
    }
    
    func readFace() throws -> Face {
        let face = Face()
        
        for indexSet in face.indexSets {
            var index = try readInt(errorMessage: "Cannot read texture coodinates index")
            indexSet.positionIndex = index
            try skip(string: "/", errorMessage: "Missing '/' in face definition")
            indexSet.textureCoordinateIndex = try? readInt()
            try skip(string: "/", errorMessage: "Missing '/' in face definition")
            indexSet.normalIndex = try? readInt()
        }
        
        return face
    }
}
