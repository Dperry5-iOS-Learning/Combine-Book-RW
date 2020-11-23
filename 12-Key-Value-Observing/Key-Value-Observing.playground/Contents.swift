import UIKit
import Combine

func introduction() {
    class TestObject: NSObject {
        @objc dynamic var integerProperty: Int = 0
        @objc dynamic var stringProperty: String = "Yoo"
        @objc dynamic var arrayProperty: [Float] = []

    }
    
    let obj = TestObject()
    
    // .prior gets you the previous value.
    let subscription = obj.publisher(for: \.integerProperty, options: [.prior])
        .sink {
            print("integerProperty changes to \($0)")
        }
    
    let subscription2 = obj.publisher(for: \.stringProperty)
        .sink {
            print("String Property changes to \($0)")
        }
    
    let subscription3 = obj.publisher(for: \.arrayProperty)
        .sink {
            print("Array Property changes to \($0)")
        }
    
    
    obj.integerProperty = 100
    obj.stringProperty = "new string"
    obj.arrayProperty.append(1.0)
    obj.integerProperty = 200
    obj.stringProperty = "another one"
    obj.arrayProperty.append(5.0)
    obj.arrayProperty.popLast()
}

func observableObjectExample() {
    class MonitorObject: ObservableObject {
        @Published var boolProperty = false
        @Published var stringProperty = ""
    }
    let object = MonitorObject()
    let subscription = object.$boolProperty.sink(receiveValue: {
        bool in
        print("BOOL Received: \(bool)")
    })
    
    object.boolProperty = true
    object.boolProperty = false
}

introduction()
observableObjectExample()
