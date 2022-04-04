//
//  DetePickerViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/11/10.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit


protocol detePickerProtocol: class {
    func detePickerSelect(date: String)
}

class DetePickerViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var datePickerView: UIDatePicker!
    weak var delegate: detePickerProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let minDateString = "1900-01-01"
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        var minDate = dateFormater.date(from: minDateString)
        let day = Date()
        let maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: day)!

        datePickerView.minimumDate = minDate
        datePickerView.maximumDate = maximumDate
        
        datePickerView.datePickerMode = .date
        datePickerView.locale = Locale(identifier: "ja")
        datePickerView.backgroundColor = UIColor.white
        
    }

    @IBAction func detePickerTap(_ sender: Any) {
        // 西暦は必要無いので、dateFormatを月日の取得だけにする。
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy-MM-dd"
        // DatePickerから取得したDateをDateFormatterでString型に変換する
        let birthdayString = dateFormater.string(from: (sender as AnyObject).date)
        delegate?.detePickerSelect(date: birthdayString)
    }
    
}
