//
//  AnkiConnectManager.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import Foundation

enum AnkiConnectManagerError: Error {
    case missingData
    case invalidResponse
    case no200Response(code: Int)
    case invalidAnkiConnectResponse(body: String)
    case emptyResult
}

class AnkiConnectManager {
    private let url: URL
    private let key: String?
    private let session: URLSession

    private enum Const {
        static let ankiConnectVersion = 6
    }

    init(url: URL, key: String?, session: URLSession = .shared) {
        self.url = url
        self.key = key
        self.session = session
    }

    private func sendRequestFor<Params: Encodable, ResponseResult: Decodable>(
        action: String,
        params: Params,
        completion: @escaping (Result<ResponseResult, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        let requestBody = AnkiConnectRequest(action: action, version: Const.ankiConnectVersion, params: params, key: key)
        let jsonEncoder = JSONEncoder()
        do {
            let data = try jsonEncoder.encode(requestBody)
            request.httpBody = data
        } catch {
            completion(.failure(error))
            return
        }
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request) { data, response, error in
            let wrappedCompletion: (Result<ResponseResult, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }

            if let error = error {
                wrappedCompletion(.failure(error))
                return
            }

            guard let data = data else {
                wrappedCompletion(.failure(AnkiConnectManagerError.missingData))
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                let response = try jsonDecoder.decode(AnkiConnectResponse<ResponseResult>.self, from: data)
                if let error = response.error {
                    wrappedCompletion(.failure(AnkiConnectError(description: error)))
                } else if let result = response.result {
                    wrappedCompletion(.success(result))
                } else {
                    wrappedCompletion(.failure(AnkiConnectManagerError.emptyResult))
                }
            } catch {
                wrappedCompletion(.failure(error))
            }
        }
        task.resume()
    }

    func checkConnection(completion: @escaping (Result<Void, Error>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            let wrappedCompletion: (Result<Void, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }

            if let error = error {
                wrappedCompletion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                wrappedCompletion(.failure(AnkiConnectManagerError.invalidResponse))
                return
            }

            guard response.statusCode == 200 else {
                wrappedCompletion(.failure(AnkiConnectManagerError.no200Response(code: response.statusCode)))
                return
            }

            guard let data = data else {
                wrappedCompletion(.failure(AnkiConnectManagerError.missingData))
                return
            }

            guard let responseString = String(data: data, encoding: .utf8) else {
                wrappedCompletion(.failure(AnkiConnectManagerError.invalidResponse))
                return
            }

            if responseString.starts(with: "AnkiConnect") {
                wrappedCompletion(.success(()))
            } else {
                wrappedCompletion(.failure(AnkiConnectManagerError.invalidAnkiConnectResponse(body: responseString)))
            }
        }
        task.resume()
    }

    func getDeckNames(completion: @escaping (Result<[String], Error>) -> Void) {
        sendRequestFor(action: "deckNames", params: [String: String](), completion: completion)
    }

    func getModelNames(completion: @escaping (Result<[String], Error>) -> Void) {
        sendRequestFor(action: "modelNames", params: [String: String](), completion: completion)
    }

    func getModelFields(_ model: String, completion: @escaping (Result<[String], Error>) -> Void) {
        sendRequestFor(action: "modelFieldNames", params: ["modelName": model], completion: completion)
    }

    func addNoteWith(
        model: String,
        deck: String,
        fields: [String: String],
        picture: CreateNoteRequest.Picture?,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        let note = CreateNoteRequest(model: model, deck: deck, fields: fields, picture: picture)
        sendRequestFor(action: "addNote", params: ["note": note], completion: completion)
    }
}
