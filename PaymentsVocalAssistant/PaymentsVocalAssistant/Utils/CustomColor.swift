//
//  customColors.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 03/02/24.
//

import Foundation
import SwiftUI

enum CustomColor {
    static var customGray: Color {
        let darkGrayNum = 35
        let lightGrayNum = 243

        return dynamicColor(
            lightMode: (red: lightGrayNum, green: lightGrayNum, blue: lightGrayNum, alpha: 1.0),
            darkMode: (red: darkGrayNum, green: darkGrayNum, blue: darkGrayNum, alpha: 1.0)
        )
    }
    
    static var customGrayMic: Color {
        let blackNum = 0
        let whiteNum = 255

        return dynamicColor(
            lightMode: (red: blackNum, green: blackNum, blue: blackNum, alpha: 1.0),
            darkMode: (red: whiteNum, green: whiteNum, blue: whiteNum, alpha: 1.0)
        ).opacity(0.5)
    }
    
    /** Define a dynamic UIColor that changes with the system theme */
    private static func dynamicColor(lightMode: (red: Int, green: Int, blue: Int, alpha: Double), darkMode: (red: Int, green: Int, blue: Int, alpha: Double)) -> Color {
        // color Int are from 0 to 255
        // alpha Double from 0.0 to 1.0
        
        let dynamicUIColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                // Dark mode color
                return UIColor(
                    red: Double(darkMode.red)/Double(255),
                    green: Double(darkMode.green)/Double(255),
                    blue: Double(darkMode.blue)/Double(255),
                    alpha: darkMode.alpha
                )
            } else {
                // Light mode color
                return UIColor(
                    red: Double(lightMode.red)/Double(255),
                    green: Double(lightMode.green)/Double(255),
                    blue: Double(lightMode.blue)/Double(255),
                    alpha: lightMode.alpha
                )
            }
        }
        // Convert the UIColor to a SwiftUI Color
        return Color(dynamicUIColor)
    }
}
