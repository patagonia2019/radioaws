//
//  UIColor+.swift
//  LDLARadio
//
//  Created by fox on 19/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit

extension UIColor {

    static func color(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    static var licorice = UIColor.black
    static var lead = UIColor.init(white: 0.1, alpha: 1)
    static var tungsten = UIColor.init(white: 0.2, alpha: 1)
    static var iron = UIColor.init(white: 0.3, alpha: 1)
    static var steel = UIColor.init(white: 0.4, alpha: 1)
    static var tin = UIColor.init(white: 0.57, alpha: 1)
    static var nickel = UIColor.tin
    static var nobel = UIColor.init(white: 0.67, alpha: 1)
    static var aluminum = UIColor.init(white: 0.6, alpha: 1)
    static var magnesium = UIColor.init(white: 0.7, alpha: 1)
    static var silver = UIColor.init(white: 0.8, alpha: 1)
    static var mercury = UIColor.init(white: 0.9, alpha: 1)
    static var snow = UIColor.white

    static var cayenne = color(r: 148, g: 17, b: 0) // pimentón
    static var mocha = color(r: 148, g: 82, b: 0) // marrón
    static var asparagus = color(r: 146, g: 144, b: 0) // verde espárrago (amarillento)
    static var fern = color(r: 79, g: 143, b: 0) // verde helecho
    static var clover = color(r: 0, g: 143, b: 0) // verde trébol
    static var moss = color(r: 0, g: 144, b: 81) // verde musgo
    static var teal = color(r: 0, g: 145, b: 147) // verde azulado
    static var cerulean = color(r: 0, g: 102, b: 153) // cerulean
    static var ocean = color(r: 0, g: 64, b: 147) // océano
    static var midnight = color(r: 1, g: 25, b: 147) // azul oscuro
    static var eggplant = color(r: 83, g: 27, b: 147) // berenjena (violeta)
    static var plum = color(r: 148, g: 33, b: 147) // ciruela
    static var maroon = color(r: 148, g: 33, b: 147) // granate
    static var maraschino = color(r: 255, g: 38, b: 0) // marron / granate
    static var tangerine = color(r: 255, g: 147, b: 0) // mandarina
    static var lemon = color(r: 255, g: 251, b: 0) // limón
    static var lime = color(r: 142, g: 250, b: 0) // lima
    static var spring = color(r: 0, g: 249, b: 0) // primavera (verde brillante)
    static var seafoam = color(r: 0, g: 250, b: 146) // espuma de mar (verde celeste)
    static var turquoise = color(r: 0, g: 253, b: 255) // turquesa
    static var aqua = color(r: 0, g: 150, b: 255) // agua
    static var blueberry = color(r: 4, g: 51, b: 255) // arándano
    static var grape = color(r: 148, g: 55, b: 255) // uva
    static var magenta = color(r: 255, g: 64, b: 255) // rosa
    static var strawberry = color(r: 255, g: 47, b: 146)
    static var salmon = color(r: 255, g: 126, b: 121)
    static var cantaloupe = color(r: 255, g: 212, b: 121) // melón
    static var banana = color(r: 255, g: 252, b: 121)
    static var honeydew = color(r: 255, g: 251, b: 121) // rocío de miel (amarillo verdoso claro)
    static var flora = color(r: 115, g: 250, b: 121)
    static var spindrift = color(r: 115, g: 252, b: 214) // rocío del mar (verde celestito claro)
    static var ice = color(r: 115, g: 253, b: 255) // celeste
    static var sky = color(r: 118, g: 214, b: 255) // color del cielo
    static var orchid = color(r: 122, g: 129, b: 255) // azul claro
    static var lavender = color(r: 215, g: 131, b: 255) // lavanda
    static var bublegum = color(r: 255, g: 133, b: 255) // chicle (rosado)
    static var carnation = color(r: 255, g: 138, b: 216) // clavel (rosa)
}
