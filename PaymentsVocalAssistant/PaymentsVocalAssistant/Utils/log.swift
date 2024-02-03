//
//  Log.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 23/01/24.
//

import Foundation

enum LogType {
    case error
    case warning
    case info
    case success
    
    var symbol: String {
        switch self {
        case .error:   return "❌"
        case .warning: return "⚠️"
        case .info:    return "ℹ️"
        case .success: return "✅"
        }
    }
}

private func log(_ messages: [String], type: LogType = .info) {
    if !GlobalConfig.enableLogs { return }
    
    for m in messages {
        if m.isEmpty {
            print()
        }
        else {
            print("\(type.symbol) Log: \(m)")
        }
    }
}

func log(_ messages: String..., type: LogType = .info) {
    log(messages, type: type)
}

func logError(_ messages: String...) {
    log(messages, type: .error)
}

func logWarning(_ messages: String...) {
    log(messages, type: .warning)
}

func logInfo(_ messages: String...) {
    log(messages, type: .info)
}

func logSuccess(_ messages: String...) {
    log(messages, type: .success)
}

func logElapsedTimeInMs<T, E>(
    of operationName: String,
    type: LogType = .info,
    since: Date? = nil,
    _ operation: () -> Result<T, E>
) -> Result<T, E> where E: Error {
    
    let t0: Date
    
    if let since = since {
        t0 = since
    }
    else {
        t0 = Date()
    }
    
    // execute operation
    let result = operation()
        
    // log elapsed time only if operation has been successfully executed
    if result.isSuccess {
        let tf = Date()
        let elapsedMs = 1000.0 * tf.timeIntervalSince(t0)
        log("Elapsed time for \(operationName): \(elapsedMs) ms", type: type)
    }
    
    return result
}

func asyncLogElapsedTimeInMs<T, E>(
    of operationName: String,
    type: LogType = .info,
    since: Date? = nil,
    _ operation: () async -> Result<T, E>
) async -> Result<T, E> where E: Error {
    
    let t0: Date
    
    if let since = since {
        t0 = since
    }
    else {
        t0 = Date()
    }
    
    // execute operation
    let result = await operation()
        
    // log elapsed time only if operation has been successfully executed
    if result.isSuccess {
        let tf = Date()
        let elapsedMs = 1000.0 * tf.timeIntervalSince(t0)
        log("Elapsed time for \(operationName): \(elapsedMs) ms", type: type)
    }
    
    return result
}
