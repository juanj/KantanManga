//
//  AboutView.swift
//  Kantan-Manga
//
//  Created by Juan on 27/06/20.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Image("app-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.primary, lineWidth: 4)
            )
            Text("Kantan Manga")
            Text(getVersionString())
        }
    }

    func getVersionString() -> String {
        var string = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            string = "\(version) (\(build))"
        }
        return string
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
