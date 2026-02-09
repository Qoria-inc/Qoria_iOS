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
                Task { await runTestCall() }
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
            await runTestCall()
        }
    }

    @MainActor
    private func runTestCall() async {
        isLoading = true
        errorText = nil
        output = ""

        do {
            let json = try await NetworkCall.shared.getTestTodo()
            output = json.description
        } catch let NetworkError.httpStatus(code, data) {
            let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            errorText = "HTTP \(code)\n\(body)"
        } catch {
            errorText = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    ContentView(heading: "Content View")
}
