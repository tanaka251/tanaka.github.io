//settingview
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @Bindable var profile: UserProfile

    // 入力一時値
    @State private var tmpKcal: String = ""
    @State private var tmpP: String = ""
    @State private var tmpF: String = ""

    // キーボード表示制御
    @FocusState private var isInputActive: Bool

    private var tmpC: Double {
        let p = Double(tmpP) ?? profile.pctProtein
        let f = Double(tmpF) ?? profile.pctFat
        return max(0, 100 - (p + f))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("目標設定") {
                    HStack {
                        Text("目標カロリー")
                        TextField("0", text: $tmpKcal)
                            .keyboardType(.numberPad)
                            .focused($isInputActive)     // ← フォーカス紐づけ
                            .frame(width: 90)
                        Text("kcal")
                    }
                    HStack {
                        Text("P比率")
                        TextField("0", text: $tmpP)
                            .keyboardType(.numberPad)
                            .focused($isInputActive)     // ← フォーカス紐づけ
                            .frame(width: 60)
                        Text("%")
                    }
                    HStack {
                        Text("F比率")
                        TextField("0", text: $tmpF)
                            .keyboardType(.numberPad)
                            .focused($isInputActive)     // ← フォーカス紐づけ
                            .frame(width: 60)
                        Text("%")
                    }
                    HStack {
                        Text("C比率")
                        Spacer()
                        Text("\(Int(tmpC)) %（自動）")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("計算結果") {
                    let kcal = Int(tmpKcal) ?? profile.targetKcal
                    let pGram = Int(Double(kcal) * ((Double(tmpP) ?? profile.pctProtein)/100) / 4)
                    let fGram = Int(Double(kcal) * ((Double(tmpF) ?? profile.pctFat)/100) / 9)
                    let cGram = Int(Double(kcal) * (tmpC/100) / 4)
                    Text("P \(pGram) g")
                    Text("F \(fGram) g")
                    Text("C \(cGram) g")
                }
            }
            .navigationTitle("設定")
            .toolbar {
                // 画面下：保存／戻る
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("保存") {
                            isInputActive = false    // ← まず閉じる
                            profile.targetKcal = Int(tmpKcal) ?? profile.targetKcal
                            profile.pctProtein = Double(tmpP) ?? profile.pctProtein
                            profile.pctFat = Double(tmpF) ?? profile.pctFat
                            try? ctx.save()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)

                        Spacer()

                        Button("戻る") {
                            isInputActive = false    // ← 閉じてから戻る
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                }

                // キーボード上：閉じるボタン
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("閉じる") {
                        isInputActive = false
                    }
                }
            }
            .onAppear {
                tmpKcal = "\(profile.targetKcal)"
                tmpP = "\(Int(profile.pctProtein))"
                tmpF = "\(Int(profile.pctFat))"
            }
        }
    }
}
