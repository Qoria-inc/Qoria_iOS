//
//  ContentView.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import SwiftUI

struct ContentView: View {

    @State private var isLoading = false
    @State private var output = ""
    @State private var errorText: String?
    @State private var didAutoRun = false
    var heading: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 10) {
                Spacer()
                Image(systemName: "network")
                Text(heading)
                    .font(.headline)
                Spacer()
            }

            if isLoading {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if let errorText {
                Text(errorText)
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }

            Text(output.isEmpty ? "No data yet." : output)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .center)
                .textSelection(.enabled)
                .padding()

            Button {
                
            } label: {
                Text("Run Test Call")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            
            Spacer()
        }
        .padding()
        .task {
            guard !didAutoRun else { return }
            didAutoRun = true
        }
    }

}

#Preview {
    ContentView(heading: "Content View")
}
