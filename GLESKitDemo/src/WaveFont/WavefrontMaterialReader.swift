//
//  WavefrontMaterialReader.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/23.
//  Copyright © 2019 su xinde. All rights reserved.
//

import GLKit

internal enum MaterialDataMarker: NSString {
    case newMaterial = "newmtl"
    case ambientColor = "Ka"
    case diffuseColor = "Kd"
    case specularColor = "Ks"
    case emissiveColor = "Ke"
    case opticalDensity = "Ni" // a.k.a index of refraction
    case specularExponent = "Ns"
    case transmissionFilter = "Tf"
    case transparency = "Tr"
    case illuminationModel = "illum"
    case dissolve = "d"
    case ambientMap = "map_Ka"
    case diffuseMap = "map_Kd"
    case specularMap = "map_Ks"
    case specularExponentMap = "map_Ns" // a.k.a specular highlight map
    case alphaMap = "map_d"
    case bumpMap = "bump"
    case displacementMap = "disp"
    case stencilDecal = "decal"
}

internal class WavefrontMaterialReader: WavefrontFileReader {
    
    func readMarker() throws -> MaterialDataMarker {
        let markerString = try readToken(errorMessage: "Unable to deternime a marker")
        guard let sourceDataMarker = MaterialDataMarker(rawValue: markerString) else {
            throw ModelLoadingError.invalidData(details: "Marker \(markerString) is unacceptable")
        }
        return sourceDataMarker
    }
    
    func readColor() throws -> GLKVector3 {
        let r = try readFloat(errorMessage: "Missing color R component")
        let g = try readFloat(errorMessage: "Missing color G component")
        let b = try readFloat(errorMessage: "Missing color B component")
        
        if r < 0.0 || r > 1.0 {
            throw ModelLoadingError.invalidData(details: "Color r value \(r) is not in the 0.0 <= r <= 1.0 range")
        }
        
        if g < 0.0 || g > 1.0 {
            throw ModelLoadingError.invalidData(details: "Color g value \(g) is not in the 0.0 <= g <= 1.0 range")
        }
        
        if b < 0.0 || b > 1.0 {
            throw ModelLoadingError.invalidData(details: "Color b value \(b) is not in the 0.0 <= b <= 1.0 range")
        }
        
        return GLKVector3(v: (r, g, b))
    }
    
    func readIlluminationModel() throws -> WavefrontIlluminationModel {
        let modelNumber = try readInt(errorMessage: "Cannot read illumination model")
        guard let model = WavefrontIlluminationModel(rawValue: modelNumber) else {
            throw ModelLoadingError.invalidData(details: "Invalid illumination model (\(modelNumber))")
        }
        return model
    }
    
    func readTransmissionFilter() throws -> GLKVector3 {
        let r = try readFloat(errorMessage: "Unable to read transmission filter")
        let g = (try? readFloat(errorMessage: "")) ?? r
        let b = (try? readFloat(errorMessage: "")) ?? r
        
        return GLKVector3(v: (r, g, b))
    }
}
