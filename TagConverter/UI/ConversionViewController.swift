//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class ConversionViewController: NSViewController {

    var conversionHandler: ((Conversion) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        insertMissingHashtagsOnly = true

        appendHashtagsRadioButton.state = .on
        hashtagPlacement = .append
        updateLinePlacementControls()
        disableControlsWithoutData()
    }


    // MARK: Conversion

    /// Local cache of displayed notes
    private var notes: [Note] = []

    func display(notes: [Note]) {
        self.notes = notes

        disableControlsWithoutData()
    }

    private func disableControlsWithoutData() {

        let isEnabled = notes.isNotEmpty

        insertMissingHashtagsCheckbox.isEnabled = isEnabled
        appendHashtagsRadioButton.isEnabled = isEnabled
        insertAtLineRadioButton.isEnabled = isEnabled
        lineStepper.isEnabled = isEnabled
        lineTextField.isEnabled = isEnabled
        convertButton.isEnabled = isEnabled
        updateLinePlacementControls()
    }

    @IBOutlet weak var convertButton: NSButton!

    @IBAction func convert(_ sender: Any) {

        guard confirmed() else { return }

        let conversion = Conversion(
            notes: notes,
            insertMissingHashtagsOnly: insertMissingHashtagsOnly,
            hashtagPlacement: hashtagPlacement)
        conversionHandler?(conversion)
    }

    private func confirmed() -> Bool {

        let confirmationAlert = NSAlert()
        confirmationAlert.alertStyle = .warning
        confirmationAlert.messageText = "Overwrite files?"
        confirmationAlert.informativeText = "The conversion will write directly to your original files. Make a backup!"
        confirmationAlert.addButton(withTitle: "Overwrite My Files")
        confirmationAlert.addButton(withTitle: "Cancel")

        let response = confirmationAlert.runModal()
        
        return response == .alertFirstButtonReturn
    }


    // MARK: Insert Missing Hashtags Only

    @IBOutlet weak var insertMissingHashtagsCheckbox: NSButton!

    var insertMissingHashtagsOnly = true

    @IBAction func changeInsertMissingHashtagsOnly(_ sender: Any) {
        guard let button = sender as? NSButton else { return }
        insertMissingHashtagsOnly = (button.state == .on)
    }


    // MARK: Hashtag placement

    @IBOutlet weak var appendHashtagsRadioButton: NSButton!
    @IBOutlet weak var insertAtLineRadioButton: NSButton!

    var hashtagPlacement: HashtagPlacement = .append

    @IBOutlet weak var lineTextField: NSTextField!
    @IBOutlet weak var lineStepper: NSStepper!

    @objc dynamic var lineNumber: Int = 1 {
        didSet {
            hashtagPlacement = .atLine(lineNumber)
        }
    }

    @IBAction func changeHashtagPlacement(_ sender: Any) {
        self.hashtagPlacement = {
            if insertAtLineRadioButton.state == .on {
                return .atLine(lineNumber)
            } else {
                return .append
            }
        }()

        updateLinePlacementControls()
    }

    private func updateLinePlacementControls() {

        let isPlacingAtLine: Bool = {
            if case .atLine = hashtagPlacement { return true }
            return false
        }()

        lineTextField.isEnabled = isPlacingAtLine
        lineStepper.isEnabled = isPlacingAtLine
    }
}
