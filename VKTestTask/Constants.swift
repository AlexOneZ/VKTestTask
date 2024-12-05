//
//  Keys.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 02.12.2024.
//

import UIKit

enum Constants {
    enum Fonts {
        static var ui16Semi: UIFont? {
            UIFont(name: "Inter-SemiBold", size: 16)
        }
        static var ui14Regular: UIFont? {
            UIFont(name: "Inter-Regular", size: 14)
        }
        static var systemHeading: UIFont {
            UIFont.systemFont(ofSize: 16, weight: .semibold)
        }
        static var systemText: UIFont {
            UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }
}
