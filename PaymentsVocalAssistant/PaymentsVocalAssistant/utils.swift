//
//  Utils.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation


// MARK: utility functions

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
        print("\(type.symbol) Log: \(m)")
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

func delay(ms: Int) async {
    let seconds = Double(ms) / 1000.0
    await withCheckedContinuation { continuation in
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            continuation.resume()
        }
    }
}

func logElapsedTimeInMs<T, E>(
    of operationName: String,
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
        log("Elapsed time for \(operationName): \(elapsedMs) ms", type: .info)
    }
    
    return result
}


// MARK: utility extensions

extension Result {
    var isFailure: Bool {
        switch self {
            case .failure(_): return true
            case .success(_): return false
        }
    }
    
    var isSuccess: Bool {
        return !isFailure
    }
    
    var failure: Failure? {
        switch self {
            case .failure(let error): return error
            case .success(_): return nil
        }
    }
    
    var success: Success? {
        switch self {
            case .failure(_): return nil
            case .success(let content): return content
        }
    }
    
    func failureResult<T>() -> Result<T, Failure>! {
        switch self {
            case .failure(let error): return .failure(error)
            case .success(_): return nil
        }
    }
    
    func successResult<E>() -> Result<Success, E>! {
        switch self {
            case .failure(_): return nil
            case .success(let content): return .success(content)
        }
    }
}

extension Array where Element: Comparable {
    func argMax() -> Int? {
        if self.count == 0 { return nil }
        
        var max: Element = self[0]
        var indexOfMax: Int = 0
        
        for (i, element) in self.enumerated() {
            if element > max {
                max = element
                indexOfMax = i
            }
        }
        
        return indexOfMax
    }
    
    func argMin() -> Int? {
        if self.count == 0 { return nil }
        
        var min: Element = self[0]
        var indexOfMin: Int = 0
        
        for (i, element) in self.enumerated() {
            if element < min {
                min = element
                indexOfMin = i
            }
        }
        
        return indexOfMin
    }
}

extension String {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}


// MARK: utility entities

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


