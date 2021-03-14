//
//  DetailViewController.swift
//  MyNotes
//
//  Created by Sergey Golovin on 13.03.2021.
//  Copyright © 2021 GoldenWindGames LLC. All rights reserved.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController {
    
    var note = Note()
    var isEditMode = false
    
    let realm = try! Realm()

    let unwindSegueIdentifier = "unwindToNotes"
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var noteImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        setDismissKeyboardGesture()
    }
    
    @IBAction func editTextPressed(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Edit text", message: "", preferredStyle: .actionSheet)
        
        let largeFontAction = UIAlertAction(title: TextStyle.largeFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.boldSystemFont(ofSize: 30)]
            self?.editTextStyle(with: attributes)
            self?.saveNoteTextStyle(note: self?.note, textStyle: TextStyle.largeFont.rawValue)
        }
        
        let greenFontAction = UIAlertAction(title: TextStyle.greenFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.green, .font: UIFont.systemFont(ofSize: 25)]
            self?.editTextStyle(with: attributes)
            self?.saveNoteTextStyle(note: self?.note, textStyle: TextStyle.greenFont.rawValue)
        }
        
        let italicFontAction = UIAlertAction(title: TextStyle.italicFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.italicSystemFont(ofSize: 20)]
            self?.editTextStyle(with: attributes)
            self?.saveNoteTextStyle(note: self?.note, textStyle: TextStyle.italicFont.rawValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(largeFontAction)
        ac.addAction(greenFontAction)
        ac.addAction(italicFontAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImagePressed(_ sender: UIButton) {
        setImagePickerController()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        performSegue(withIdentifier: unwindSegueIdentifier, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == unwindSegueIdentifier else { return }
        
        let title = titleTextField.text ?? ""
        let body = noteTextView.text ?? ""
        let image = noteImageView.image
        let style = note.textStyle
        
        note = Note()
        note.title = title
        note.body = body
        note.image = image?.pngData()
        note.textStyle = style
    
    }
    
    // MARK: - Dismiss keyboard
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Update UI
    
    private func updateUI() {
        titleTextField.text = note.title
        noteTextView.text = note.body
        if let data = note.image {
            noteImageView.image = UIImage(data: data)
        }
        switch note.textStyle {
        case TextStyle.largeFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.boldSystemFont(ofSize: 30)]
            noteTextView.attributedText = NSAttributedString(string: note.body, attributes: attributes)
        case TextStyle.greenFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.green, .font: UIFont.systemFont(ofSize: 25)]
            noteTextView.attributedText = NSAttributedString(string: note.body, attributes: attributes)
        case TextStyle.italicFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.italicSystemFont(ofSize: 20)]
            noteTextView.attributedText = NSAttributedString(string: note.body, attributes: attributes)
        default:
            return
        }
    }
    
    // MARK: - Edit text style 
    
    private func editTextStyle(with attributes: [NSAttributedString.Key : Any]) {
        guard let  stringToEdit = noteTextView.text else { return }
        noteTextView.attributedText = NSAttributedString(string: stringToEdit, attributes: attributes)
    }
    
    private func saveNoteTextStyle(note: Note?, textStyle: String) {
        guard let note = note else { return }
        do {
            try realm.write {
                note.textStyle = textStyle
            }
        } catch {
            print("Saving error \(error)")
        }
    }
}

// MARK: - Image picker

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func setImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else { return }
        noteImageView.image = image
    }
}
