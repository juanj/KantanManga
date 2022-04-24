//
//  LocalNetworkAuthorization.swift
//  Kantan-Manga
//
//  Created by Juan on 23/04/22.
//

import Foundation
import Network

/// Utility to trigger and wait for local network access dialog
/// https://stackoverflow.com/a/67758105

public class LocalNetworkAuthorization: NSObject {
    private var browser: NWBrowser?
    private var netService: NetService?
    private var completion: ((Bool) -> Void)?

    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard #available(iOS 14.0, *) else {
            completion(true)
            return
        }

        self.completion = completion

        // Create parameters, and allow browsing over peer-to-peer link.
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        // Browse for a custom service type.
        let browser = NWBrowser(for: .bonjour(type: "_bonjour._tcp", domain: nil), using: parameters)
        self.browser = browser
        browser.stateUpdateHandler = { newState in
            switch newState {
            case let .failed(error):
                print(error.localizedDescription)
            case .ready, .cancelled:
                break
            case .waiting:
                self.reset()
                self.completion?(false)
            default:
                break
            }
        }

        netService = NetService(domain: "local.", type: "_lnp._tcp.", name: "LocalNetworkPrivacy", port: 1100)
        netService?.delegate = self

        self.browser?.start(queue: .main)
        netService?.publish()
    }

    private func reset() {
        browser?.cancel()
        browser = nil
        netService?.stop()
        netService = nil
    }
}

@available(iOS 14.0, *)
extension LocalNetworkAuthorization: NetServiceDelegate {
    public func netServiceDidPublish(_: NetService) {
        reset()
        completion?(true)
    }
}
