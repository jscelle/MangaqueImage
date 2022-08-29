//
//  TranslatorProtocol.swift
//  converter
//
//  Created by Artem Raykh on 27.08.2022.
//

import Foundation

public enum MangaqueTranslation {
    case none
    case custom(translator: MangaqueTranslator)
}

public protocol MangaqueTranslator {
    func performTranslate(
        untranslatedText: String,
        comletionHandler: @escaping (
            _ translatedText: String?,
            _ error: Error?
        ) -> ()
    )
}
