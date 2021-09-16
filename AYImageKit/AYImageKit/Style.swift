//
//  Style.swift
//  AYImageKit
//
//  Created by Adnan Yousaf on 16/09/2021.
//

import UIKit

/**
 Struct to Implement style for AYImageView
 - implement Initials label font properties
 - Implement Initials label text color
 - Implement background color
 - Implement Border Color
 */
struct Style {
    
    var font: UIFont
    var background: UIColor
    var textColor: UIColor
    var borderColor: UIColor?
    
    public init(font: UIFont, textColor: UIColor, background: UIColor, borderColor: UIColor? = nil) {
        self.font = font
        self.textColor = textColor
        self.background = background
        self.borderColor = borderColor
    }
    
    public static func `default`(font: UIFont? = nil, textColor: UIColor? = nil, background: UIColor? = nil, borderColor: UIColor? = nil) -> Style {
        switch UIScreen.main.traitCollection.userInterfaceIdiom {
        case .phone:
            return Style(font: font != nil ? font! : UIFont.systemFont(ofSize: 19),
                         textColor: textColor != nil ? textColor! : UIColor(red: 120.0/255.0, green: 144.0/255.0, blue: 156.0/255.0, alpha: 1.0),
                         background: background != nil ? background! : .white,
                         borderColor: borderColor != nil ? borderColor! : .black)
        
        case .pad, .tv, .carPlay, .unspecified, .mac:
            return Style(font: font != nil ? font! : UIFont.systemFont(ofSize: 19),
                         textColor: textColor != nil ? textColor! : UIColor.white,
                         background: background != nil ? background! : UIColor(red: 144.0/255.0, green: 164.0/255.0, blue: 174.0/255.0, alpha: 1.0),
                         borderColor: borderColor != nil ? borderColor! : .black)
        @unknown default:
            fatalError()
        }
    }
}


