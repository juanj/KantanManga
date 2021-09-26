//
//  TransferringSentencesViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 19/09/21.
//

import UIKit

class TransferringSentencesViewController: UIViewController {
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var reportTextView: UITextView!

    var progress = 0 {
        didSet {
            updateProgress()
        }
    }

    private let total: Int
    init(total: Int) {
        self.total = total
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateProgress()
    }

    private func updateProgress() {
        progressLabel?.text = "Transferring sentences to Anki (\(progress)/\(total))"
        progressView.progress = Float(progress)/Float(total)
    }

    func updateReport(report: String) {
        reportTextView?.text = report
    }
}
