//
//  SwiftToolchain.swift
//  Xcode mini
//
//  Created by Kristaps Grinbergs on 15/04/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

enum SwiftToolchain: String, RawRepresentable, Codable, CustomStringConvertible, CaseIterable {
  case swift5_1 = "5.1-RELEASE"
  
  var value: String {
    return rawValue
  }
  
  var description: String {
    let dashIndex = value.firstIndex(of: "-") ?? value.endIndex
    return String(value[..<dashIndex])
  }
  
  static var latestVersion: SwiftToolchain {
    return SwiftToolchain.allCases.last!
  }
}
