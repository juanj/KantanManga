//
//  TransferringSentencesViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 19/09/21.
//

import UIKit

protocol TransferringSentencesViewControllerDelegate: AnyObject {
    func didSelectClose(_ transferringSentencesViewController: TransferringSentencesViewController)
    func didSelectDone(_ transferringSentencesViewController: TransferringSentencesViewController)
}

class TransferringSentencesViewController: UIViewController {
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var reportTextView: UITextView!

    var progress = 0 {
        didSet {
            updateProgress()
        }
    }

    private var doneButton: UIBarButtonItem?

    private let total: Int
    private weak var delegate: TransferringSentencesViewControllerDelegate?
    init(total: Int, delegate: TransferringSentencesViewControllerDelegate) {
        self.total = total
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        updateProgress()
    }

    private func configureNavBar() {
        title = "Sync"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        doneButton.isEnabled = false
        self.doneButton = doneButton

        navigationItem.rightBarButtonItem = doneButton
    }

    private func updateProgress() {
        progressLabel?.text = "Transferring sentences to Anki (\(progress)/\(total))"
        progressView.progress = Float(progress)/Float(total)
        if progress == total {
            doneButton?.isEnabled = true
        }
    }

    @objc func close() {
        delegate?.didSelectClose(self)
    }

    @objc func done() {
        delegate?.didSelectDone(self)
    }

    func updateReport(report: String) {
        reportTextView?.text = report
    }
}
