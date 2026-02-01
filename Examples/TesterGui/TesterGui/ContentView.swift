//
//  ContentView.swift
//  TesterGui
//
//  Created by Manabu Tonosaki on 2026-01-26.
//

import SwiftUI
import UIKit
import Tono

struct ContentView: View {
    @State private var hashCode: String = ""
    @State private var imageForHash: Image = Image(.notyet)
    @State private var dataForHash: Data?
    
    var body: some View {
        ScrollView {
            Button {
                guard let image = UIImage(named: "sampleLogoAlpha") else {
                    return
                }
                hashCode = ImageHash.getImageHash(image: image){ img, dat in
                    imageForHash = img
                    dataForHash = dat
                }
            }
            label: {
                HStack {
                    Image(.sampleLogoAlpha)
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    imageForHash
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                }
            }
            VStack {
                TextField("hash code", text: $hashCode)
                Text("count = \(hashCode.utf8.count)")
                if let dataForHash = dataForHash {
                    let data = Array(dataForHash)
                    let str = data.map { String(format: "%02X", $0) }.joined()
                    ForEach(0..<32) { index in
                        Text("\(StrUtil.mid(str, start: index * 64, length: 64))")
                            .font(Font.custom("Menlo", size: 10))
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
