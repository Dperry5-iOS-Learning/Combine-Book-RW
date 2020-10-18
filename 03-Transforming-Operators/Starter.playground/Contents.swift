import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK:- 3.1.0 Collect Operator
example(of: "collect") {
    let array = ["A", "B", "C", "D", "E"]
    // Using Collect means isntead of array publishing one value at a time
    // We send all published events together.
    // Be careful when working with collect() and other buffering operators that do not require specifying a count or limit. They will use an unbounded amount of memory to store received values.
    // When you use paramter to pass in there - it limits how many times you collect - i.e collect tw = [A, B], [C, D], [E]
    
    array
    .publisher
    .collect(2)
    .sink(receiveCompletion: { print("Completion: \($0)") }, receiveValue: { print("Recieve: \($0)")} )
    .store(in: &subscriptions)
}

// MARK:- 3.2 Map Operators
example(of: "Map") {
    // Create a Number Formatter
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // Create New Array of Numbers, and turn it into a publisher.
    let array = [123, 4, 56]
    // Turn it into a publisher
    array
        .publisher
        .map {
            formatter.string(for: NSNumber(integerLiteral: $0)) ?? ""
        }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

// MARK:- 3.2.1 - Map Key Paths
example(of: "Map Key Paths") {
    
    // Create publisher using Coordinate from helper stuff.
    let publisher = PassthroughSubject<Coordinate, Never>()
    // Subscribe to the publisher
    publisher
        .map(\.x, \.y)
        .sink(receiveValue: { x, y in
            print("The coordinate at (\(x), \(y)) is in quadrant", quadrantOf(x: x, y: y))
        })
        .store(in: &subscriptions)

    publisher.send(Coordinate(x: 10, y: -8))
    publisher.send(Coordinate(x: 0, y: 5))
}

// MARK:- 3.2.2 - tryMap Operator
example(of: "tryMap") {
    // Create Just Publisher
    Just("Directory name doesn't exist")
        .tryMap {
            try FileManager.default.contentsOfDirectory(atPath: $0)
        }
        .sink(receiveCompletion: { print("Completion: \($0)") }, receiveValue: { print("Recieve: \($0)")} )
        .store(in: &subscriptions)
}

// MARK:- 3.3.0 - Flattening Publishers
example(of: "flatMap") {
    // Create two chatter objects
    let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte.")
    let james = Chatter(name: "James", message: "Hey, I'm James.")
    
    let chat = CurrentValueSubject<Chatter, Never>(charlotte)
    
    // .max(2) -- ONLY reciee from 2 publishers
    chat
        .flatMap(maxPublishers: .max(2)){ $0.message }
        .sink(receiveValue: { print($0) })
    
    charlotte.message.value = "Charlotte: How's it going?"
    chat.value = james
    
    let morgan = Chatter(name: "Morgan", message: "Hey guys! What are you up too?")
    chat.value = morgan
    
    charlotte.message.value = "Did you hear something?"
}

// MARK:- 3.4.0 - Replacing Upstream Output
example(of: "replaceNil") {
    // Create Publisher of Optional Strings
    let array = ["A", nil, "C"]
    array.publisher
        .replaceNil(with: "-")
        // Get rid of optional
        .map { $0! }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

// MARK:- 3.4.1 - Replacing Upstream Output
example(of: "replaceEmpty(with:)") {
    let empty = Empty<Int, Never>()
    empty
        .replaceEmpty(with: 1)
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

// MARK:- 3.5.0 Incrementally Transforming Output

// MARK:- 3.5.1 Scan Operator
example(of: "scan", action: {
    var dailyGainLoss: Int {
        .random(in: -10...10)
    }
    
    let august2019 = (0..<22)
        .map {_ in dailyGainLoss }
        .publisher
    
    august2019
        .scan(50) { latest, current in
            max(0, latest + current)
        }
        .sink(receiveValue: { _ in })
        .store(in: &subscriptions)
    
})


