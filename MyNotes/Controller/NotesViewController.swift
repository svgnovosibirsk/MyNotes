//
//  NotesViewController.swift
//  MyNotes
//
//  Created by Sergey Golovin on 09.03.2021.
//  Copyright © 2021 GoldenWindGames LLC. All rights reserved.
//

import UIKit
import RealmSwift

class NotesViewController: UITableViewController {
    
    var notes: Results<Note>?
    var selectedIndexPath: IndexPath?
    
    let realm = try! Realm()
    
    let cellIdetifier = "noteCell"
    let segueIdentifier = "toDetail"
    let unwindSegueIdentifier = "unwindToNotes"
    let editSegueIdentifier = "editNote"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appendObligatoryNote()
        setEditButton()
        loadNotes()
    }
    
    // MARK: -Add new note
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    // MARK: -Segue methods
    
    @IBAction func unwindSegueToNotesVC(segue: UIStoryboardSegue) {
        guard segue.identifier == unwindSegueIdentifier else {return }
        guard let sourceVC = segue.source as? DetailViewController else { return }
        let note = sourceVC.note
        let isEditMode = sourceVC.isEditMode
        
        if isEditMode {
            guard let indexPath = selectedIndexPath else { return }
            if let item = notes?[indexPath.row] {
                do {
                    try realm.write {
                        item.title = note.title
                        item.body = note.body
                        item.image = note.image
                        item.textStyle = note.textStyle
                    }
                } catch {
                    print("Saving error \(error)")
                }
            }
            tableView.reloadData()
        } else {
            save(note: note)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == editSegueIdentifier else { return }
        if let indexPath = tableView.indexPathForSelectedRow {
            selectedIndexPath = indexPath
            let note = notes?[indexPath.row] ?? Note()
            let navigationVC = segue.destination as? UINavigationController
            let detailVC = navigationVC?.topViewController as? DetailViewController
            detailVC?.note = note
            detailVC?.isEditMode = true
            detailVC?.title = "Edit mode"
        }

    }
    
    private func appendObligatoryNote() {
        notes = realm.objects(Note.self)
        if notes?.count == 0 {
            let note = Note()
            note.title = "Obligatory note"
            note.body = "In accordance with test task requirements"
            note.image = nil
            note.textStyle = ""
            save(note: note)
        } else {
            return
        }
    }
    
    private func setEditButton() {
        navigationItem.leftBarButtonItem = self.editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    private func save(note: Note) {
        do {
            try realm.write {
                realm.add(note)
            }
        } catch {
            print("Note saving error \(error)")
        }
        
        tableView.reloadData()
    }
    
    private func loadNotes() {
        notes = realm.objects(Note.self)
        tableView.reloadData()
    }
    
}

// MARK: - Table view data source and Table view Delegate

extension NotesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdetifier, for: indexPath)
        if let note = notes?[indexPath.row] {
            configureCell(cell: cell, note: note)
        } else {
            cell.textLabel?.text = "No notes added"
        }
        
        return cell
    }
    
    private func configureCell(cell: UITableViewCell, note: Note) {
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.body
        if let data = note.image {
            cell.imageView?.image = UIImage(data: data)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Deleting notes
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = notes?[indexPath.row] {
                do {
                    try realm.write {
                        realm.delete(item)
                    }
                } catch {
                    print("Deleting error \(error)")
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}


    
