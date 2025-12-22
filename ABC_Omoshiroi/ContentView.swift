import SwiftUI
import AVFoundation

// --- 1. 数据模型 ---
struct AlphabetData {
    static let dict: [String: String] = [
        "A": "Apple", "B": "Ball", "C": "Cat", "D": "Dog", "E": "Elephant",
        "F": "Fish", "G": "Goat", "H": "Hat", "I": "Ice cream", "J": "Juice",
        "K": "Kite", "L": "Lion", "M": "Monkey", "N": "Nose", "O": "Orange",
        "P": "Pig", "Q": "Queen", "R": "Rabbit", "S": "Sun", "T": "Tiger",
        "U": "Umbrella", "V": "Van", "W": "Watch", "X": "Xylophone", "Y": "Yo-yo", "Z": "Zebra"
    ]
    
    static func getColor(for letter: String) -> Color {
        let colors: [Color] = [.orange, .blue, .green, .red, .purple, .pink, .cyan]
        let index = Int(letter.unicodeScalars.first!.value) % colors.count
        return colors[index]
    }
}

// --- 2. 游戏主视图 ---
struct ContentView: View {
    @State private var currentLevel = 1
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("游戏模式", selection: $currentLevel) {
                    Text("あいうえお (认知)").tag(1)
                    Text("クイズ (挑战)").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(red: 0.98, green: 0.96, blue: 0.92))

                if currentLevel == 1 {
                    LevelOneView()
                } else {
                    LevelTwoView()
                }
            }
            .navigationTitle("ABC、面白い！")
            .background(Color(red: 0.98, green: 0.96, blue: 0.92))
        }
    }
}

// --- 3. 第一关：3D翻转认知模式 ---
struct LevelOneView: View {
    let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }
    @State private var flippedLetter: String? = nil // 记录当前哪个字母被翻开了
    private let synthesizer = AVSpeechSynthesizer()
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(letters, id: \.self) { letter in
                    FlipCard(
                        letter: letter,
                        isFlipped: flippedLetter == letter,
                        color: AlphabetData.getColor(for: letter),
                        word: AlphabetData.dict[letter] ?? ""
                    ) {
                        handleTap(on: letter)
                    }
                }
            }
            .padding(30)
        }
    }

    func handleTap(on letter: String) {
        if flippedLetter == letter {
            flippedLetter = nil // 如果点的是同一个，就翻回来
        } else {
            flippedLetter = letter // 翻开新的，旧的由于绑定会自动闭合
            playSpeech(for: letter)
        }
    }

    func playSpeech(for letter: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let word = AlphabetData.dict[letter] ?? ""
        let phrase = (letter == "L") ? "\(letter)..... L is for Lion. Roar!" : "\(letter)..... \(letter) is for \(word)"
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.38
        synthesizer.speak(utterance)
    }
}

// --- 4. 翻转卡片组件 ---
struct FlipCard: View {
    let letter: String
    let isFlipped: Bool
    let color: Color
    let word: String
    let action: () -> Void
    
    @State private var isPressing = false // 用于手动控制缩放效果

    var body: some View {
        ZStack {
            // 正面：显示大字母
            CardContent(text: letter, subText: "", bgColor: .white, textColor: color)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 0 : 1)
            
            // 背面：显示单词
            CardContent(text: "🍎", subText: word, bgColor: color, textColor: .white)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(height: 160)
        .scaleEffect(isPressing ? 0.9 : 1.0) // 缩放效果
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                action()
            }
        }
        // 模拟点击时的缩放手感
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressing = pressing
            }
        }, perform: {})
    }
}

struct CardContent: View {
    let text: String
    let subText: String
    let bgColor: Color
    let textColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(bgColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack {
                Text(text)
                    .font(.system(size: subText.isEmpty ? 80 : 50, weight: .bold, design: .rounded))
                if !subText.isEmpty {
                    Text(subText)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.5)
                }
            }
            .foregroundColor(textColor)
            .padding(10)
        }
    }
}

// --- 5. 第二关：挑战模式 (逻辑与震动强化) ---
struct LevelTwoView: View {
    let groups = [
        ["A", "B", "C", "D", "E"], ["F", "G", "H", "I", "J"],
        ["K", "L", "M", "N", "O"], ["P", "Q", "R", "S", "T"],
        ["U", "V", "W", "X", "Y", "Z"]
    ]
    
    @State private var currentGroupIndex = 0
    @State private var hiddenIndices: Set<Int> = []
    @State private var solvedIndices: Set<Int> = []
    @State private var feedbackMessage = "缺掉的是哪个字母呢？"
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("第 \(currentGroupIndex + 1) 组挑战")
                .font(.system(.title, design: .rounded, weight: .bold))
                .padding(.top)

            HStack(spacing: 20) {
                let currentGroup = groups[currentGroupIndex]
                ForEach(0..<currentGroup.count, id: \.self) { index in
                    let letter = currentGroup[index]
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(hiddenIndices.contains(index) && !solvedIndices.contains(index) ? Color.gray.opacity(0.15) : .white)
                            .frame(width: 90, height: 120)
                            .shadow(radius: 5)
                        
                        if hiddenIndices.contains(index) {
                            if solvedIndices.contains(index) {
                                Text(letter).font(.largeTitle).bold().foregroundColor(.green)
                            } else {
                                Image(systemName: "questionmark").font(.largeTitle).foregroundColor(.gray.opacity(0.3))
                            }
                        } else {
                            Text(letter).font(.largeTitle).bold()
                        }
                    }
                }
            }

            Text(feedbackMessage)
                .font(.title3).foregroundColor(.secondary)

            let options = groups[currentGroupIndex].shuffled()
            HStack(spacing: 20) {
                ForEach(options, id: \.self) { option in
                    Button(action: { checkAnswer(option) }) {
                        Text(option)
                            .font(.title).bold()
                            .frame(width: 70, height: 70)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle()) // 避免默认样式冲突
                }
            }

            if solvedIndices.count == hiddenIndices.count {
                Button("下一组") { nextGroup() }
                    .buttonStyle(.borderedProminent).tint(.green).controlSize(.large)
            }
            Spacer()
        }
        .onAppear { setupQuiz() }
    }

    func setupQuiz() {
        solvedIndices.removeAll()
        let count = groups[currentGroupIndex].count
        var indices = Set<Int>()
        while indices.count < 2 { indices.insert(Int.random(in: 0..<count)) }
        hiddenIndices = indices
        feedbackMessage = "请选出消失的字母！"
    }

    func checkAnswer(_ answer: String) {
        let currentGroup = groups[currentGroupIndex]
        if let index = currentGroup.firstIndex(of: answer), hiddenIndices.contains(index) {
            if !solvedIndices.contains(index) {
                solvedIndices.insert(index)
                // 震动：成功
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
                
                if solvedIndices.count == hiddenIndices.count {
                    feedbackMessage = "太棒了！(すごい！)"
                }
            }
        } else {
            // 震动：错误
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
            feedbackMessage = "再试一次哦 (もう一度！)"
        }
    }

    func nextGroup() {
        currentGroupIndex = (currentGroupIndex + 1) % groups.count
        setupQuiz()
    }
}
