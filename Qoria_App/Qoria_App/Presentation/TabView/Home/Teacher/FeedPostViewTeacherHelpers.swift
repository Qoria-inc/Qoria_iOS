//
//  FeedPostViewTeacherHelpers.swift
//  Qoria_App
//
//  Helper types and functions for FeedPostViewTeacher (date formatting, media kind, status style, audio session).
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - Audio session for feed video (ambient, mix with others – reduces HAL/Simulator noise)
enum FeedVideoAudioSession {
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

    /// Resolved media kind: two videos → side-by-side, one video → single, else images (1–3).
    static func from(_ json: dynamicJSON) -> FeedPostMediaKind {
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
        // "images" array: [ { "url": "...", "width": ..., "height": ... }, ... ]
        let imageURLs = (json.images.array ?? []).compactMap { $0.url.string }.filter { !$0.isEmpty }
        if !imageURLs.isEmpty {
            return .images(Array(imageURLs.prefix(3)))
        }
        return .images([])
    }
}

// MARK: - Date helpers for feed post timestamps
enum FeedPostDateHelpers {
    static func createdAtDisplayText(from rawTimestamp: String) -> String {
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

        let days = seconds / 86400
        if days < 7 {
            return days == 1 ? "1d ago" : "\(days)d ago"
        }

        let weeks = days / 7
        if weeks < 4 {
            return weeks == 1 ? "1w ago" : "\(weeks)w ago"
        }

        let months = days / 30
        if months < 12 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        }
        let years = days / 365
        return years == 1 ? "1 year ago" : "\(years) years ago"
    }

    static func parseISO8601Date(_ value: String) -> Date? {
        let formatterWithFraction = ISO8601DateFormatter()
        formatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFraction.date(from: value) {
            return date
        }

        let formatterWithoutFraction = ISO8601DateFormatter()
        formatterWithoutFraction.formatOptions = [.withInternetDateTime]
        return formatterWithoutFraction.date(from: value)
    }
}

// MARK: - Competition status style for feed post tag
enum FeedPostCompetitionStatusHelpers {
    static func styleForStatus(title: String) -> CompetitionCurrentStatusTagView.Style {
        if title.lowercased().contains("winners announced") {
            return .winnersAnnounced
        } else if title.lowercased().contains("voting ends") {
            return .votingEndsSoon
        } else {
            return .neutral
        }
    }
}
