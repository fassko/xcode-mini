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
  
  private let lexer = SwiftLexer()
  
  private var isConnected = false
  
  let webSocketQueue = OperationQueue()
  private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: webSocketQueue)
  private lazy var webSocketTask = session.webSocketTask(with: URL(string: "ws://online.swiftplayground.run/terminal")!)
  
  private var swiftVersion: SwiftToolchain! = SwiftToolchain.latestVersion {
    didSet {
      swiftVersionButton.title = "Swift \(String(describing: swiftVersion.description))"
    }
  }
  
  fileprivate func receiveMessage() {
    webSocketTask.receive { [weak self] result in
      switch result {
      case .success(let message):
        switch message {
        case .string(let text):
          DispatchQueue.main.async {
            do {
              guard let data = text.data(using: .utf8) else { return }
              let result = try JSONDecoder().decode(Result.self, from: data)
              self?.resultTextView.text = result.output.value
              self?.resultTextView.textColor = result.output.annotations.isEmpty ? .white : .red
              self?.syntaxTextView.contentTextView.resignFirstResponder()
            } catch {
              print(error)
            }
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webSocketTask.resume()
    
    syntaxTextView.theme = DefaultSourceCodeTheme()
    syntaxTextView.delegate = self
  }
}

extension ViewController: URLSessionWebSocketDelegate {
  func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
    receiveMessage()
    
    DispatchQueue.main.async { [weak self] in
      self?.isConnected = true
      self?.compileIcon.isEnabled = true
    }
  }
  
  func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
    print("close")
  }
}

extension ViewController {
  @IBAction func compile(_ sender: Any) {
    
    resultTextView.clear()
    
    guard isConnected else { return }
    
    let run = Run(toolchain: swiftVersion, value: syntaxTextView.text)
    let compilation = Compilation(run: run)
    
    do {
      let jsonData = try JSONEncoder().encode(compilation)
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        return
      }
      webSocketTask.send(.string(jsonString)) { error in
        if let error = error {
          print("Can't send to compile \(error)")
        }
      }
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

extension ViewController: SyntaxTextViewDelegate {
  func lexerForSource(_ source: String) -> Lexer {
    return lexer
  }
}
