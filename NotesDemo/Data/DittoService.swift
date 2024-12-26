import Foundation
import Combine
import DittoSwift
import SwiftUI


@MainActor class DittoService: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var allNotes = [Note]()
    private var allNotesCancellable = AnyCancellable({})
    
    static var shared = DittoService()
    let ditto = DittoInstance.shared.ditto
    
    private let storeService: StoreService
    private let syncService: SyncService
    
    private init() {
        storeService = StoreService(ditto.store)
        
        syncService = SyncService(ditto.sync)
        syncService.registerSubscriptions()
        
        // Prevent Xcode previews from syncing: non preview simulators and real devices can sync
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            try! ditto.startSync()
        }
        
        updateNotesPublisher()
    }
    
}

// MARK: Public
extension DittoService {
   func addNote(_ note: Note) {
        storeService.insertNote(of: note)
    }
}

// MARK: - Private
extension DittoService {

    private func updateNotesPublisher() {
        guard syncService.notesSubscription != nil else { return }
        allNotesCancellable = storeService.allNotesObservePublisher()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error in notes publisher: \(error)")
                    }
                },
                receiveValue: { [weak self] notes in
                    self?.allNotes = notes
                }
            )
    }
}


