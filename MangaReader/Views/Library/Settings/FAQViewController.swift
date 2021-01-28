//
//  FAQViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 28/01/21.
//

import UIKit
import WebKit

class FAQViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "FAQ"
        loadFile()
    }

    private func loadFile() {
        guard let fileUrl = Bundle.main.url(forResource: "FAQ", withExtension: "html"),
              let content = try? String(contentsOf: fileUrl) else { return }
        webView.loadHTMLString(content, baseURL: fileUrl)
        webView.navigationDelegate = self
    }
}

extension FAQViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
