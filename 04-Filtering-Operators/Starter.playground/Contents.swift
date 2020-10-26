import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK:- 4.1.0 Filter Operator
example(of: "filter") {
    // 1. Create Array of numbers to filter.
    let numbers = (1...10).publisher
    
    // 2 Example of Filter working
    numbers
        .filter{ $0.isMultiple(of: 3)}
        .sink(receiveValue: {
            print("\($0) is a multilpe of 3")
        })
        .store(in: &subscriptions)
}
// MARK:- 4.1.1 Remove Duplicates
example(of: "removeDuplicates"){
    // 1. Create string of words and make it a publisher.
    let words = "Hey hey there! want to listen to me mister mister ?"
    let publisher = words.components(separatedBy: " ").publisher
    // doesn't remove the first Hey - cause its capitalized.
    publisher
        .removeDuplicates()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

// MARK:- 4.2.0 Compacting and Ignoring
example(of: "compactMap"){
    // 1. Create a publisher that emits strings
    let strings = ["a", "1.24", "3", "def", "45", "0.23"]
    let publisher = strings.publisher
    
    publisher
        .compactMap { Float($0) }
        .sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

// MARK:- 4.2.1 Ignoring Output
example(of: "ignoreOutput") {
    // Create numbers
    let numbers = (1...10_000)
    let publisher = numbers.publisher
    publisher
        // Dont send on output
        .ignoreOutput()
        .sink(receiveCompletion: { print("Receieved Completion: \($0)")},
              receiveValue: { print("Recieved Value: \($0)")}
        )
        .store(in: &subscriptions)
    
}

// MARK:- 4.3.0 Finding Values
// MARK:- 4.3.1 first(where:) and print() Operator
example(of: "first(where:)") {
    let numbers = (1...10)
    let publisher = numbers.publisher
    publisher
        .print("Numbers")
        .first(where: { $0 % 2 == 0})
        .sink(receiveCompletion: { print("Completion Recieved: \($0)")},
              receiveValue: { print("Value recieved: \($0)") }
        )
        .store(in: &subscriptions)
}

// MARK:- 4.3.2 last(where:)
example(of: "last(where:)") {
    let numbers = (1...9)
    let publisher = numbers.publisher
    
    publisher
        .print("Numbers")
        .last(where: { $0 % 2 == 0})
        .sink(receiveCompletion: { print("Completion Recieved: \($0)")},
              receiveValue: { print("Value recieved: \($0)") }
        )
        .store(in: &subscriptions)
    
    let passthroughPublisher = PassthroughSubject<Int, Never>()
    passthroughPublisher
        .print("Numbers")
        .last(where: { $0 % 2 == 0})
        .sink(receiveCompletion: { print("Completion Recieved: \($0)")},
                receiveValue: { print("Value recieved: \($0)") }
        )
        .store(in: &subscriptions)
    
    passthroughPublisher.send(1)
    passthroughPublisher.send(2)
    passthroughPublisher.send(3)
    passthroughPublisher.send(4)
    passthroughPublisher.send(5)
    //  Won't end until you send completion.
    passthroughPublisher.send(completion: .finished)
}

// MARK:- 4.4.0 Dropping Values
// MARK:- 4.4.1 Drop First / dropFirst()
example(of: "dropFirst()") {
    let numbers = (1...10)
    let publisher = numbers.publisher
    
    publisher
        .print("Numbers")
        // Only Start publishing after the 8th one. Drop first 8 values
        .dropFirst(8)
        .sink(receiveCompletion: { print("Completion Recieved: \($0)")},
              receiveValue: { print("Value recieved: \($0)") }
        )
        .store(in: &subscriptions)
}

// MARK:- 4.4.2 drop(while:)
example(of: "drop(while:)") {
    let numbers = (1...10)
    let publisher = numbers.publisher
    
    publisher
        .drop(while: {
                print("x")
                return $0 % 5 != 0
            }
        )
        .sink(receiveValue: { print($0)})
        .store(in: &subscriptions)
}

// MARK:- 4.4.3 drop(untilOutputFrom:)
example(of: "drop(untilOutputFrom:)") {
    // 1  Create two PassthroughSubjects to manually send values thru
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .drop(untilOutputFrom: isReady)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    (1...5).forEach { n in
        taps.send(n)
        if n == 3 {
          isReady.send()
        }
    }
}

// MARK:- 4.5.0 Limiting Values
// MARK:- 4.5.1 Prefix
// Prefix is the opposite of dropFirst
example(of: "prefix") {
    let numbers = (1...10)
    let publisher = numbers.publisher
    
    publisher
        .prefix(2)
        .sink(receiveCompletion: { print("Completion Recieved: \($0)")},
              receiveValue: { print($0)}
        )
        .store(in: &subscriptions)
}

// MARK:- 4.5.2 prefix(while:)
example(of: "prefix(while:)") {
    let numbers = (1...10)
    let publisher = numbers.publisher
    
    publisher
        .prefix(while: { $0 < 3 })
        .sink(receiveCompletion: { print("Completion Recieved: \($0)")},
              receiveValue: { print($0)}
        )
        .store(in: &subscriptions)
}

// MARK:- 4.5.3 prefix(untilOutputFrom:)
example(of: "prefix(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .prefix(untilOutputFrom: isReady)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    (1...5).forEach { n in
        taps.send(n)
        if n == 3 {
          isReady.send()
        }
    }
}

/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
