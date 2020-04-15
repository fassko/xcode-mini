//
//  WebSocketManager.swift
//  Xcode mini
//
//  Created by Kristaps Grinbergs on 15/04/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
  private var webSocketTask: URLSessionWebSocketTask?
  private let delegate: WebSocketManagerDelegate?
  
  init(delegate: WebSocketManagerDelegate) {
    self.delegate = delegate
  }
  
  func connect() {
    let webSocketQueue = OperationQueue()
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: webSocketQueue)
    
    webSocketTask = session.webSocketTask(with: URL(string: "ws://online.swiftplayground.run/terminal")!)
    webSocketTask?.resume()
  }
  
  func send(text: String, _ completion: ((Error?) -> Void)? = nil) {
    webSocketTask?.send(.string(text)) { error in
      if let error = error {
        completion?(error)
      } else {
        completion?(nil)
      }
    }
  }
  
  func receiveMessage() {
    webSocketTask?.receive { [weak self] result in
      switch result {
      case .success(let message):
        switch message {
        case .string(let text):
          do {
            guard let data = text.data(using: .utf8) else { return }
            let result = try JSONDecoder().decode(Result.self, from: data)
            
            DispatchQueue.main.async {
              self?.delegate?.didReceive(text: result.output.value, annotations: result.output.annotations)
            }
          } catch {
            print(error)
          }
        case .data(let data):
          print("Received data: \(data)")
        @unknown default:
          fatalError("Unknown case")
        }
      case .failure(let error):
        print("Error in receiving message: \(error)")
      }
      
      self?.receiveMessage()
    }
  }
  
  func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
    receiveMessage()
    
    DispatchQueue.main.async { [weak self] in
      self?.delegate?.didConnect()
    }
  }
  
  func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
    print("WebSocket closed")
  }
}
