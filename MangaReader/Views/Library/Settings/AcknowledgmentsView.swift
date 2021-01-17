//
//  AcknowledgmentsView.swift
//  Kantan-Manga
//
//  Created by Juan on 4/10/20.
//

import SwiftUI

struct AcknowledgmentsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Libraries")
                    .font(.title)
                Spacer()
            }
            Text("""
                ZIPFoundation
                GCDWebServer/WebUploader
                GRDB
                SwiftTesseract
                UnrarKit
                MeCab - Nara Institute of Science and Technology / Taku Kudou
                """)
            Text("Dictionary file")
                .font(.title)
            Text("""
                JMdict/EDICT
                """)
            Text("Demo Manga")
                .font(.title)
            Text("Hikaru Nakamura - Creative Commons")
            Text("Other")
                .font(.title)
            Text("This app was heavily inspired by jisho.org and Yomichan web addon")
            Spacer()
        }
        .padding(20)
    }
}
