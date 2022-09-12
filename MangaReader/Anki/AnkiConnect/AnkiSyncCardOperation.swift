//
//  AnkiSyncCardOperation.swift
//  Kantan-Manga
//
//  Created by Juan on 25/09/21.
//

import Foundation

class AnkiSyncCardOperation: Operation {
    private enum State {
        case initial, started, done
    }

    override var isAsynchronous: Bool { true }
    override var isExecuting: Bool { state == .started }
    override var isFinished: Bool { state == .done }

    private var state: State = .initial {
        willSet {
            willChangeValue(forKey: "isExecuting")
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
            didChangeValue(forKey: "isFinished")
        }
    }
    private(set) var error: Error?
    private(set) var noteId: UInt?

    let sentence: Sentence
    private let config: AnkiConfig
    private let manager: AnkiConnectManager
    init(sentence: Sentence, config: AnkiConfig, manager: AnkiConnectManager) {
        self.sentence = sentence
        self.config = config
        self.manager = manager
    }

    override func start() {
        guard !isCancelled else {
            state = .done
            return
        }
        state = .started
        main()
    }

    override func main() {
        let fields = joinFields()

        var picture: CreateNoteRequest.Picture?
        if let imageData = sentence.imageData, let imageField = config.imageField {
            picture = CreateNoteRequest.Picture(
                filename: getFileName(),
                data: imageData.base64EncodedString(),
                fields: [imageField]
            )
        }

        manager.addNoteWith(
            model: config.note,
            deck: config.deck,
            fields: fields,
            picture: picture
        ) { [weak self] result in
            switch result {
            case let .success(noteId):
                self?.noteId = noteId
            case let .failure(error):
                self?.error = error
            }
            self?.state = .done
        }
    }

    private func addAnkiNewLines(to string: String) -> String {
        return string.replacingOccurrences(of: "\n", with: "<br />")
    }

    private func joinFields() -> [String: String] {
        var fields = [String: String]()
        let keys = [config.wordField, config.readingField, config.sentenceField, config.definitionField]
        let values = [sentence.word, sentence.reading, sentence.sentence, addAnkiNewLines(to: sentence.definition)]

        for (key, value) in zip(keys, values) {
            guard let key = key else { continue }
            if var currentValue = fields[key] {
                currentValue += "<br />"
                currentValue += value
                fields[key] = currentValue
            } else {
                fields[key] = value
            }
        }

        return fields
    }

    private func getFileName() -> String {
        var components = ["KM"]
        if !sentence.sentence.trimmingCharacters(in: .whitespaces).isEmpty {
            components.append(sentence.sentence)
        }
        if !sentence.word.trimmingCharacters(in: .whitespaces).isEmpty {
            components.append(sentence.word)
        }

        return components.joined(separator: "-").appending(".png")
    }
}
