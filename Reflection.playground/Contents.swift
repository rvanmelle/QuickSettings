//: Playground - noun: a place where people can play

import UIKit

struct Foo {
    let x = 3
    let y = true
    let z = 3.0
}

//let lotteryTuple = (4, 8, 15, 16, 23, 42)
let lotteryTuple = Foo()

// create a mirror of the tuple
let lotteryMirror = Mirror(reflecting: lotteryTuple)

var lotteryArray: [Int] = []
for (index,value) in lotteryMirror.children {
    print(Mirror(reflecting: value).subjectType)
    if let number = value as? Int {
        lotteryArray.append(number)
    }
}
print(lotteryArray)

enum Dogs : String {
    case Lady
    case Tramp
}

let dogMirror = Mirror(reflecting: Dogs.self)

print(dogMirror.subjectType)
for c in dogMirror.children {
    print(c)
}

// loop over the elements of the mirror to build an array
/*var lotteryArray: [Int] = []
for i in 0..<lotteryMirror.count {
    let (index, mirror) = lotteryMirror[i]
    if let number = mirror.value as? Int {
        lotteryArray.append(number)
    }
}
print(lotteryArray)*/