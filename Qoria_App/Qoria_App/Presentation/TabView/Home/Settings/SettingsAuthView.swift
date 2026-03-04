//
//  SettingsAuthView.swift
//  Qoria_App
//
//  Temporary auth controls for manual login/logout from Settings.
//

import SwiftUI

struct SettingsAuthView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var statusText: String = ""
    @State private var isLoggedIn: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .padding(12)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))

            SecureField("Password", text: $password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))

            HStack(spacing: 12) {
                Button {
                    Task { await login() }
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)

                Button {
                    logout()
                } label: {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isLoading || !isLoggedIn)
            }

            if isLoading {
                ProgressView("Please wait…")
            }

            Text(isLoggedIn ? "Status: Logged in" : "Status: Logged out")
                .font(.subheadline)
                .foregroundStyle(isLoggedIn ? Color.green : Color.secondary)

            if !statusText.isEmpty {
                Text(statusText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            Spacer()
        }
        .padding(16)
        .onAppear {
            isLoggedIn = !(AuthTokenStore.shared.accessToken ?? "").isEmpty
        }
    }

    private func login() async {
        isLoading = true
        statusText = ""
        defer { isLoading = false }

        do {
            let json = try await NetworkCall.shared.loginWithEmail(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )

            let data = json["data"]
            let accessToken = data["access"].string ?? data["access_token"].string
            let refreshToken = data["refresh"].string ?? data["refresh_token"].string

            guard let accessToken, !accessToken.isEmpty else {
                statusText = "Login succeeded but access token was missing."
                return
            }

            AuthTokenStore.shared.accessToken = accessToken
            AuthTokenStore.shared.refreshToken = refreshToken
            isLoggedIn = true
            statusText = "Login successful."
        } catch {
            isLoggedIn = false
            statusText = "Login failed: \(error.localizedDescription)"
        }
    }

    private func logout() {
        AuthTokenStore.shared.clear()
        isLoggedIn = false
        statusText = "Logged out successfully."
    }
}

#Preview {
    SettingsAuthView()
}
