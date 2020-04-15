//
//  Extensions.swift
//  Native Swift Editor
//
//  Created by Kristaps Grinbergs on 22/11/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
  func addActions(_ actions: [UIAlertAction]) {
    actions.forEach {
      addAction($0)
    }
  }
}

extension UITextView {
  func clear() {
    text = ""
  }
}
