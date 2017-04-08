//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

struct Address {
    var street: String
}

struct Person {
    var name: String = "John"
    var age: Int = 42
    var dutch: Bool = false
    let width : Float = 20.0
    var address: Address? = Address(street: "Market St.")
    
    static func foo() {
        
    }
}

let john = Person()

/*extension Mirror {
    var childs: [(String,Mirror)] {
        var result: [(String, Mirror)] = []
        for i in 0..<self.children.count {
            result.append(self.children[i])
        }
        return result
    }
}*/

protocol JSON {
    func toJSON() throws -> AnyObject?
}

let m = Mirror(reflecting: john)

for (name,m) in m.children {
    print(name!, m)
}
print(m.children)
