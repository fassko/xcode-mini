//
//  ViewController.swift
//  Native Swift Editor
//
//  Created by Kristaps Grinbergs on 21/11/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import UIKit
import SavannaKit
import SourceEditor
import Starscream

class ViewController: UIViewController {
  
  let lexer = SwiftLexer()
  
  let socket = WebSocket(url: URL(string: "ws://online.swiftplayground.run/terminal")!)
  
  @IBOutlet weak var syntaxTextView: SyntaxTextView!
  @IBOutlet weak var resultTextView: TextView!
  @IBOutlet weak var compileIcon: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    socket.connect()
    socket.delegate = self
    
    syntaxTextView.theme = DefaultSourceCodeTheme()
    syntaxTextView.delegate = self
  }
  
  @IBAction func compile(_ sender: Any) {
    guard socket.isConnected else { return }
    
    let run = Run(toolchain: .swift4_2, value: syntaxTextView.text)
    let compilation = Compilation(run: run)
    
    do {
      let jsonData = try JSONEncoder().encode(compilation)
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        return
      }
      socket.write(string: jsonString)
    } catch {
      print("Can't encode")
    }
  }
}

extension ViewController: WebSocketDelegate {
  func websocketDidConnect(socket: WebSocketClient) {
    compileIcon.isEnabled = true
  }
  
  func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    print("disconnected", error.debugDescription)
    compileIcon.isEnabled = false
  }
  
  func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    do {
      guard let data = text.data(using: .utf8) else { return }
      let result = try JSONDecoder().decode(Result.self, from: data)
      resultTextView.text = result.output.value
      resultTextView.textColor = result.output.annotations.isEmpty ? .white : .red
    } catch {
      print(error)
    }
  }
  
  func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    print(data)
  }
}


extension ViewController: SyntaxTextViewDelegate {
  func didChangeText(_ syntaxTextView: SyntaxTextView) {
  }
  
  func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
  }
  
  func lexerForSource(_ source: String) -> Lexer {
    return lexer
  }
}
