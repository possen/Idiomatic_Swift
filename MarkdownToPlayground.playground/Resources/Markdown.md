
# Transforming Code into Beautiful, Idiomatic Swift

Adapted to Swift 4 from Raymond Hettinger's talk at pycon US 2013 by Paul Ossenbruggen [github](https://github.com/possen) [video](http://www.youtube.com/watch?feature=player_embedded&v=OSGv2VnC0go), [slides](https://speakerdeck.com/pyconslides/transforming-code-into-beautiful-idiomatic-python-by-raymond-hettinger-1).
Many of the nice idioms of Python are here in Swift and some are even nicer. Python idioms apply well to Swift in most cases. Although, the types can add more verbosity. Even if you don't know Python, these approches should be easy to understand both becuase Python is sometimes thought of a runnable psuedocode and because the same approach are encouraged in most modern languages.

The code examples and direct quotes are all from Raymond's talk where appropriate. If something does not make sense in Swift I deleted that section. I tried to stay close to the original examples, but in some cases added more where Swift has more alternatives.

**See playground attachment below to try all these examples**
``` swift
import Foundation
```
## Looping over a range of numbers
``` swift
for i in [0, 1, 2, 3, 4, 5] {
    print(i * i)
}
```
### Open range
``` swift
for i in 0..<6 {
    print(i * i)
}
```
### Closed range
``` swift
for i in 0...5 {
    print(i * i)
}
```
Swift does not offer square of an integer, only the `Pow` function which takes Doubles, like most C family languages. Another approach which is faster is to use the bit shift operator.
``` swift
for i in 0...5 {
    print(i << 2)
}
```
## Looping over a collection
### Not great
``` swift
let colors = ["red", "green", "blue", "yellow"]

for i in 0..<colors.count {
    print(colors[i])
}
```
### Better
``` swift
for color in colors {
    print(color)
}
```
## Looping backwards
### Not good
``` swift
for index in stride(from: colors.count-1, to: 0, by: -1) {
    print(colors[index])
}
```
### Better
``` swift
for i in (0..<colors.count).reversed() {
    print(colors[i])
}
```
### Best
``` swift
for color in colors.reversed() {
    print(color)
}
```
## Looping over a collection and indices
``` swift
for i in 0..<colors.count {
    print("\(i) ---> \(colors[i])")
}
```
### Better
``` swift
for (i, color) in colors.enumerated() {
    print("\(i) ---> \(color)")
}
```
> It's fast and beautiful and saves you from tracking the individual indices and incrementing them.

> Whenever you find yourself manipulating indices [in a collection], you're probably doing it wrong.
## Looping over two collections
### Not preferred
``` swift
var names = ["raymond", "rachel", "matthew"]

let n = min(names.count, colors.count)
for i in 0..<n {
    print("\(names[i]) ---> \(colors[i])")
}
```
### Better
``` swift
for (name, color) in zip(names, colors) {
    print("\(name) ---> \(color)")
}
```
## Looping in sorted order
### Forward sorted order
``` swift
for color in colors.sorted() {
    print(color)
}
```
### Backwards sorted order
``` swift
for color in colors.sorted(by:>) {
    print(color)
}
```
## Custom Sort Order
### Not Great
``` swift
func compare_length(c1: String, c2: String) -> Bool {
    if c1.count < c2.count { return true }
    return false
}

print(colors.sorted(by: compare_length))
```
### Better
``` swift
print(colors.sorted { $0.count < $1.count } )

var d = ["matthew": "blue", "rachel": "green", "raymond": "red"]

for k in d {
    print(k)  // returns key value tuples unlike python
}
```
### Deleting while iterating is ok in Swift since the keys are a copy (not so in Python).
``` swift
for k in d.keys {
    if k.hasPrefix("r") {
        d[k] = nil
    }
}
print(d)
```
When should you use the second and not the first? When you're mutating the dictionary.

> If you mutate something while you're iterating over it, this is OK compared to Objective-C or Python because they use value semantics.

## Looping over dictionary keys and values

``` swift
d = ["matthew": "blue", "rachel": "green", "raymond": "red"]
```

### This creates an optional in second param, better to use other option below.
``` swift
for k in d.keys {
    print("\(k) ---> \(d[k])")
}

for k in d.keys {
    print("\(k) ---> \(String(describing: d[k]))") // fix warning
}
```
### Better
``` swift
for (k, v) in d {
    print("\(k) ---> \(v)")
}
```
### Simple, basic way to count. A good start for beginners.
``` swift
let moreColors = ["red", "green", "blue", "red", "green", "red"]
var counts: [String: Int] = [:]
for color in moreColors {
    if var count = counts[color] {
        count += 1
        counts[color] = count
    } else {
        counts[color] = 1
    }
}
print(counts)
```
**{'blue': 1, 'green': 2, 'red': 3}**

### Better
``` swift
counts = [:]
for color in moreColors {
    counts[color, default: 0] += 1
}
print(counts)
```
**{'blue': 1, 'green': 2, 'red': 3}**

## Grouping with dictionaries -- Part I and II
``` swift
names = ["raymond", "rachel", "matthew", "roger", "betty", "melissa", "judith", "charlie"]
```
In this example, we're grouping by name length
### Good
``` swift
var dict:[Int: [String]] = [:]
for name in names {
    let key = name.count
    if var value = dict[key] {
        value += [name]
        dict[key] = value  // assignment is important here because of value types.
    } else {
        dict[key] = [name]
    }
}
print(dict)
```
### Better
``` swift
dict = [:]
for name in names {
    let key = name.count
    if dict[key] == nil {
        dict[key] = []
    }
    dict[key] = dict[key]! + [name] // can't be null so force is OK.
}
print(dict)
```
### Even Better
``` swift
dict = [:]
for name in names {
    dict[name.count, default: []] += [name]
}
print(dict)
```
### Or Even
``` swift
let myDictionary = names.reduce([Int: [String]]()) { (dict, name) -> [Int: [String]] in
    var dict = dict
    dict[name.count, default: []] += [name]
    return dict
}
print(myDictionary)
```
### Or perhaps
``` swift
let dictx = names.reduce([Int: [String]]()) {
    var dict = $0
    dict[$1.count, default: []] += [$1]
    return dict
}
print(dictx)
```
### Best
``` swift
let dicty = names.reduce(into: [Int: [String]]()) {
    dict[$1.count, default: []] += [$1]
}
print(dicty)
```
## Is a dictionary popFirst() atomic?
``` swift
d = ["matthew": "blue", "rachel": "green", "raymond": "red"]

for _ in d {
    if let (key, value) = d.popFirst() {
        print("\(key) --> \(value)")
    }
}
print(d)
```
`popFirst` is atomic so you don't have to put locks around it to use it in threads.

## Improving Clarity
* Positional arguments and indicies are nice
* Keywords and names are better
* The first way is convenient for the computer
* The second corresponds to how human’s think

## Clarify function calls with keyword arguments, unless it makes it clearer to leave it off
Defeating Swift's parameter names is actually more work and less understandable.
``` swift
func twitterSearch(_ name: String, _ retweets: Bool, _ numTweets: Int, _ popular: Bool) {
}
twitterSearch("@possen", false, 20, true)
```
### Better
``` swift
func twitterSearch2(name: String, retweets: Bool, numTweets: Int, popular: Bool) {
}
twitterSearch2(name: "@possen", retweets: false, numTweets: 20, popular: true)
```
it is worth it for the code clarity and developer time savings. please see Apple's naming conventions for when it is approprate to drop param name. Usually when it is the direct object in the first parameter. Also, keep in mind Swift's parameters do not add the type in the paramter like Objective-C conventions.

### Don't do this (Objective-C style)
``` swift
func createTweetFromString(title: String, userNameString: String) {
}
```
### Or this
``` swift
func createTweetFromString(_ title: String, userNameString: String) {
}
```

### Do this
``` swift
func createTweet(title: String, userName: String) {
}
```

## Clarify multiple return values with named tuples
``` swift
func runTests() -> (Int, Int) {
    return (0, 4)
}
print(runTests())
```
You don't know because what the return values are not clear.
### Better
``` swift
func runTests2() -> (failed: Int, attempted: Int) {
    return (failed:0, attempted: 4)
}
print(runTests2())
```
They still work like a regular tuple, but are more friendly.
## Unpacking sequences
Python used a heterogenous array here for unpacking, but that is not supported in Swift but tuple is, by not allowing mixing of types Swift can be more efficient.

``` swift
let p = ("Raymond", "Hettinger", 30, "swift@example.com")
```
### A common approach / habit from other languages
``` swift
let fname = p.0
let lname = p.1
let age = p.2
let email = p.3
```
### Better
``` swift
let (fname2, lname2, age2, email2) = p
```
## Updating multiple state variables
``` swift
func fibonacci(n: Int) {
    var x = 0
    var y = 1
    for _ in 0..<n {
        print(x, terminator: " ")
        let t = y
        y = x + y
        x = t
    }
}
fibonacci(n:10)
print()
```
### Better
``` swift
func fibonacci2(n: Int) {
    var (x, y) = (0, 1)
    for _ in 0..<n {
        print(x, terminator: " ")
        (x, y) = (y, x + y)
    }
}
fibonacci2(n: 10)
print()
```
## Efficiency
* An optimization fundamental rule
* Don’t cause data to move around unnecessarily
* It takes only a little care to avoid O(n**2) behavior instead of linear behavior

> Basically, just don't move data around unecessarily.

## Concatenating strings
``` swift
names = ["raymond", "rachel", "matthew", "roger", "betty", "melissa", "judith", "charlie"]
var s = names[0]
for name in names[1...] {
    s += "..." + name
}
print(s)
```
### Better
``` swift
print(names.joined(separator: "..."))
```
## Updating sequences
``` swift
names = ["raymond", "rachel", "matthew", "roger", "betty", "melissa", "judith", "charlie"]
names.remove(at: 0)
print(names)
```
The below are signs you're using the wrong data structure in Python, but in Swift insertions at either end are efficient and you don't need deque data structure.
``` swift
names.removeFirst()
names.insert("mark", at: 0)
```
## How to open and close files without leaving file descriptors open.
``` swift
func writeFile() {
    let fd = open("/tmp/scratch.txt", O_WRONLY|O_CREAT, 0o666)
    if fd < 0 {
        perror("could not open /tmp/scratch.txt")
    } else {
        let text = "Hello World"
        write(fd, text, text.characters.count)
        close(fd)
    }
}
```
### Better
``` swift
func writeFile2() {
    let fd = open("/tmp/scratch.txt", O_WRONLY|O_CREAT, 0o666)
    defer {
        close(fd) // don't leave file descriptor open
    }
    if fd < 0 {
        perror("could not open /tmp/scratch.txt")
    } else {
        let text = "Hello World"
        write(fd, text, text.characters.count)
    }
}
```
Although, you should use higher level functions in most cases. For example, you can read a smallish file into a string using contentsOf
``` swift
let url = URL(fileURLWithPath: "/tmp/test.txt")
let va = try? String(contentsOf: url)
print(va ?? "could not load text")
```

## Concise Expressive One-Liners
Two conflicting rules:

* Don’t put too much on one line
* Don’t break atoms of thought into subatomic particles

Raymond’s rule:

* One logical line of code equals one sentence in English

## List Comprehensions and Generator Expressions
``` swift
var result: [Int] = []
for i in 0..<10 {
    let s = i * i
    result.append(s)
}
var sum = 0
for num in result {
    sum += num
}
print(sum)
```
### Better
``` swift
let result2 = (0..<10).map { $0 * $0 }.reduce(0, +)
print(result2)
```
First way tells you what to do, second way tells you what you want.

