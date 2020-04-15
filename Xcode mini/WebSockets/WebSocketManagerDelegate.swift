//
//  WebSocketManagerDelegate.swift
//  Xcode mini
//
//  Created by Kristaps Grinbergs on 15/04/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

protocol WebSocketManagerDelegate {
  func didConnect()
  func didReceive(text: String, annotations: [Annotation])
}
