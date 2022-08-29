//
//  TranslatorProtocol.swift
//  converter
//
//  Created by Artem Raykh on 27.08.2022.
//

import Foundation

enum MangaqueTranslation {
    case none
    case custom(translator: MangaqueTranslator)
}

protocol MangaqueTranslator {
    func performTranslate(
        untranslatedText: String,
        comletionHandler: @escaping (
            _ translatedText: String?,
            _ error: Error?
        ) -> ()
    )
}
