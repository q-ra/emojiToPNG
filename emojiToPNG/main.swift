//
//  main.swift
//  emojiToPNG
//
//  Created by Michał Kurkowski on 26/07/2018.
//  Copyright © 2018 Michał Kurkowski. All rights reserved.
//

import AppKit
import CoreGraphics

class EmojiAsImage {
  var nsgCtx: NSGraphicsContext?
  var cgImg: CGImage?
  var codepoints: [String]?
  
  init(){
    
  }
  
  func initDefaultDir() -> String {
    let flMngr = FileManager.default
    let newPath = flMngr.urls(for: .desktopDirectory, in: .userDomainMask).first!.path + "/emojiPngs"
    if flMngr.fileExists(atPath: newPath) {
      try? flMngr.removeItem(atPath: newPath)
    }
    try? flMngr.createDirectory(atPath: newPath, withIntermediateDirectories: true, attributes: nil)
    return newPath
  }
  
  func drawVerticallyCentered(string: String, fontSize: CGFloat) throws {
    
    let nsString = NSString.init(string: string)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    
    let attributes = [
      NSAttributedStringKey.paragraphStyle: paragraphStyle,
      NSAttributedStringKey.font: NSFont.systemFont(ofSize: fontSize),
      NSAttributedStringKey.foregroundColor: NSColor.red
    ]
    
    let size = nsString.size(withAttributes: attributes)
    if (size.height <= 0 || size.width <= 0) {
      throw EmojiError.runtimeError("Wrong context size")
    }
    let ctx = createContext(height: Int(size.height), width: Int(size.width))
    let centeredRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    self.nsgCtx = NSGraphicsContext.init(cgContext: ctx, flipped: false)
    NSGraphicsContext.current = self.nsgCtx
    nsString.draw(in: centeredRect, withAttributes: attributes)
    self.cgImg = self.nsgCtx!.cgContext.makeImage()
  }
  
  func writeCGImage(destinationURL: URL) -> Bool {
    guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return false }
    CGImageDestinationAddImage(destination, self.cgImg!, nil)
    return CGImageDestinationFinalize(destination)
  }
  
  func getCodePoints(path: String? = nil) {
    let link = path != nil ? path : "/Users/kura/Desktop/unicode.txt"
    let url = URL(fileURLWithPath: link!)
    let content = try! String(contentsOf: url, encoding: .utf8)
    self.codepoints = content.characters.split{ $0 == "\n" }.map(String.init)
    
  }
  
  private
  func createContext(height: Int, width: Int) -> CGContext {
    let numComponents = 4
    let bitmapInfo =  CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
    let colorspace = CGColorSpaceCreateDeviceRGB()
    
    return CGContext.init(
      data: nil,
      width: width,
      height: height,
      bitsPerComponent: 16,
      bytesPerRow: 16 * numComponents * width,
      space: colorspace,
      bitmapInfo: bitmapInfo
      )!
  }
  
}

enum EmojiError: Error {
  case runtimeError(String)
}

let emoji = EmojiAsImage()
let dfltDir = emoji.initDefaultDir()
emoji.getCodePoints()
for codePoint in emoji.codepoints! {
  let hex = Int(codePoint, radix: 16)!
  do {
    try emoji.drawVerticallyCentered(string: "\(UnicodeScalar(hex)!)", fontSize: 100)
    emoji.writeCGImage(destinationURL: URL(fileURLWithPath: dfltDir + "/" + codePoint + ".png"))
  } catch {
    print("\(hex) - no emoji")
  }
}






