//
//  AnnotationType.swift
//  Xcode mini
//
//  Created by Kristaps Grinbergs on 15/04/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

enum AnnotationType: String, Codable {
  case error = "error"
  case warning = "warning"
  case notice = "notice"
}
