//
//  ViewController.swift
//  Native Swift Editor
//
//  Created by Kristaps Grinbergs on 21/11/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import UIKit

import Starscream
import Sourceful

class ViewController: UIViewController {
  
  @IBOutlet weak var syntaxTextView: SyntaxTextView!
  @IBOutlet weak var resultTextView: TextView!
  @IBOutlet weak var compileIcon: UIBarButtonItem!
  @IBOutlet weak var swiftVersionButton: UIBarButtonItem!
  
  private let lexer = SwiftLexer()
  
  
  private let socket = WebSocket(request: URLRequest(url: URL(string: "ws://online.swiftplayground.run/terminal")!))
  
  private var swiftVersion: SwiftToolchain! = SwiftToolchain.latestVersion {
    didSet {
      swiftVersionButton.title = "Swift \(String(describing: swiftVersion.description))"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    socket.delegate = self
    socket.connect()
    
    syntaxTextView.theme = DefaultSourceCodeTheme()
    syntaxTextView.delegate = self
  }
}

extension ViewController {
  @IBAction func compile(_ sender: Any) {
    
    resultTextView.clear()
    
//    guard socket.isConnected else { return }
    
    let run = Run(toolchain: swiftVersion, value: syntaxTextView.text)
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
  
  @IBAction func changeSwiftVersion(_ sender: UIBarButtonItem) {
    let swiftVersionAlert = UIAlertController(title: nil,
                                              message: "Choose Swift toolchain version",
                                              preferredStyle: .actionSheet)
    
    let alertActions = SwiftToolchain.allCases.map { version in
      return UIAlertAction(title: version.description, style: .default) { [weak self] _ in
        self?.swiftVersion = version
      }
    }
    swiftVersionAlert.addActions(alertActions)
    
    present(swiftVersionAlert, animated: true, completion: nil)
  }
}

extension ViewController: WebSocketDelegate {
  func didReceive(event: WebSocketEvent, client: WebSocket) {
    switch event {
    case .connected:
      compileIcon.isEnabled = true
    case .text(let text):
      do {
        guard let data = text.data(using: .utf8) else { return }
        let result = try JSONDecoder().decode(Result.self, from: data)
        resultTextView.text = result.output.value
        resultTextView.textColor = result.output.annotations.isEmpty ? .white : .red
        syntaxTextView.contentTextView.resignFirstResponder()
      } catch {
        print(error)
      }
    default:
      print("something else")
    }
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
