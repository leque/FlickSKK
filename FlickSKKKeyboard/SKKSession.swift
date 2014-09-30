
//
//  SKKSession.swift
//  FlickSKK
//
//  Created by mzp on 2014/09/29.
//  Copyright (c) 2014年 BAN Jun. All rights reserved.
//

import Foundation

class SKKSession {
    let inputMode : [SKKInputMode:InputMode]
    var currentMode : SKKInputMode = .Hirakana
    let dictionary : SKKDictionary

    init(delegate : SKKDelegate, dict : String) {
        dictionary = SKKDictionary(path: dict)
        inputMode = [
            .Hirakana: HirakanaInputMode(delegate: delegate, dict: dictionary),
            .Katakana: KatakanaInputMode(delegate: delegate, dict: dictionary)
        ]
    }

    func handle(event : KeyEvent, shift : Bool) {
        let m : InputMode? = inputMode[currentMode]
        m?.handle(event, shift: shift, changeMode: { (mode : SKKInputMode) -> () in
            self.currentMode = mode
        })
    }
}
