//
//  SyncService.swift
//  NotesDemo
//
//  Created by Aaron LaBeau on 12/26/24.
//

import Foundation
import DittoSwift
import Combine

final class SyncService {
    private let sync: DittoSync
    var notesSubscription: DittoSyncSubscription? = nil
    
    init(_ sync: DittoSync) {
        self.sync = sync
    }
    
    func registerSubscriptions() {
        do {
            try notesSubscription = sync.registerSubscription(
                query: Note.selectAllQuery.string,
                arguments: Note.selectAllQuery.args
            )
        } catch {
            assertionFailure("ERROR with \(#function)" + error.localizedDescription)
        }
    }
   
    func cancelSubscription() {
        notesSubscription?.cancel()
        notesSubscription = nil
    }
}
