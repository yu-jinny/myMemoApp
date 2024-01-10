// TableViewCell.swift

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func switchChanged(for cell: TableViewCell)
}

class TableViewCell: UITableViewCell {
    static let identifier = "cell"

    weak var delegate: TableViewCellDelegate?
    
    func configure(with todoItem: TodoItem) {
        textLabel?.text = todoItem.text

        let switchView = UISwitch()
        switchView.isOn = todoItem.isCompleted
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)

        switchView.tag = tag
        accessoryView = switchView

        updateTextStrikeThrough(isCompleted: todoItem.isCompleted)
    }

    @objc func switchChanged(_ sender: UISwitch) {
        delegate?.switchChanged(for: self)
    }

    func updateTextStrikeThrough(isCompleted: Bool) {
        if isCompleted {
            let attributeString = NSAttributedString(string: textLabel?.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            textLabel?.attributedText = attributeString
        } else {
            let attributeString = NSAttributedString(string: textLabel?.text ?? "")
            textLabel?.attributedText = attributeString
        }
    }
}
