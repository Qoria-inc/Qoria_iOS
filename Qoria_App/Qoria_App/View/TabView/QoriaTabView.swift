//
//  QoriaTabView.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import SwiftUI

// MARK: - Root Container

struct QoriaTabView: View {

    enum Tab: Hashable {
        case text, learn, post, discover, settings
    }

    @State private var selection: Tab = .text

    /// Space reserved so content does not hide under the floating bar
    private let bottomInset: CGFloat = 78

    var body: some View {
        ZStack(alignment: .bottom) {

            // Your actual tab content
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: bottomInset)
                }

            // Floating glass tab bar
            QoriaTabBar(selection: $selection)
                .padding(.horizontal, 18)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selection {
        case .text:
            NavigationStack { TextTab() }
        case .learn:
            NavigationStack { LearnTab() }
        case .post:
            NavigationStack { PostTab() }
        case .discover:
            NavigationStack { DiscoverTab() }
        case .settings:
            NavigationStack { SettingsTab() }
        }
    }
}

// MARK: - Qoria Tab Bar (Figma Accurate + iOS Glass)

struct QoriaTabBar: View {

    @Binding var selection: QoriaTabView.Tab

    private let activeColor = Color.white
    private let inactiveColor = Color(red: 0.65, green: 0.65, blue: 0.70)

    var body: some View {
        HStack(spacing: 0) {

            tabItem(.text, title: "Home", icon: "house.circle")
            tabItem(.learn, title: "Learn", icon: "info.circle")

            postItem()

            tabItem(.discover, title: "Discover", icon: "magnifyingglass.circle")
            tabItem(.settings, title: "Settings", icon: "gearshape.circle")
        }
        .frame(height: 65)
        .background(GlassBackground())
        .clipShape(Capsule(style: .continuous))
    }

    // MARK: - Items

    private func tabItem(
        _ tab: QoriaTabView.Tab,
        title: String,
        icon: String
    ) -> some View {
        Button {
            selection = tab
        } label: {
            VStack(spacing: 0) {

                Image(systemName: icon)
                    .resizable()
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(selection == tab ? activeColor : inactiveColor)
                    .frame(width: 28, height: 28)
                    .padding(.bottom, 6)

                Text(title)
                    .font(.system(size: 10))
                    .lineSpacing(14)
                    .foregroundStyle(selection == tab ? activeColor : inactiveColor)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func postItem() -> some View {
        Button {
            selection = .post
        } label: {
            VStack(spacing: 0) {

                Image(systemName: "arrow.up.circle")
                    .resizable()
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .padding(.bottom, 6)

                Text("Post")
                    .font(.system(size: 10))
                    .lineSpacing(14)
                    .foregroundStyle(.white)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.15))
            .clipShape(Capsule(style: .continuous))
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Glass Background
private struct GlassBackground: View {
    var body: some View {
        Capsule(style: .continuous)
            .fill(.ultraThinMaterial).opacity(0.95)
            .overlay(
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.5)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
            )
        )
    }
}

// MARK: - Placeholder Tabs (Replace with Real Screens)

private struct TextTab: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(0..<10, id: \.self) { _ in
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 400)
                        
                        Text("Test Test Test")
                            .bold()
                    }
                }
            }
            .padding(0)
        }
        .navigationBarHidden(true)
    }
}

private struct LearnTab: View {
    var body: some View {
        Text("Learn")
            .font(.title)
            .navigationBarHidden(true)
    }
}

private struct PostTab: View {
    var body: some View {
        Text("Post")
            .font(.title)
            .navigationBarHidden(true)
    }
}

private struct DiscoverTab: View {
    var body: some View {
        Text("Discover")
            .font(.title)
            .navigationBarHidden(true)
    }
}

private struct SettingsTab: View {
    var body: some View {
        Text("Settings")
            .font(.title)
            .navigationBarHidden(true)
    }
}

#Preview {
    QoriaTabView()
        .preferredColorScheme(.dark)
}
