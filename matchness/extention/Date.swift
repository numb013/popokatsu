
import Foundation

extension Date {
    func toFuzzy() -> String {

        // 現在時刻を取得する
        let now = Date()

        // カレンダーを作成する
        let cal = Calendar.current

        // MARK: メソッド名と引数の指定方法が変わっているので変更
        //let calUnit: Calendar.Unit = .CalendarUnitSecond | .CalendarUnitMinute | .CalendarUnitHour | .CalendarUnitDay | .CalendarUnitYear
        //let components = cal.components(calUnit, fromDate: self, toDate: now, options: nil)
        let components = cal.dateComponents([.second, .minute, .hour, .day, .year], from: self, to: now)

        // MARK: 各プロパティはオプショナル型として宣言されているため、強制アンラップを行なっている
        // 目的などに応じて適切に書き換える必要がある
        let diffSec = components.second! + components.minute! * 60 + components.hour! * 3600 + components.day! * 86400 + components.year! * 31536000

        var result = String()

        if diffSec < 60 {
            result = "\(diffSec)秒前"
        } else if diffSec < 3600 {
            result = "\(diffSec/60)分前"
        } else if diffSec < 86400 {
            result = "\(diffSec/3600)時間前"
        } else if diffSec < 2764800 {
            result = "\(diffSec/86400)日前"
        } else if diffSec > 2764800 {
            result = "\(diffSec/2764800)ヶ月前"
        } else {
            let dateFormatter = DateFormatter()

            // MARK: year はオプショナル型のため強制アンラップを行なっている
            if components.year! > 0 {
                dateFormatter.dateFormat = "yyyy年M月d日"
                result = dateFormatter.string(from: self)
            } else {
                dateFormatter.dateFormat = "M月d日"
                result = dateFormatter.string(from: self)
            }
        }

        return result
    }

    static func parse(dateString:String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"
        let d = formatter.date(from: dateString)
        return Date(timeInterval: 0, since: d!)
    }
}
