//
//  Note.swift
//  NotesDemo
//
//  Created by Aaron LaBeau on 12/26/24.
//

import Foundation
import DittoSwift

typealias DittoQuery = (string: String, args: [String: Any?])

protocol DittoDecodable {
    init(value: [String: Any?])
    static var collectionName: String { get }
}

struct Note: Identifiable, Hashable, Equatable {
    let id: String
    var title: String
    var content: String
    var date: Date
    
    init(id: String, title: String, content: String, date: Date) {
       self.id = id
       self.title = title
       self.content = content
       self.date = date
    }
}

// MARK: - Date to String
extension Note {
    var dateString: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}

// MARK: -  DittoDecodable
extension Note: DittoDecodable {
    
    var _id: String { id } // For DittoDecodable
    static let collectionName = "notes"
    
    init(value: [String: Any?]) {
        let dateIsoString = value["date"] as! String
        let dateFormatter = ISO8601DateFormatter()
        
        self = Note(
            id: value["_id"] as! String,
            title: value["title"] as! String,
            content: value["content"] as! String,
            date: dateFormatter.date(from: dateIsoString) ?? Date()
        )
    }
}

// MARK: - Ditto Query Language (DQL) Support
extension Note {
    
    var insertNewQuery: DittoQuery {
        (
            string: """
                INSERT INTO COLLECTION \(Self.collectionName)
                DOCUMENTS (:new)
                ON ID CONFLICT DO UPDATE
            """,
            args: [
                "new": [
                    "_id": self.id,
                    "title": self.title,
                    "content": self.content,
                    "date": self.dateString
                ]
            ]
        )
    }
    
    var deleteQuery: DittoQuery {
        (
            string: """
                EVICT FROM \(Self.collectionName)
                WHERE _id = \(self.id)
            """,
            args: [:]
        )
    }
    
    static var selectAllQuery: DittoQuery {
        (
            string: """
                SELECT * FROM COLLECTION \(Self.collectionName)
            """,
            args: [:]
        )
    }
}
