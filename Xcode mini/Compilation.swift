//
//  Compilation.swift
//  Native Swift Editor
//
//  Created by Kristaps Grinbergs on 21/11/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation

struct Compilation: Codable {
  let run: Run
}

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

struct Run: Codable {
  let toolchain: SwiftToolchain
  let value: String
}
