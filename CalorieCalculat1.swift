 // contentview
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var profiles: [UserProfile]

    // 入力欄
    @State private var inP: String = ""
    @State private var inF: String = ""
    @State private var inC: String = ""

    // 合計（永続化：アプリ終了・翌日でも保持）
    @AppStorage("totalP") private var totalP: Double = 0
    @AppStorage("totalF") private var totalF: Double = 0
    @AppStorage("totalC") private var totalC: Double = 0

    // 直前の入力（1回だけ取り消し用）※これはセッション内だけでOK
    @State private var lastP: Double = 0
    @State private var lastF: Double = 0
    @State private var lastC: Double = 0

    // UI
    @State private var showSettings = false
    @FocusState private var isInputActive: Bool
    @State private var showResetConfirm = false

    private var profile: UserProfile { profiles.first ?? UserProfile() }
    private var totalKcal: Int { Int(totalP*4 + totalF*9 + totalC*4) }

    private var canAdd: Bool {
        (Double(inP) ?? 0) > 0 || (Double(inF) ?? 0) > 0 || (Double(inC) ?? 0) > 0
    }
    private var canUndo: Bool { lastP != 0 || lastF != 0 || lastC != 0 }
    private var hasAnyTotal: Bool { totalP > 0 || totalF > 0 || totalC > 0 }

    var body: some View {
        NavigationStack {
            Form {
                // 入力
                Section("入力") {
                    Row(symbol: "P", input: $inP, total: totalP,
                        goal: Double(profile.targetPgram), unit: "g",
                        focus: $isInputActive)

                    Row(symbol: "F", input: $inF, total: totalF,
                        goal: Double(profile.targetFgram), unit: "g",
                        focus: $isInputActive)

                    Row(symbol: "C", input: $inC, total: totalC,
                        goal: Double(profile.targetCgram), unit: "g",
                        focus: $isInputActive)

                    HStack {
                        Text("カロリー")
                        Spacer()
                        Text("\(totalKcal) / \(profile.targetKcal) kcal")
                            .font(.headline)
                    }

                    Button("追加") {
                        let p = max(0, Double(inP) ?? 0)
                        let f = max(0, Double(inF) ?? 0)
                        let c = max(0, Double(inC) ?? 0)
                        guard p + f + c > 0 else { return }

                        // 直前値（1回分）を記録
                        lastP = p; lastF = f; lastC = c

                        // 合計に反映（@AppStorage なので自動保存）
                        totalP += p; totalF += f; totalC += c

                        // 入力欄クリア & キーボード閉じる
                        inP = ""; inF = ""; inC = ""
                        isInputActive = false

                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canAdd)

                    // 直前の入力を取り消す（1回分だけ）
                    Button("直前の入力を取り消す") {
                        totalP = max(0, totalP - lastP)
                        totalF = max(0, totalF - lastF)
                        totalC = max(0, totalC - lastC)
                        lastP = 0; lastF = 0; lastC = 0
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canUndo)
                }

                // リセット
                Section {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Text("今日をリセット（合計を0にする）")
                    }
                    .disabled(!hasAnyTotal)
                }
            }
            .navigationTitle("カロリー管理")
            .toolbar {
                // 右上：設定
                ToolbarItem(placement: .topBarTrailing) {
                    Button("設定") {
                        ensureProfile()
                        showSettings = true
                        isInputActive = false
                    }
                }
                // キーボード上：閉じる
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("閉じる") { isInputActive = false }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(profile: profile)
            }
            .onAppear { ensureProfile() }
            .alert("合計をリセットしますか？", isPresented: $showResetConfirm) {
                Button("キャンセル", role: .cancel) { }
                Button("リセット", role: .destructive) {
                    totalP = 0; totalF = 0; totalC = 0
                    lastP = 0; lastF = 0; lastC = 0
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            } message: {
                Text("P/F/C の合計を 0 に戻します。元に戻すことはできません。")
            }
        }
    }

    private func ensureProfile() {
        if profiles.isEmpty {
            ctx.insert(UserProfile())
            try? ctx.save()
        }
    }
}

// 入力行
private struct Row: View {
    let symbol: String
    @Binding var input: String
    let total: Double
    let goal: Double
    let unit: String
    var focus: FocusState<Bool>.Binding

    var body: some View {
        HStack {
            Text(symbol)
            TextField("0", text: $input)
                .keyboardType(.decimalPad)
                .focused(focus)
                .frame(width: 70)
                .textFieldStyle(.roundedBorder)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(total)) / \(Int(goal)) \(unit)")
                    .font(.headline)
                ProgressView(value: min( max(total / max(goal, 1), 0), 1))
                    .frame(width: 120)
            }
        }
    }
}
