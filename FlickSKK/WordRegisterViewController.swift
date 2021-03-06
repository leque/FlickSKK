//
//  SettingsViewController.swift
//  FlickSKK
//
//  Created by MIZUNO Hiroki on 12/18/14.
//  Copyright (c) 2014 BAN Jun. All rights reserved.
//

import UIKit
class WordRegisterViewController : SafeTableViewController, UITextFieldDelegate {
    private let yomiField = UITextField(frame: CGRectZero)
    private let okuriField = UITextField(frame: CGRectZero)
    private let wordField = UITextField(frame: CGRectZero)
    private lazy var doneButton : UIBarButtonItem =
        UIBarButtonItem(title: NSLocalizedString("Register", comment:""),
            style: .Done, target:self, action: Selector("register"))
    var done : ((String, String?, String) -> Void)?

    private lazy var sections : [(
        title: String?,
        rows: [(title: String, text: UITextField, returnType: UIReturnKeyType)]
    )] = [
        (title: nil, rows: [
            (title: NSLocalizedString("word", comment: ""), text: self.wordField, returnType: .Next),
            (title: NSLocalizedString("yomi", comment: ""), text: self.yomiField, returnType: .Next),
            (title: NSLocalizedString("okuri", comment: ""), text: self.okuriField, returnType: .Default),
    ])]

    init() {
        super.init(style: .Grouped)
        self.doneButton.enabled = false
        self.navigationItem.rightBarButtonItem = doneButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func register() {
        if canRegister() {
            var okuri : String? = nil

            if let text = self.okuriField.text where !text.isEmpty {
                // 1文字目
                let first = Array(text.characters)[0]
                // ローマ字変換
                if let roman = first.toRoman() {
                    // 1文字目を取得
                    okuri = String(Array(roman.characters)[0])
                } else {
                    okuri = String(first)
                }
            }
            self.done?(
                self.wordField.text ?? "",
                okuri,
                self.yomiField.text ?? "")
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    let kCellID = "Cell"

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID) ?? UITableViewCell(style: .Default, reuseIdentifier: kCellID)

        let row = sections[indexPath.section].rows[indexPath.row]
        cell.accessoryType = .None
        cell.selectionStyle = .None

        // label
        let label = UILabel(frame: CGRectMake(20, 5, 130, 45))
        label.text = row.title
        label.font = Appearance.normalFont(17.0)
        cell.contentView.addSubview(label)

        // text field
        let textField = row.text
        textField.frame = CGRectMake(130, 0, view.frame.width-130, 50)
        textField.font = Appearance.normalFont(17.0)
        textField.clearButtonMode = .WhileEditing
        textField.placeholder = row.title
        textField.contentVerticalAlignment = .Center
        textField.returnKeyType = row.returnType
        textField.delegate = self
        textField.addTarget(self, action: "didChange", forControlEvents: .EditingChanged)
        cell.contentView.addSubview(textField)

        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        for section in self.sections {
            for (index,row) in section.rows.enumerate() {
                if textField == row.text {
                    switch row.returnType {
                    case .Next:
                        section.rows[index+1].text.becomeFirstResponder()
                    case .Default:
                        register()
                    default:
                        // do nothing
                        break
                    }
                }
            }
        }
        return true
    }

    @objc private func didChange() {
        self.doneButton.enabled = canRegister()
    }

    private func canRegister() -> Bool {
        // 登録できる条件
        // ・登録する単語が入力されている
        // ・よみが入力されている。SKK的に読みはほぼ任意(例: forallとかもある)なので、あまり前提をおけない。
        // ・送り仮名が空もしくはひらがな一文字(ローマ字に変換できる)
        let wordInputed : Bool = self.wordField.text != nil
        let yomiInputed : Bool = yomiField.text != nil

        let okuriBlank : Bool = self.okuriField.text?.isEmpty ?? true
        let okuri = self.okuriField.text?.characters
        let okuriInputed = okuri?.count == 1 && (okuri?.first?.toRoman() != nil)

        return wordInputed && yomiInputed && (okuriBlank || okuriInputed)
    }
}
