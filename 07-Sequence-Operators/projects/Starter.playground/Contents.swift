import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK:- 7.0 Sequence Operators

// MARK:- 7.1 Finding Values
// MARK:- 7.1.1 min example
example(of: "min") {
    // 1
    let publisher = [1, -50, 246, 0].publisher
    // 2
    // Emits all f the values and finishes then finds the minimum and sends that to the sink.
    publisher
        .print("publisher")
        .min()
        .sink(receiveValue: { print("Lowest value is \($0)")})
        .store(in: &subscriptions)
}
// MARK:- 7.1.1.1 Min Non-Comparable
example(of: "min non-Comparable") {
    // 1
    let publisher = ["12345", "ab", "hello world"]
        .compactMap{ $0.data(using: .utf8)}
        .publisher
    
    // 2 Data doesn't conform
    publisher
        .print("publisher")
        .min(by: { $0.count < $1.count })
        .sink(receiveValue: { data in
            // 3
            let string = String(data: data, encoding: .utf8)!
            print("Smallest data is \(string), \(data.count) bytes")
        })
}

// MARK:- 7.1.2 Max
example(of: "max") {
    // 1
    let publisher = ["A", "F", "Z", "E"].publisher
    // 2
    publisher
        .print("publisher")
        .max()
        .sink(receiveValue: { print("Highest Value is \($0)")})
        .store(in: &subscriptions)
}

// MARK:- 7.1.3 First
example(of: "first", action: {
    // 1
    let publisher = ["A", "B", "C"].publisher
    // 2
    publisher
        .print("publisher")
        .first()
        .sink(receiveValue: { print("First value is \($0)")})
        .store(in: &subscriptions)
})

// MARK:- 7.1.3 First(where:)
example(of: "first(where:)", action: {
    // 1
    let publisher = ["A", "B", "C", "H", "E"].publisher
    // 2
    publisher
        .print("publisher")
        .first(where: { "Hello World".contains($0)})
        .sink(receiveValue: { print("First value is \($0)")})
        .store(in: &subscriptions)
})

// MARK:- 7.1.4 last
// Also has last(where:) -- just like "first(where:)
example(of: "last", action: {
    let publisher = ["A", "B", "C"].publisher
    // 2
    publisher
        .print("publisher")
        .last()
        .sink(receiveValue: { print("Last value is \($0)")})
        .store(in: &subscriptions)
})

// MARK:- 7.1.4 output(at:)
example(of: "output(at:)") {
    let publisher = ["A", "B", "C"].publisher
    // 2
    publisher
        .print("publisher")
        .output(at: 1)
        .sink(receiveValue: { print("Value at index 1 is: \($0)")})
        .store(in: &subscriptions)
}

// MARK:- 7.1.4 output(in:)
example(of: "output(at:)") {
    let publisher = ["A", "B", "C", "D", "E", "F"].publisher
    // 2
    publisher
        .print("publisher")
        .output(in: 1...3)
        .sink(receiveValue: { print("Value in range is: \($0)")})
        .store(in: &subscriptions)
}

// MARK:- 7.2 Querying the Publisher

// MARK:- 7.2.1 Count
example(of: "count") {
    let publisher = ["A", "B", "C"].publisher
    // 2
    publisher
        .print("publisher")
        .count()
        .sink(receiveValue: { print("Total # of Items: \($0)")})
        .store(in: &subscriptions)
}

// MARK:-7.2.2  Contains
example(of: "Contains", action: {
    let publisher = ["A", "B", "C", "D", "E", "F"].publisher
    let letter = "C"
    // 2
    publisher
        .print("publisher")
        .contains(letter)
        .sink(receiveValue: { contains in
            print(contains ? "Published emitted \(letter)!"
                : "Publisher never emitted \(letter)")
        })
        .store(in: &subscriptions)
})

// MARK:- 7.2.2.1 Contains(where:)
example(of: "contains(where:)") {
    // Create struct
    struct Person {
        let id: Int
        let name: String
    }
    // Create list of people
    let people = [
        (456, "Dylan Perry"),
        (123, "Ariel Tipton"),
        (556, "Elgin Perry")
    ]
    .map(Person.init)
    .publisher
    
    people
        .contains(where: {$0.id == 800 || $0.name == "Dylan Perry"})
        .sink(receiveValue: { contains in
            print(contains ? "Matches Criteria" : "Couldn't find a math for the criteria")
        })
        .store(in: &subscriptions)
}

// MARK:- 7.2.3 allSatisfy
example(of: "allSatisfy") {
    //let publisher = stride(from: 0, to: 5, by: 2).publisher
    let publisher = stride(from: 0, to: 5, by: 1).publisher

    publisher
        .print("publisher")
        .allSatisfy { $0 % 2 == 0}
        .sink(receiveValue: { allEven in
            print(allEven ? "All numbers are even" : "Something is odd...")
        })
        .store(in: &subscriptions)
}

// MARK:- 7.2.4 Reduce
example(of: "reduce") {
    let publisher = ["Hel", "lo", " ", "Wor", "ld", "!"].publisher
    
    // Verbose
//    publisher
//        .print("publisher")
//        .reduce(""){ accumulator, value in
//            accumulator + value
//        }
//        .sink(receiveValue: {print("Reduced into \($0)")})
//        .store(in: &subscriptions)
    
    // Less verbose
    publisher
        .print("publisher")
        .reduce("", +)
        .sink(receiveValue: {print("Reduced into \($0)")})
        .store(in: &subscriptions)
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
