//
//  NoteModal.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 4/4/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit

class NoteModal: UIViewController {
    @IBOutlet weak var text: UITextView!
    
    
    var changeNote: ((_ text:String)->Void)?
    
    
    var note:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        text.text = note
    }

    @IBAction func done(_ sender: Any) {
        changeNote!(text.text)
        self.dismiss(animated: true, completion: nil)
    }
}
