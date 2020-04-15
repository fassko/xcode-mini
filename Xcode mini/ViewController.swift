//
//  ViewController.swift
//  Native Swift Editor
//
//  Created by Kristaps Grinbergs on 21/11/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import UIKit

import Sourceful

class ViewController: UIViewController {
  
  @IBOutlet weak var syntaxTextView: SyntaxTextView!
  @IBOutlet weak var resultTextView: TextView!
  @IBOutlet weak var compileIcon: UIBarButtonItem!
  @IBOutlet weak var swiftVersionButton: UIBarButtonItem!
  
  private var webSocketManager: WebSocketManager?
  
  private var swiftVersion: SwiftToolchain! = SwiftToolchain.latestVersion {
    didSet {
      swiftVersionButton.title = "Swift \(String(describing: swiftVersion.description))"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webSocketManager = WebSocketManager(delegate: self)
    webSocketManager?.connect()
    
    syntaxTextView.theme = DefaultSourceCodeTheme()
    syntaxTextView.delegate = self
  }
}

extension ViewController: WebSocketManagerDelegate {
  func didConnect() {
    compileIcon.isEnabled = true
  }
  
  func didReceive(text: String, annotations: [Annotation]) {
    resultTextView.text = text
    resultTextView.textColor = annotations.isEmpty ? .white : .red
    syntaxTextView.contentTextView.resignFirstResponder()
  }
}

extension ViewController {
  @IBAction func compile(_ sender: Any) {
    resultTextView.clear()
    
    let run = Run(toolchain: swiftVersion, value: syntaxTextView.text)
    let compilation = Compilation(run: run)
    
    do {
      let jsonData = try JSONEncoder().encode(compilation)
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        return
      }
      webSocketManager?.send(text: jsonString)
    } catch {
      print("Can't encode")
    }
  }
  
  @IBAction func changeSwiftVersion(_ sender: UIBarButtonItem) {
    let swiftVersionAlert = UIAlertController(title: nil,
                                              message: "Choose Swift toolchain version",
                                              preferredStyle: .actionSheet)
    
    let alertActions = SwiftToolchain.allCases.map { version in
      UIAlertAction(title: version.description, style: .default) { [weak self] _ in
        self?.swiftVersion = version
      }
    }
    swiftVersionAlert.addActions(alertActions)
    
    present(swiftVersionAlert, animated: true, completion: nil)
  }
}

extension ViewController: SyntaxTextViewDelegate {
  func lexerForSource(_ source: String) -> Lexer {
    SwiftLexer()
  }
}
