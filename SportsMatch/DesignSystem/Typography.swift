//
//  Typography.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 09/10/2025.
//

import SwiftUI

extension Font {
    // Titres
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // Corps de texte
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    
    // Boutons
    static let button = Font.system(size: 17, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 15, weight: .semibold, design: .default)
    static let buttonLarge = Font.system(size: 20, weight: .semibold, design: .default)
}

struct Typography {
    static let largeTitle = Font.largeTitle
    static let title1 = Font.title1
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let headline = Font.headline
    static let body = Font.body
    static let bodyBold = Font.bodyBold
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
    static let button = Font.button
    static let buttonSmall = Font.buttonSmall
    static let buttonLarge = Font.buttonLarge
}
