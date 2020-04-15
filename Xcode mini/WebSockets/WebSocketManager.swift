//
//  WebSocketManager.swift
//  Xcode mini
//
//  Created by Kristaps Grinbergs on 15/04/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation
import Starscream

class WebSocketManager: NSObject {
  private var websocket: WebSocket?
  private let delegate: WebSocketManagerDelegate?
  
  init(delegate: WebSocketManagerDelegate) {
    self.delegate = delegate
  }
  
  func connect() {
    let request = URLRequest(url: URL(string: "ws://online.swiftplayground.run/terminal")!)
    websocket = WebSocket(request: request)
    websocket?.delegate = self
    websocket?.connect()
  }
  
  func send(text: String, _ completion: ((Error?) -> Void)? = nil) {
    websocket?.write(string: text) {
      completion?(nil)
    }
  }
}

extension WebSocketManager: WebSocketDelegate {
  func didReceive(event: WebSocketEvent, client: WebSocket) {
    switch event {
    case .connected:
      delegate?.didConnect()
    case .text(let text):
      do {
        guard let data = text.data(using: .utf8) else { return }
        let result = try JSONDecoder().decode(Result.self, from: data)
        
        DispatchQueue.main.async { [weak self] in
          self?.delegate?.didReceive(text: result.output.value, annotations: result.output.annotations)
        }
      } catch {
        print(error)
      }
    default:
      print("Not implemented \(event)")
    }
  }
}
