//
//  Annotation.swift
//  Xcode mini
//
//  Created by Kristaps Grinbergs on 15/04/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

struct Annotation: Codable {
  let type: AnnotationType
  let location: AnnotationLocation
  let description: String
}
