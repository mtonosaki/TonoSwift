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
    let image = Image(.sampleHorz)

    
    var body: some View {
        ScrollView {
            Button {
                hashCode = ImageHash.computeHashCode(image)
#if os(iOS)
                print("iOS   - hash code = \(hashCode)")
#else
                print("macOS - hash code = \(hashCode)")
#endif
            } label: {
                VStack {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                }
            }
            VStack {
                TextField("hash code", text: $hashCode)
                Text("hash count = \(hashCode.utf8.count)")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
