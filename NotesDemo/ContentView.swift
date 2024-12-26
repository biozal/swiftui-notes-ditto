//
//  ContentView.swift
//  NotesDemo
//
//  Created by Aaron LaBeau on 12/26/24.
//

import SwiftUI
import DittoSwift
import Combine

@MainActor class NotesViewModel: ObservableObject {
    
    @Published var notes: [Note] = []
    
    //handle information from Ditto
    private let dittoService = DittoService.shared
    private var notesDocsCancellable = AnyCancellable({})
    private var cancellables = Set<AnyCancellable>()
    
    //UI State
    @Published var showingNewNoteSheet = false
    @Published var newNoteTitle = ""
    @Published var newNoteContent = ""
    
    init () {
        dittoService.$allNotes
            .sink {[weak self] notes in
                guard let self = self else { return }
                self.notes = notes
        }
        .store(in: &cancellables)
    }
    
    func clearState() {
        showingNewNoteSheet = false
        newNoteTitle = ""
        newNoteContent = ""
    }
    
    func addNote() {
        if (!newNoteTitle.isEmpty) {
            let note = Note(
                id: UUID().uuidString,
                title: newNoteTitle,
                content: newNoteContent,
                date: Date()
            )
            DittoService.shared.addNote(note)
            clearState()
        }
    }
    
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingNewNoteSheet = false
    @State private var newNoteTitle = ""
    @State private var newNoteContent = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.notes) { note in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.date, style: .date)
                            .font(.caption)
                        Text(note.content)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: viewModel.deleteNote)
            }
            .navigationTitle("Notes")
            .toolbar {
                Button(action: {
                    viewModel.showingNewNoteSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewNoteSheet) {
                NavigationView {
                    Form {
                        TextField("Title", text: $viewModel.newNoteTitle)
                        TextEditor(text: $viewModel.newNoteContent)
                            .frame(height: 200)
                    }
                    .navigationTitle("New Note")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            viewModel.clearState()
                        },
                        trailing: Button("Save") {
                            viewModel.addNote()
                        }
                            .disabled(viewModel.newNoteTitle.isEmpty)
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
