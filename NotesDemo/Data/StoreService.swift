import Foundation
import DittoSwift
import Combine
import SwiftUI

struct StoreService {
    private let store: DittoStore
    
    init(_ store: DittoStore){
        self.store = store
    }
    
    func insertNote(of note: Note) {
        let query = note.insertNewQuery
        exec(query: query)
    }
    
    func deleteNote(of note: Note) {
        let query = note.deleteQuery
        exec(query: query)
    }
    
    private func exec(query: DittoQuery, function: String = #function) {
        Task {
            do {
                try await self.store.execute(query: query.string, arguments: query.args)
            } catch {
                assertionFailure("ERROR with \(function) \(query.string) \(query.args): " + error.localizedDescription)
            }
        }
    }
     
    func allNotesObservePublisher() -> AnyPublisher<[Note], Error> {
        let subject = PassthroughSubject<[Note], Error>()
        
        do {
            try self.store.registerObserver(
                query: Note.selectAllQuery.string,
                arguments: Note.selectAllQuery.args,
                deliverOn: .main
            ) { result in
                let items = result.items.compactMap { Note(value: $0.value) }
                subject.send(items)
            }
        } catch {
            subject.send(completion: .failure(error))
        }
        
        return subject.eraseToAnyPublisher()
    }
}

