//
//  AnkiConnectManager.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import Foundation

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
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let response = try jsonDecoder.decode(AnkiConnectResponse<ResponseResult>.self, from: data)
                    if let error = response.error {
                        completion(.failure(AnkiConnectError(description: error)))
                    } else {
                        completion(.success(response.result))
                    }
                } catch {
                    completion(.failure(error))
                }
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
}
