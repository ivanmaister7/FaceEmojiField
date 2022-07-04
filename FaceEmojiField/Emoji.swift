//
//  Emoji.swift
//  FaceEmojiField
//
//  Created by Master on 29.06.2022.
//

import Foundation

public enum Emoji {
    case 😠
    case 😬
    case 😱
    case 😆
    case 😑
    case 😢
    case 😮
        
    init(emotion: String){
        switch (emotion) {
        case ("Angry"):
            self = .😠
        case ("Disgust"):
            self = .😬
        case ("Fear"):
            self = .😱
        case ("Happy"):
            self = .😆
        case ("Sad"):
            self = .😢
        case ("Surprise"):
            self = .😮
        default:
            self = .😑
        }
    }
}
