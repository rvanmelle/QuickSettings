// https://github.com/danger/danger-swift

import Foundation
import Danger
import DangerSwiftCompileTimes // package: https://github.com/instacart/danger-swift-compiletimes.git
let danger = Danger()

let allSourceFiles = danger.git.modifiedFiles + danger.git.createdFiles

let changelogChanged = allSourceFiles.contains("CHANGELOG.md")
let sourceChanges = allSourceFiles.first(where: { $0.hasPrefix("Sources") })
let testChanges = allSourceFiles.first(where: { $0.hasPrefix("Tests") })
let prTitle = danger.github.pullRequest.title
let isTrivial = prTitle.contains("#trivial")
let filesChangedCount = danger.git.createdFiles.count + danger.git.modifiedFiles.count - danger.git.deletedFiles.count

var foundIssues = false

if !isTrivial && !changelogChanged && sourceChanges != nil {
    warn("No CHANGELOG entry added, please consider adding a note about this change.")
    foundIssues = true
}

if sourceChanges != nil && testChanges == nil {
    message("There were no tests added/modified to this change.")
    foundIssues = true
}

if filesChangedCount > 10 {
    warn("Big PR, try to keep changes smaller if you can.")
    foundIssues = true
}

if prTitle.contains("WIP") {
    warn("PR is classed as Work in Progress.")
    foundIssues = true
}

SwiftCompileTimes.analyze(userHome: "/Users/distiller", targetName: "QuickSettings", configFile: ".swift-compiletimes.yml")

if !foundIssues {
    message("No rules were triggered! 🎉")
}

// Suggested rules to add:
// - Look for print or NSLog statements in code
