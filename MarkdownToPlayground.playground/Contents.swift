//: ## A handy utilty that converts a markdown file into a playground markdown file and
//: the otherway around.
//: Just put the source markdown in the resources inside the playground with the name Markdown.md
//: the output is in the Debug area at the bottom of the playground.

import Foundation

// In playground add
let fileURL = Bundle.main.url(forResource: "Markdown", withExtension: "md")
let text = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

func covertToMatches(text: String) -> [String] {
    // Swift currently does not have regex built into stanard library.
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [] )
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            let results = regex.matches(in: text, range: range)
            let res:[String] = results.map {
                let range = Range($0.range, in: text)!
                return String(text[range])
            }
            return  res
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    return matches(for: ".*", in: text)
}

func converMatchesToPlayground(lines: [String]) -> String {
    var result = ["/*:"]
    for line in lines {
        if line.hasPrefix("``` swift") {
            result += ["*/"]
        } else if line.hasPrefix("```") {
            result += ["/*:"]
        } else if line.isEmpty {
            // don't do anything
        } else {
            result += [line]
        }
    }
    result += ["*/"]
    return result.joined(separator: "\n")
}


func converMatchesToMarkdown(lines: [String]) -> String {
    func replace(prefix: String, line: String) -> String {
        return String(line[prefix.endIndex...]) // very unsatisfactory Subsequence conversion here, this is better than the deprcated substring?
    }
    var result: [String] = []
    for line in lines {
        if line.hasPrefix("/*:") {
            result += [replace(prefix: "/*:", line: line)]
            result += ["```"]
        } else if line.hasPrefix("//:", line: line) {
            result += [replace(prefix: "//:")]
        } else if line.hasPrefix("*/", line: line) {
            result += [replace(prefix: "*/")]
            result += ["``` swift"]
        } else if line.isEmpty {
            // don't do anything
        } else {
            result += [line]
        }
    }
    result = [String](result.dropFirst().dropLast())
    return result.joined(separator: "\n")
}

let lines = covertToMatches(text: text)
let result = converMatchesToPlayground(lines: lines)
print(result)

let lineso = covertToMatches(text: result)
let original = converMatchesToMarkdown(lines: lineso)
print(original)






