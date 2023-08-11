import Foundation

enum Items: String, CaseIterable {
    case add_track = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

enum Events: String, CaseIterable {
    case open = "open"
    case close = "close"
    case click = "click"
}

enum Constants: String {
    case apiKey = "6afd36d2-5535-4758-9b72-7e2cd23df2b7"
}
