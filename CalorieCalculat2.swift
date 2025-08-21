//userprofile
import SwiftData

@Model
final class UserProfile {
    var targetKcal: Int
    var pctProtein: Double
    var pctFat: Double
    init(targetKcal: Int = 2200, pctProtein: Double = 25, pctFat: Double = 25) {
        self.targetKcal = targetKcal
        self.pctProtein = pctProtein
        self.pctFat = pctFat
    }
    var pctCarb: Double { max(0, 100 - (pctProtein + pctFat)) }
    var targetPgram: Int { Int(Double(targetKcal) * (pctProtein/100) / 4) }
    var targetFgram: Int { Int(Double(targetKcal) * (pctFat/100) / 9) }
    var targetCgram: Int { Int(Double(targetKcal) * (pctCarb/100) / 4) }
}
