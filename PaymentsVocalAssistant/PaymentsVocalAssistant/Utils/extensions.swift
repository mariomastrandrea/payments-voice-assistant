//
//  extensions.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 23/01/24.
//

import Foundation

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
    
    /**
     Returns a new `String` without the specified initial part (if any)
     */
    func removeLeading(_ substring: String) -> String {
        guard self.starts(with: substring) else { return self }
        return self.replacingCharacters(in: self.range(of: substring)!, with: "")
    }
    
    func matches(_ pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern)
        
        return regex.firstMatch(in: self, options: [],
                         range: NSRange(location: 0, length: self.utf16.count)) != nil
    }
}
