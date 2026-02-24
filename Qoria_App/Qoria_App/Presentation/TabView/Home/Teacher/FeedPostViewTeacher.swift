//
//  FeedPostViewTeacher.swift
//  Qoria_App
//
//  Feed post content view for Teacher user type.
//

import SwiftUI
import AVFoundation
import AVKit

// MARK: - Audio session for feed video (ambient, mix with others – reduces HAL/Simulator noise)
private enum FeedVideoAudioSession {
    private static var didConfigure = false
    static func configureOnce() {
        guard !didConfigure else { return }
        didConfigure = true
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true, options: [])
        } catch { }
    }
}

// MARK: - Feed Post Media Kind (1: images 1–3, 2: single HLS video, 3: two HLS videos side by side)
enum FeedPostMediaKind {
    case images([String])
    case singleVideo(hlsURL: String, thumbnailURL: String?)
    case twoVideos(left: String, right: String, leftThumbnail: String?, rightThumbnail: String?)
}

// MARK: - Preference key for scroll-based play (post index -> media frame in global coords)
struct MediaFramesPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] { [:] }
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct FeedPostViewTeacher: View {

    // MARK: - Inputs
    /// When non-nil, the post at this index is considered “in center” for auto-play (set by HomeView from scroll).
    var focusedMediaPostIndex: Int? = nil
    /// This post’s index in the feed (used to report frame and to compare with focusedMediaPostIndex).
    var postIndex: Int = 0

    var json: dynamicJSON = dynamicJSON()
    var showsLearnThis: Bool = false

    // MARK: - Body
    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
            .clipped()
            .background(Color.Surface.post)
    }
}

// MARK: - FeedPostViewTeacher Layout
private extension FeedPostViewTeacher {
    var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            captionSection
            currentCompetitionStatusSection
            mediaSection
            actionsSection
        }
    }

    var headerSection: some View {
        HStack {
            HStack {
                profileImageSection
                profileMetaSection
            }

            Spacer()

            moreButton
        }
    }

    var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 52, height: 52)

                Circle()
                    .stroke(
                        LinearGradient(colors: [Color.Gradient.proStart, Color.Gradient.proEnd], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                    .frame(width: 52, height: 52)

                FeedMediaImage(source: json.owner_info.avatar.string ?? "")
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            }

            Image("ic_proBadgeBlue")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 26)
                .offset(x: 3, y: 2)
        }
        .frame(width: 52, height: 52)
    }

    var profileMetaSection: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 6) {
                Text(json.owner_info.name.string ?? "")
                    .font(.system(size: 16, weight: .medium))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.Text.onDark)

                Text("Teacher")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.Text.onDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LinearGradient(colors: [Color.Gradient.tagLeft, Color.Gradient.tagRight], startPoint: .leading, endPoint: .trailing), in: Capsule())
                    .overlay(
                        Capsule().stroke(AngularGradient(colors: [.white, .white, Color.Gradient.tagRight, .white], center: .center), lineWidth: 0.5))

                FeedContentTypeView(isSingleTrophy: true)
            }

            Text(createdAtDisplayText(from: json.created_at.string ?? ""))
                .font(.system(size: 14))
                .foregroundStyle(Color.Text.secondary)
        }
    }

    var moreButton: some View {
        Button {} label: {
            Image("ic_more")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }

    var captionSection: some View {
        Text(json.title.string ?? "")
            .font(.body)
            .foregroundStyle(Color.Text.onDark)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    var currentCompetitionStatusSection: some View {
        if let statusTitle = json.challenge_current_status_title.string,
           statusTitle.isEmpty == false {
            CompetitionCurrentStatusTagView(
                title: statusTitle,
                style: styleForStatus(title: statusTitle)
            )
            .padding(.top, -2)
        }
    }

    var mediaSection: some View {
        VStack(spacing: 0) {
            FeedPostMediaView(
                media: mediaKind,
                competitionStatusTitle: json.challenge_status_title.string,
                isInCenter: focusedMediaPostIndex == postIndex
            )
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: MediaFramesPreferenceKey.self, value: [postIndex: geo.frame(in: .global)])
                }
            )

            // Learn This CTA sits BELOW the media (not over it)
            if showsLearnThis {
                LearnThisButtonView {}
                    .padding(.horizontal, -16)
            }
        }
    }

    var actionsSection: some View {
        HStack(spacing: 20) {
            Button {} label: {
                HStack(spacing: 4) {
                    Image("ic_clap")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("\(json.like_count.int ?? 0)")
                        .font(.system(size: 14))
                }
            }
            .foregroundStyle(Color.Text.secondary)
            .buttonStyle(.plain)

            Button {} label: {
                HStack(spacing: 4) {
                    Image("ic_comment")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("\(json.comment_count.int ?? 0)")
                        .font(.system(size: 14))
                        .padding(.leading, 5)
                }
            }
            .foregroundStyle(Color.Text.secondary)
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Button {} label: {
                HStack(spacing: 4) {
                    Image("ic_share")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("\(json.share_count.int ?? 0)")
                        .font(.system(size: 14))
                }
            }
            .foregroundStyle(Color.Text.secondary)
            .buttonStyle(.plain)

            Button {} label: {
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
}

// MARK: - FeedPostViewTeacher Helpers
private extension FeedPostViewTeacher {
    func createdAtDisplayText(from rawTimestamp: String) -> String {
        guard let createdAt = parseISO8601Date(rawTimestamp) else {
            return rawTimestamp
        }

        let now = Date()
        let seconds = Int(now.timeIntervalSince(createdAt))
        if seconds < 60 {
            return "Just now"
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return minutes == 1 ? "1 min ago" : "\(minutes) mins ago"
        }

        let hours = minutes / 60
        if hours < 24 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        }

        let calendar = Calendar.current
        if calendar.isDateInYesterday(createdAt) {
            return "yesterday"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: createdAt)
    }

    func parseISO8601Date(_ value: String) -> Date? {
        let formatterWithFraction = ISO8601DateFormatter()
        formatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFraction.date(from: value) {
            return date
        }

        let formatterWithoutFraction = ISO8601DateFormatter()
        formatterWithoutFraction.formatOptions = [.withInternetDateTime]
        return formatterWithoutFraction.date(from: value)
    }

    /// Resolved media kind: two videos → side-by-side, one video → single, else images (1–3).
    var mediaKind: FeedPostMediaKind {
        let first = json.processed_video_hls.string ?? ""
        let second = json.processed_after_video_hls.string ?? ""
        let single = json.processed_video_hls.string ?? ""

        let firstThumb = json.processed_video_thumbnail.string ?? ""
        let secondThumb = json.processed_after_video_thumbnail.string ?? ""

        if !first.isEmpty && !second.isEmpty {
            return .twoVideos(left: first, right: second, leftThumbnail: firstThumb.isEmpty ? nil : firstThumb, rightThumbnail: secondThumb.isEmpty ? nil : secondThumb)
        }
        if !single.isEmpty {
            return .singleVideo(hlsURL: single, thumbnailURL: firstThumb.isEmpty ? nil : firstThumb)
        }
        if !first.isEmpty {
            return .singleVideo(hlsURL: first, thumbnailURL: firstThumb.isEmpty ? nil : firstThumb)
        }
        // Images: 1, 2, or max 3
        let imageList = [json.photo1.string ?? "", json.photo2.string ?? "", json.photo3.string ?? ""]
            .filter { !$0.isEmpty }
        if !imageList.isEmpty {
            return .images(Array(imageList.prefix(3)))
        }
        return .images([])
    }

    func styleForStatus(title: String) -> CompetitionCurrentStatusTagView.Style {
        if title.lowercased().contains("winners announced") {
            return .winnersAnnounced
        } else if title.lowercased().contains("voting ends") {
            return .votingEndsSoon
        } else {
            return .neutral
        }
    }
}

// MARK: - Feed Post Media View (images 1–3, single HLS video, or two HLS videos side by side)

private struct FeedPostMediaView: View {
    var media: FeedPostMediaKind
    var competitionStatusTitle: String?
    var isInCenter: Bool = false

    @State private var singleIsMuted = true
    @State private var leftIsMuted = true
    @State private var rightIsMuted = true

    private let containerSize = UIScreen.main.bounds.width
    private let twoVideosLeadingTrailingPadding: CGFloat = 4
    private let twoVideosMiddleSpacing: CGFloat = 4

    var body: some View {
        Group {
            switch media {
            case .images(let items):
                imagesLayout(items: items)
            case .singleVideo(let hlsURL, let thumbnailURL):
                singleVideoLayout(hlsURL: hlsURL, thumbnailURL: thumbnailURL)
            case .twoVideos(let left, let right, let leftThumb, let rightThumb):
                twoVideosLayout(left: left, right: right, leftThumbnail: leftThumb, rightThumbnail: rightThumb)
            }
        }
        .frame(width: containerSize, height: containerSize)
        .overlay(alignment: .bottom) {
            mediaOverlay
        }
        .padding(.horizontal, -16)
    }

    // MARK: - Case 1: 1, 2, or 3 images (same screen space)
    @ViewBuilder
    private func imagesLayout(items: [String]) -> some View {
        let safeItems = Array(items.prefix(3))
        ZStack {
            Color.Surface.appBackground
            if safeItems.isEmpty {
                FeedMediaImage(source: "ic_postImg1")
                    .frame(width: containerSize, height: containerSize)
                    .clipped()
            } else if safeItems.count == 1 {
                FeedMediaImage(source: safeItems[0])
                    .frame(width: containerSize, height: containerSize)
                    .clipped()
            } else if safeItems.count == 2 {
                HStack(spacing: 2) {
                    ForEach(Array(safeItems.enumerated()), id: \.offset) { _, src in
                        FeedMediaImage(source: src)
                            .frame(width: (containerSize - 4) / 2, height: containerSize)
                            .clipped()
                            .cornerRadius(4)
                    }
                }
                .padding(2)
            } else {
                // 3 images: top row 2, bottom row 1 (same total height as container)
                let rowHeight = (containerSize - 2) / 2
                let halfW = (containerSize - 4) / 2
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        FeedMediaImage(source: safeItems[0])
                            .frame(width: halfW, height: rowHeight)
                            .clipped()
                            .cornerRadius(4)
                        FeedMediaImage(source: safeItems[1])
                            .frame(width: halfW, height: rowHeight)
                            .clipped()
                            .cornerRadius(4)
                    }
                    FeedMediaImage(source: safeItems[2])
                        .frame(width: containerSize - 4, height: rowHeight)
                        .clipped()
                        .cornerRadius(4)
                }
                .padding(2)
            }
        }
    }

    // MARK: - Case 2: Single HLS video (full width, same space)
    private func singleVideoLayout(hlsURL: String, thumbnailURL: String?) -> some View {
        FeedVideoCellView(
            urlString: hlsURL,
            thumbnailURL: thumbnailURL,
            isInCenter: isInCenter,
            isMuted: $singleIsMuted,
            showVolumeButton: true
        )
        .frame(width: containerSize, height: containerSize)
    }

    // MARK: - Case 3: Two videos side by side; leading/trailing 5pt, 3pt between
    private func twoVideosLayout(left: String, right: String, leftThumbnail: String?, rightThumbnail: String?) -> some View {
        let totalHorizontalPadding = twoVideosLeadingTrailingPadding * 2 + twoVideosMiddleSpacing
        let halfWidth = (containerSize - totalHorizontalPadding) / 2
        return ZStack {
            Color.Surface.appBackground
            HStack(spacing: twoVideosMiddleSpacing) {
                FeedVideoCellView(
                    urlString: left,
                    thumbnailURL: leftThumbnail,
                    isInCenter: isInCenter,
                    isMuted: $leftIsMuted,
                    showVolumeButton: false
                )
                .frame(width: halfWidth, height: containerSize)
                .clipped()
                .cornerRadius(10)
                FeedVideoCellView(
                    urlString: right,
                    thumbnailURL: rightThumbnail,
                    isInCenter: isInCenter,
                    isMuted: $rightIsMuted,
                    showVolumeButton: false
                )
                .frame(width: halfWidth, height: containerSize)
                .clipped()
                .cornerRadius(10)
            }
            .padding(.leading, twoVideosLeadingTrailingPadding)
            .padding(.trailing, twoVideosLeadingTrailingPadding)
        }
    }

    @ViewBuilder
    private var mediaOverlay: some View {
        ZStack(alignment: .bottomTrailing) {
            if let title = competitionStatusTitle {
                HStack {
                    Spacer()
                    CompetitionStatusButtonView(title: title)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            switch media {
            case .singleVideo:
                EmptyView()
            case .twoVideos:
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        volumeButton(toggleLeft: $leftIsMuted, toggleRight: $rightIsMuted)
                            .padding(10)
                    }
                }
            case .images:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func volumeButton(toggleLeft: Binding<Bool>, toggleRight: Binding<Bool>) -> some View {
        Button {
            let next = !toggleLeft.wrappedValue
            toggleLeft.wrappedValue = next
            toggleRight.wrappedValue = next
        } label: {
            Image(systemName: toggleLeft.wrappedValue ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.system(size: 18))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.black.opacity(0.5), in: Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Single video cell: thumbnail until loaded, then video; auto-play when in center; optional volume in cell
private struct FeedVideoCellView: View {
    let urlString: String
    var thumbnailURL: String? = nil
    let isInCenter: Bool
    @Binding var isMuted: Bool
    var showVolumeButton: Bool = true
    @State private var isVideoReady = false

    var body: some View {
        ZStack {
            Color.Surface.appBackground
            if let thumb = thumbnailURL, !thumb.isEmpty {
                FeedMediaImage(source: thumb)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .opacity(isVideoReady ? 0 : 1)
                    .animation(.easeOut(duration: 0.2), value: isVideoReady)
            }
            FeedHLSVideoPlayer(
                urlString: urlString,
                shouldPlay: isInCenter,
                isMuted: isMuted,
                isReadyForDisplay: $isVideoReady
            )

            if showVolumeButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            $isMuted.wrappedValue = !$isMuted.wrappedValue
                        } label: {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.black.opacity(0.5), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
                }
            }
        }
        .onChange(of: isInCenter) { inCenter, _ in
            if !inCenter { isVideoReady = false }
        }
    }
}

// MARK: - HLS Video Player (AVPlayer) – play/pause from scroll position, mute by default
private struct FeedHLSVideoPlayer: View {
    let urlString: String
    var shouldPlay: Bool = true
    var isMuted: Bool = true
    @Binding var isReadyForDisplay: Bool

    var body: some View {
        FeedHLSVideoPlayerRepresentable(urlString: urlString, shouldPlay: shouldPlay, isMuted: isMuted, isReadyForDisplay: $isReadyForDisplay)
    }
}

private struct FeedHLSVideoPlayerRepresentable: UIViewRepresentable {
    let urlString: String
    var shouldPlay: Bool
    var isMuted: Bool
    @Binding var isReadyForDisplay: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isReadyForDisplay: $isReadyForDisplay)
    }

    func makeUIView(context: Context) -> UIView {
        let view = PlayerView()
        let coord = context.coordinator
        view.onReadyForDisplay = {
            DispatchQueue.main.async {
                coord.isReadyForDisplay.wrappedValue = true
            }
        }
        if shouldPlay {
            view.configure(urlString: urlString, shouldPlay: true)
            view.setMuted(isMuted)
            DispatchQueue.main.async {
                view.applyPlayPause(shouldPlay: true)
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let playerView = uiView as? PlayerView else { return }
        let coord = context.coordinator
        playerView.onReadyForDisplay = {
            DispatchQueue.main.async {
                coord.isReadyForDisplay.wrappedValue = true
            }
        }
        if shouldPlay {
            playerView.cancelTearDown()
            if playerView.currentURLString != urlString {
                playerView.configure(urlString: urlString, shouldPlay: true)
            }
            playerView.setMuted(isMuted)
            DispatchQueue.main.async {
                playerView.applyPlayPause(shouldPlay: true)
            }
        } else {
            DispatchQueue.main.async {
                context.coordinator.isReadyForDisplay.wrappedValue = false
            }
            // Avoid aggressive create/destroy churn while scrolling; pause in place.
            playerView.cancelTearDown()
            playerView.applyPlayPause(shouldPlay: false)
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        guard let playerView = uiView as? PlayerView else { return }
        coordinator.isReadyForDisplay.wrappedValue = false
        playerView.performImmediateTearDown()
    }

    class Coordinator {
        var isReadyForDisplay: Binding<Bool>
        init(isReadyForDisplay: Binding<Bool>) {
            self.isReadyForDisplay = isReadyForDisplay
        }
    }
}

private final class PlayerView: UIView {
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var statusObserver: NSKeyValueObservation?
    private var readyForDisplayObserver: NSKeyValueObservation?
    private var endObserver: Any?
    private var tearDownWorkItem: DispatchWorkItem?
    private(set) var currentURLString: String = ""
    private var pendingShouldPlay: Bool = false
    var onReadyForDisplay: (() -> Void)?

    override static var layerClass: AnyClass { AVPlayerLayer.self }

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer = layer as? AVPlayerLayer
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        playerLayer = layer as? AVPlayerLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    func configure(urlString: String, shouldPlay: Bool = false) {
        guard let url = URL(string: urlString), urlString.hasPrefix("http") else {
            removeEndObserver()
            statusObserver = nil
            playerLayer?.player = nil
            player = nil
            currentURLString = ""
            return
        }
        removeEndObserver()
        statusObserver = nil
        readyForDisplayObserver = nil
        currentURLString = urlString
        pendingShouldPlay = shouldPlay
        FeedVideoAudioSession.configureOnce()
        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 10
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.isMuted = true
        playerLayer?.player = newPlayer
        playerLayer?.videoGravity = .resizeAspectFill
        player = newPlayer

        readyForDisplayObserver = playerLayer?.observe(\.isReadyForDisplay, options: [.new]) { [weak self] layer, _ in
            guard (layer as AVPlayerLayer).isReadyForDisplay == true else { return }
            DispatchQueue.main.async { self?.onReadyForDisplay?() }
        }

        statusObserver = item.observe(\.status, options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.itemStatusDidChange()
            }
        }
        endObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.replayFromBeginning()
        }
        if item.status == .readyToPlay {
            applyPlayPause(shouldPlay: shouldPlay)
        }
    }

    private func removeEndObserver() {
        if let o = endObserver {
            NotificationCenter.default.removeObserver(o)
            endObserver = nil
        }
    }

    func cancelTearDown() {
        tearDownWorkItem?.cancel()
        tearDownWorkItem = nil
    }

    /// Defer teardown slightly to avoid FigApplicationStateMonitor / PlayerRemoteXPC errors from rapid create/destroy.
    func scheduleTearDown() {
        cancelTearDown()
        player?.pause()
        let item = DispatchWorkItem { [weak self] in
            self?.performTearDown()
        }
        tearDownWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: item)
    }

    /// Release player and observers when scrolled out of center.
    private func performTearDown() {
        tearDownWorkItem = nil
        pendingShouldPlay = false
        removeEndObserver()
        statusObserver = nil
        readyForDisplayObserver = nil
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerLayer?.player = nil
        currentURLString = ""
    }

    func performImmediateTearDown() {
        cancelTearDown()
        performTearDown()
    }

    private func replayFromBeginning() {
        guard pendingShouldPlay else { return }
        player?.seek(to: .zero) { [weak self] finished in
            guard finished else { return }
            self?.player?.play()
        }
    }

    private func itemStatusDidChange() {
        guard let item = player?.currentItem, item.status == .readyToPlay else { return }
        applyPlayPause(shouldPlay: pendingShouldPlay)
    }

    func applyPlayPause(shouldPlay: Bool) {
        pendingShouldPlay = shouldPlay
        guard player != nil else { return }
        if shouldPlay {
            player?.play()
        } else {
            player?.pause()
        }
    }

    func setMuted(_ muted: Bool) {
        player?.isMuted = muted
    }

    deinit {
        cancelTearDown()
        removeEndObserver()
        statusObserver = nil
        player?.pause()
        player = nil
        playerLayer?.player = nil
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FeedPostViewTeacher()
            .padding(.top, 16)
            .padding(.horizontal, 0)
    }
    .preferredColorScheme(.dark)
}
