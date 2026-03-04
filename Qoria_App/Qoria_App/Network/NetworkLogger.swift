//
//  NetworkLogger.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation
import Alamofire

final class NetworkLogger: EventMonitor {

    enum Level { case none, basic, verbose }
    let level: Level

    init(level: Level = .basic) {
        self.level = level
    }

    let queue = DispatchQueue(label: "net.logger.queue")

    func requestDidResume(_ request: Request) {
        guard level != .none else { return }

        print("➡️ [\(request.id)] \(request.request?.httpMethod ?? "") \(request.request?.url?.absoluteString ?? "")")

        if level == .verbose {
            request.cURLDescription { cURL in
                print("🧾 cURL:\n\(cURL)")
            }
        }
    }

    func request<Value>(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Value, AFError>
    ) {
        guard level != .none else { return }

        let code = response.response?.statusCode ?? -1
        print("⬅️ [\(request.id)] status=\(code)")

        if level == .verbose {
            if let data = response.data, !data.isEmpty {
                if let jsonObj = try? JSONSerialization.jsonObject(with: data),
                   let pretty = try? JSONSerialization.data(withJSONObject: jsonObj, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: pretty, encoding: .utf8) {
                    print("📦 body:\n\(str)")
                } else if let str = String(data: data, encoding: .utf8) {
                    print("📦 body:\n\(str)")
                }
            }

            if let err = response.error {
                if err.isExplicitlyCancelledError {
                    return
                }
                print("❌ error:", err)
            }
        }
    }
}
