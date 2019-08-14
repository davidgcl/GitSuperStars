// reference:   https://benoitpasquier.com/ios-swift-mvvm-pattern/
//              https://benoitpasquier.com/optimise-uicollectionview-swift/

import Foundation

typealias CompletionHandler = (() -> Void)
class DynamicValue<T> {
    
    public var value : T {
        didSet {
            self.notify()
        }
    }
    
    private var observers = [String: CompletionHandler]()
    
    init(_ value: T) {
        self.value = value
    }
    
    public func addObserver(_ observer: NSObject, completionHandler: @escaping CompletionHandler) {
        observers[observer.description] = completionHandler
    }
    
    public func addAndNotify(_ observer: NSObject, completionHandler: @escaping CompletionHandler) {
        self.addObserver(observer, completionHandler: completionHandler)
        self.notify()
    }
    
    public func removeObserver(_ observer: NSObject) {
        observers.removeValue(forKey: observer.description)
    }
    
    public func removeObservers() {
        observers.removeAll()
    }
    
    private func notify() {
        observers.forEach({ $0.value() })
    }
    
    deinit {
        observers.removeAll()
    }
}
