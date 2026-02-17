//
//  FeedPostViewStudent.swift
//  Qoria_App
//
//  Feed post content view for Student user type. Layout identical to Teacher (FeedPostView).
//

import SwiftUI

struct FeedPostViewStudent: View {

    // MARK: - State

    @State private var showUnderDevelopment = false
    var image: String?
    var images: [String]? = nil
    
    // MARK: - Computed Properties
    
    /// Returns images array: prefers `images` if provided, otherwise wraps single `image` in array
    private var mediaItems: [String] {
        if let images = images, !images.isEmpty {
            return Array(images.prefix(2)) // Max 2 images
        } else if let image = image {
            return [image]
        } else {
            return ["ic_postImg1"] // Default fallback
        }
    }
    
    private var hasMultipleImages: Bool {
        mediaItems.count == 2
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 52, height: 52)

                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        Color.Profile.borderWhiteBase.opacity(1),
                                        Color.Profile.borderBlueBase.opacity(0.5),
                                        Color.Profile.borderWhiteBase.opacity(1),
                                        Color.Profile.borderBlueBase.opacity(0.5),
                                        Color.Profile.borderWhiteBase.opacity(1)
                                    ],
                                    center: .center
                                ),
                                lineWidth: 1
                            )
                            .frame(width: 52, height: 52)

                        Image("ic_proImg")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    }
                    .frame(width: 52, height: 52)

                    VStack(alignment: .leading) {
                        Text("Sarah Morgan")
                            .font(.system(size: 16, weight: .medium))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.Text.onDark)

                        Text("2h ago")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.Text.secondary)
                    }
                }

                Spacer()

                Button {
                    showUnderDevelopment = true
                } label: {
                    Image("ic_more")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }

            Text("Exploring trust and balance through simple partner movements.")
                .font(.body)
                .foregroundStyle(Color.Text.onDark)
                .fixedSize(horizontal: false, vertical: true)

            // MARK: - Media Content (Single or Side-by-Side)
            if hasMultipleImages {
                // Two images side-by-side inside a square container
                let containerSize = UIScreen.main.bounds.width

                ZStack {
                    // Container background #17171A (reuses app bar surface)
                    Color.Surface.appBar

                    HStack(spacing: 2) {
                        ForEach(Array(mediaItems.enumerated()), id: \.offset) { index, img in
                            Image(img)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: (containerSize - 6) / 2,     // 2px left + 2px right + 2px gap
                                    height: containerSize - 4           // 2px top + 2px bottom
                                )
                                .clipped()
                                .cornerRadius(6)
                                .overlay(alignment: .bottomTrailing) {
                                    // Volume button only on right image
                                    if index == 1 {
                                        Button {
                                            showUnderDevelopment = true
                                        } label: {
                                            Image("ic_volumeWithBG")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 32, height: 32)
                                                .padding(8)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                        }
                    }
                    .padding(2)
                }
                .frame(width: containerSize, height: containerSize)
                .padding(.horizontal, -16)
            } else {
                // Single image (original behavior)
                Image(mediaItems.first ?? "ic_postImg1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width, alignment: .center)
                    .clipped()
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            showUnderDevelopment = true
                        } label: {
                            Image("ic_volumeWithBG")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, -16)
            }

            HStack(spacing: 20) {

                Button { showUnderDevelopment = true } label: {
                    HStack(spacing: 4) {
                        Image("ic_clap")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text("128")
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)

                Button { showUnderDevelopment = true } label: {
                    HStack(spacing: 4) {
                        Image("ic_comment")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("24")
                            .font(.system(size: 14))
                            .padding(.leading, 5)
                    }
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                Button { showUnderDevelopment = true } label: {
                    HStack(spacing: 4) {
                        Image("ic_share")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("9")
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)

                Button { showUnderDevelopment = true } label: {
                    Image("ic_save")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)
            }
            .font(.system(size: 14))
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        .clipped()
        .background(Color.Surface.post)
        .alert("Under development", isPresented: $showUnderDevelopment) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This feature is under development.")
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FeedPostViewStudent(image: "ic_postImg1")
            .padding(.top, 16)
            .padding(.horizontal, 0)
    }
    .preferredColorScheme(.dark)
}
