//
//  QoriaTabView.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import SwiftUI

struct QoriaTabView: View {

    enum Tab: Hashable { case home, learn, post, discover, settings }

    @State private var selection: Tab = .home
    @StateObject private var homeViewModel = AppContainer.shared.makeHomeViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .home:
                    NavigationStack { HomeView(viewModel: homeViewModel) }
                case .learn:
                    NavigationStack { ContentView(heading: "Learn") }
                case .post:
                    NavigationStack { ContentView(heading: "Post") }
                case .discover:
                    NavigationStack { ContentView(heading: "Discover") }
                case .settings:
                    NavigationStack {
                        SettingsAuthView {
                            selection = .home
                            homeViewModel.loadHome()
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            QoriaTabBar(selection: $selection)
                .padding(.horizontal, 18)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .task {
            homeViewModel.loadHome()
        }
    }
}

struct QoriaTabBar: View {

    @Binding var selection: QoriaTabView.Tab

    private let activeColor = Color.white
    private let inactiveColor = Color(red: 0.65, green: 0.65, blue: 0.70)

    var body: some View {
        HStack(spacing: 0) {
            tabItem(.home, title: "Home", icon: "homeTabIconOff", selectedIcon: "homeTabIconOn")
            tabItem(.learn, title: "Learn", icon: "learnTabIconOff", selectedIcon: "learnTabIconOn")
            tabItem(.post, title: "Post", icon: "postTabIconOff", selectedIcon: "postTabIconOn",isPrimary: true)
            tabItem(.discover, title: "Discover", icon: "discoverTabIconOff", selectedIcon: "discoverTabIconOn")
            tabItem(.settings, title: "Settings", icon: "settingsTabIconOff", selectedIcon: "settingsTabIconOn")
        }
        .frame(height: 65)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule(style: .continuous)
                        .fill(Color.black.opacity(0.50))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                )
        }
        .clipShape(Capsule(style: .continuous))
    }

    private func tabItem(_ tab: QoriaTabView.Tab, title: String, icon: String, selectedIcon: String? = nil, isPrimary: Bool = false) -> some View {

        let isSelected = (selection == tab)

        let imageName = isSelected ? (selectedIcon ?? icon) : icon

        let textColor = isPrimary ? Color.white : (isSelected ? activeColor : inactiveColor)

        return Button {
            selection = tab
        } label: {
            VStack(spacing: 0) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .padding(.bottom, 6)

                Text(title)
                    .font(.system(size: 10))
                    .foregroundStyle(textColor)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isPrimary {
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.15))
                    }
                }
            )
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QoriaTabView()
}
