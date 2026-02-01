//
//  ContentView.swift
//  TesterGui
//
//  Created by Manabu Tonosaki on 2026-01-26.
//

import SwiftUI
import Tono

struct ContentView: View {
    @State private var hashCode: String = ""
    @State private var imageForHash: Image = Image(.notyet)
    @State private var dataForHash: Data?
    @State private var selectedImage: Image?
    @State private var imageData: Data?
    
    var body: some View {
        ScrollView {
            Button {
                if let selectedImage = selectedImage {
                    hashCode = ImageHash.getImageHash(image: selectedImage) { img, dat in
                        imageForHash = img
                        dataForHash = dat
                    }
                    print("hash code = \(hashCode)")
                }
            } label: {
                HStack {
                    if let selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96, height: 96)
                    } else {
                        ProgressView()
                            .frame(width: 96, height: 96)
                    }
                    
                    imageForHash
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                }
            }
            .onAppear {
                prepareImage()
            }
            
            VStack {
                TextField("hash code", text: $hashCode)
                Text("count = \(hashCode.utf8.count)")
                
                if let dataForHash = dataForHash {
                    let data = Array(dataForHash)
                    let str = data.map { String(format: "%02X", $0) }.joined()
                    ForEach(0..<min(32, (str.count / 64) + 1), id: \.self) { index in
                        Text("\(StrUtil.mid(str, start: index * 64, length: 64))")
                            .font(Font.custom("Menlo", size: 10))
                    }
                }
            }
        }
        .padding()
    }
    
    private func prepareImage() {
        if let result = ImageUtil.resizeImage(Image(.sampleLogoAlpha), maxPixel: 96) {
            self.selectedImage = result.image
            self.imageData = result.data
        }
    }
}

#Preview {
    ContentView()
}
