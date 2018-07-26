//
//  main.swift
//  emojiToPNG
//
//  Created by Michał Kurkowski on 26/07/2018.
//  Copyright © 2018 Michał Kurkowski. All rights reserved.
//

import AppKit

class EmojiAsImage {
  
  func dirPath() -> String {
    let pathFromArgs: String? = CommandLine.argc > 1 ? CommandLine.arguments[1] : nil
    var isDir  = false as ObjCBool
    let flMngr = FileManager.default
    if pathFromArgs != nil && flMngr.fileExists(atPath: pathFromArgs!, isDirectory: &isDir) {
      return pathFromArgs!
    } else {
      return flMngr.urls(for: .desktopDirectory, in: .userDomainMask).first!.path
    }
  }
}

let emoji = EmojiAsImage()
print(emoji.dirPath())

