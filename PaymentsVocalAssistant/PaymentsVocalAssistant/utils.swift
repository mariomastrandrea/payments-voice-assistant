//
//  Utils.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

func log(_ messages: String...) {
    if !GlobalConfig.enableLogs { return }
    
    for m in messages {
        print("⚠️ Custom Log: \(m)")
    }
}

func delay(ms: Int) async {
    let seconds = Double(ms) / 1000.0
    await withCheckedContinuation { continuation in
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            continuation.resume()
        }
    }
}

struct File {
    let name: String
    let _extension: String
    let description: String

    init(name: String, extension _extension: String) {
        self.name = name
        self._extension = _extension
        self.description = "\(name).\(_extension)"
    }
}
