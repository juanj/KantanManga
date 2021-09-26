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

    func setProgress(current: Int, total: Int) {
        progressLabel?.text = "Transferring sentences to Anki (\(current)/\(total))"
        progressView.progress = Float(current)/Float(total)
    }

    func updateReport(report: String) {
        reportTextView?.text = report
    }
}
