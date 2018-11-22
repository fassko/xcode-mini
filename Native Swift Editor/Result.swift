//
//  Result.swift
//  
//
//  Created by Kristaps Grinbergs on 21/11/2018.
//

import Foundation

struct Result: Codable {
  let output: Output
}

struct Output: Codable {
  let value: String
  let annotations: [Annotation]
}

enum AnnotationType: String, Codable {
  case error = "error"
  case warning = "warning"
  case notice = "notice"
}

struct AnnotationLocation: Codable {
  let row: Int
  let column: Int
}

struct Annotation: Codable {
  let type: AnnotationType
  let location: AnnotationLocation
  let description: String
}
