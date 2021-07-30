//
//  WavefrontMaterial.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/23.
//  Copyright © 2019 su xinde. All rights reserved.
//


import GLESKit

public class WavefrontMaterial {
    public internal(set) var name: String!
    public internal(set) var ambientColor: GLKVector3!
    public internal(set) var diffuseColor: GLKVector3!
    public internal(set) var specularColor: GLKVector3!
    public internal(set) var emissiveColor: GLKVector3?
    public internal(set) var illuminationModel: WavefrontIlluminationModel!
    public internal(set) var opticalDensity: Float?
    public internal(set) var specularExponent: Float?
    public internal(set) var dissolve: Float?
    public internal(set) var transparency: Float?
    public internal(set) var transmissionFilter: GLKVector3?
    public internal(set) var ambientMap: GLTexture2D?
    public internal(set) var diffuseMap: GLTexture2D?
    public internal(set) var specularMap: GLTexture2D?
    public internal(set) var specularExponentMap: GLTexture2D?
    public internal(set) var alphaMap: GLTexture2D?
    public internal(set) var bumpMap: GLTexture2D?
    public internal(set) var displacementMap: GLTexture2D?
    public internal(set) var stencilDecalMap: GLTexture2D?
}

public enum WavefrontIlluminationModel: Int {
    
    /// This is a constant color illumination model. The color is the specified Kd for the material. The formula is:
    ///
    /// color = Kd
    case colorOnAmbientOff = 0
    
    /// This is a diffuse illumination model using Lambertian shading. The color includes an ambient constant term and a diffuse shading term for each light source.
    /// The formula is:
    ///
    /// color = KaIa + Kd { SUM j=1..ls, (N * Lj)Ij }
    case colorOnAmbient = 1
    
    /// This is a diffuse and specular illumination model using Lambertian shading and Blinn's interpretation of Phong's specular illumination model (BLIN77).
    /// The color includes an ambient constant term, and a diffuse and specular shading term for each light source. The formula is:
    ///
    /// color = KaIa
    /// + Kd { SUM j=1..ls, (N*Lj)Ij }
    /// + Ks { SUM j=1..ls, ((H*Hj)^Ns)Ij }
    case highlightOn = 2
    
    /// This is a diffuse and specular illumination model with reflection using Lambertian shading,
    /// Blinn's interpretation of Phong's specular illumination model (BLIN77),
    /// and a reflection term similar to that in Whitted's illumination model (WHIT80).
    /// The color includes an ambient constant term and a diffuse and specular shading term for each light source. The formula is:
    ///
    /// color = KaIa
    /// + Kd { SUM j=1..ls, (N*Lj)Ij }
    /// + Ks ({ SUM j=1..ls, ((H*Hj)^Ns)Ij } + Ir)
    ///
    /// Ir = (intensity of reflection map) + (ray trace)
    case reflectionOnRayTraceOn = 3
    
    /// The diffuse and specular illumination model used to simulate glass is the same as illumination model 3.
    /// When using a very low dissolve (approximately 0.1), specular highlights from lights or reflections become imperceptible.
    ///
    /// Simulating glass requires an almost transparent object that still reflects strong highlights.
    /// The maximum of the average intensity of highlights and reflected lights is used to adjust the dissolve factor. The formula is:
    ///
    /// color = KaIa
    /// + Kd { SUM j=1..ls, (N*Lj)Ij }
    /// + Ks ({ SUM j=1..ls, ((H*Hj)^Ns)Ij } + Ir)
    case transparencyGlassOnReflectionRayTraceOn = 4
    
    /// This is a diffuse and specular shading models similar to illumination model 3,
    /// except that reflection due to Fresnel effects is introduced into the equation.
    /// Fresnel reflection results from light striking a diffuse surface at a grazing or glancing angle.
    /// When light reflects at a grazing angle, the Ks value approaches 1.0 for all color samples. The formula is:
    ///
    /// color = KaIa
    /// + Kd { SUM j=1..ls, (N*Lj)Ij }
    /// + Ks ({ SUM j=1..ls, ((H*Hj)^Ns)Ij Fr(Lj*Hj,Ks,Ns)Ij} + Fr(N*V,Ks,Ns)Ir})
    case reflectionFresnelOnRayTraceOn = 5
    
    /// This is a diffuse and specular illumination model similar to that used by Whitted (WHIT80) that allows rays to refract through a surface.
    /// The amount of refraction is based on optical density (Ni). The intensity of light that refracts is equal to 1.0 minus the value of Ks,
    /// and the resulting light is filtered by Tf (transmission filter) as it passes through the object. The formula is:
    ///
    /// color = KaIa
    /// + Kd { SUM j=1..ls, (N*Lj)Ij }
    /// + Ks ({ SUM j=1..ls, ((H*Hj)^Ns)Ij } + Ir)
    /// + (1.0 - Ks) TfIt
    case transparencyRefractionOnReflectionFresnelOffRayTraceOn = 6
    
    /// This illumination model is similar to illumination model 6, except that reflection and transmission due to Fresnel effects has been introduced to the equation.
    /// At grazing angles, more light is reflected and less light is refracted through the object. The formula is:
    ///
    /// color = KaIa
    /// + Kd { SUM j=1..ls, (N*Lj)Ij }
    /// + Ks ({ SUM j=1..ls, ((H*Hj)^Ns)Ij Fr(Lj*Hj,Ks,Ns)Ij} + Fr(N*V,Ks,Ns)Ir})
    /// + (1.0 - Kx)Ft (N*V,(1.0-Ks),Ns)TfIt
    case transparencyRefractionOnReflectionFresnelOnRayTraceOn = 7
    
    /// This illumination model is similar to illumination model 3 (reflectionOnRayTraceOn) without ray tracing. The formula is:
    ///
    /// color = KaIa
    /// + Kd { SUM j=1..ls, (N*Lj)Ij }
    /// + Ks ({ SUM j=1..ls, ((H*Hj)^Ns)Ij } + Ir)
    ///
    /// Ir = (intensity of reflection map)
    case reflectionOnRayTraceOff = 8
    
    /// This illumination model is similar to illumination model 4 (transparencyGlassOnReflectionRayTraceOn) without ray tracing. The formula is:
    ///
    /// color = KaIa
    /// + Kd { SUM j=1..ls, (N*Lj)Ij }
    /// + Ks ({ SUM j=1..ls, ((H*Hj)^Ns)Ij } + Ir)
    ///
    /// Ir = (intensity of reflection map)
    case transparencyGlassOnReflectionRayTraceOff = 9
    
    /// This illumination model is used to cast shadows onto an invisible surface.
    /// This is most useful when compositing computer-generated imagery onto live action,
    /// since it allows shadows from rendered objects to be composited directly on top of video-grabbed images.
    /// The equation for computation of a shadowmatte is formulated as follows.
    case invisibleSurfaceShadowCasting = 10
}
