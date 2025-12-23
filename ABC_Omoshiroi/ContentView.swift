import SwiftUI
import AVFoundation

// MARK: - 1. 数据模型与配置

struct AlphabetItem {
    let letter: String
    let word: String
    let emoji: String
    let color: Color
}

struct AlphabetData {
    static let items: [String: AlphabetItem] = [
        "A": AlphabetItem(letter: "A", word: "Apple", emoji: "🍎", color: .red),
        "B": AlphabetItem(letter: "B", word: "Ball", emoji: "⚽️", color: .blue),
        "C": AlphabetItem(letter: "C", word: "Cat", emoji: "🐱", color: .orange),
        "D": AlphabetItem(letter: "D", word: "Dog", emoji: "🐶", color: .brown),
        "E": AlphabetItem(letter: "E", word: "Elephant", emoji: "🐘", color: .purple),
        "F": AlphabetItem(letter: "F", word: "Fish", emoji: "🐟", color: .cyan),
        "G": AlphabetItem(letter: "G", word: "Goat", emoji: "🐐", color: .green),
        "H": AlphabetItem(letter: "H", word: "Hat", emoji: "👒", color: .pink),
        "I": AlphabetItem(letter: "I", word: "Ice cream", emoji: "🍦", color: .yellow),
        "J": AlphabetItem(letter: "J", word: "Juice", emoji: "🧃", color: .orange),
        "K": AlphabetItem(letter: "K", word: "Kite", emoji: "🪁", color: .blue),
        "L": AlphabetItem(letter: "L", word: "Lion", emoji: "🦁", color: .red),
        "M": AlphabetItem(letter: "M", word: "Monkey", emoji: "🐒", color: .brown),
        "N": AlphabetItem(letter: "N", word: "Nose", emoji: "👃", color: .pink),
        "O": AlphabetItem(letter: "O", word: "Orange", emoji: "🍊", color: .orange),
        "P": AlphabetItem(letter: "P", word: "Pig", emoji: "🐷", color: .pink),
        "Q": AlphabetItem(letter: "Q", word: "Queen", emoji: "👸", color: .purple),
        "R": AlphabetItem(letter: "R", word: "Rabbit", emoji: "🐰", color: .gray),
        "S": AlphabetItem(letter: "S", word: "Sun", emoji: "☀️", color: .yellow),
        "T": AlphabetItem(letter: "T", word: "Tiger", emoji: "🐯", color: .orange),
        "U": AlphabetItem(letter: "U", word: "Umbrella", emoji: "☂️", color: .purple),
        "V": AlphabetItem(letter: "V", word: "Van", emoji: "🚐", color: .blue),
        "W": AlphabetItem(letter: "W", word: "Watch", emoji: "⌚️", color: .gray),
        "X": AlphabetItem(letter: "X", word: "Xylophone", emoji: "🎹", color: .green),
        "Y": AlphabetItem(letter: "Y", word: "Yo-yo", emoji: "🪀", color: .red),
        "Z": AlphabetItem(letter: "Z", word: "Zebra", emoji: "🦓", color: .black)
    ]
}

// 连连看专用的卡片模型
struct LinkGameItem: Identifiable, Equatable {
    let id = UUID()
    let text: String      // 显示的文字 "A" 或 "a"
    let letterKey: String // 用于比对的 Key "A"
    let isUppercase: Bool // 是左边还是右边
    var isMatched: Bool = false
    var isFaceUp: Bool = true // 控制显示/隐藏
}

// AI 对话模型
struct ChatScenario {
    let question: String
    let options: [ChatOption]
}
struct ChatOption {
    let text: String
    let emoji: String
    let reply: String
}

// MARK: - 2. 主视图 ContentView

struct ContentView: View {
    @State private var currentLevel = 1
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部模式切换
                Picker("游戏模式", selection: $currentLevel) {
                    Text("认知").tag(1)
                    Text("挑战").tag(2)
                    Text("连线").tag(3)
                    Text("AI对话").tag(4)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(red: 0.98, green: 0.96, blue: 0.92))

                // 内容区域
                ZStack {
                    if currentLevel == 1 {
                        LevelOneView()
                    } else if currentLevel == 2 {
                        LevelTwoView()
                    } else if currentLevel == 3 {
                        LevelThreeView()
                    } else {
                        LevelFourView()
                    }
                }
            }
            .navigationTitle("ABC、面白い！")
            .background(Color(red: 0.98, green: 0.96, blue: 0.92))
        }
    }
}

// MARK: - 3. 第一关：3D翻转认知

struct LevelOneView: View {
    let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }
    @State private var flippedLetter: String? = nil
    private let synthesizer = AVSpeechSynthesizer()
    let columns = [GridItem(.adaptive(minimum: 130), spacing: 20)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(letters, id: \.self) { char in
                    if let item = AlphabetData.items[char] {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                if flippedLetter == char { flippedLetter = nil }
                                else {
                                    flippedLetter = char
                                    playSpeech(for: item)
                                }
                            }
                        }) {
                            FlipCardView(item: item, isFlipped: flippedLetter == char)
                        }
                        .buttonStyle(KiddyButtonStyle())
                    }
                }
            }
            .padding(20)
        }
    }

    func playSpeech(for item: AlphabetItem) {
        synthesizer.stopSpeaking(at: .immediate)
        let phrase = (item.letter == "L") ? "\(item.letter)..... L is for Lion. Roar!" : "\(item.letter)..... \(item.letter) is for \(item.word)"
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
}

struct FlipCardView: View {
    let item: AlphabetItem
    let isFlipped: Bool
    var body: some View {
        ZStack {
            CardFace(text: item.letter, subText: "", bgColor: .white, textColor: item.color)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 0 : 1)
            CardFace(text: item.emoji, subText: item.word, bgColor: item.color, textColor: .white)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
    }
}

struct CardFace: View {
    let text: String, subText: String, bgColor: Color, textColor: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(bgColor)
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
            VStack {
                Text(text).font(.system(size: subText.isEmpty ? 70 : 55, weight: .bold, design: .rounded))
                if !subText.isEmpty { Text(subText).font(.system(size: 22, weight: .heavy, design: .rounded)) }
            }
            .foregroundColor(textColor)
        }
        .frame(height: 150)
    }
}

// MARK: - 4. 第二关：猜字母挑战

struct LevelTwoView: View {
    let groups = [["A","B","C","D","E"], ["F","G","H","I","J"], ["K","L","M","N","O"], ["P","Q","R","S","T"], ["U","V","W","X","Y","Z"]]
    @State private var currentGroupIndex = 0
    @State private var hiddenIndices: Set<Int> = []
    @State private var solvedIndices: Set<Int> = []
    @State private var feedbackMessage = "Find the missing letter!"
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Stage \(currentGroupIndex + 1)").font(.title.bold())
            HStack(spacing: 12) {
                let group = groups[currentGroupIndex]
                ForEach(0..<group.count, id: \.self) { i in
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(hiddenIndices.contains(i) && !solvedIndices.contains(i) ? Color.gray.opacity(0.2) : .white)
                            .frame(width: 65, height: 90)
                            .shadow(radius: 3)
                        if hiddenIndices.contains(i) {
                            Text(solvedIndices.contains(i) ? group[i] : "?")
                                .font(.title).bold()
                                .foregroundColor(solvedIndices.contains(i) ? .green : .gray)
                        } else {
                            Text(group[i]).font(.title).bold()
                        }
                    }
                }
            }
            Text(feedbackMessage).font(.headline).foregroundColor(.secondary)
            HStack(spacing: 15) {
                ForEach(groups[currentGroupIndex].shuffled(), id: \.self) { opt in
                    Button(action: { checkAnswer(opt) }) {
                        Text(opt).font(.title2.bold()).frame(width: 60, height: 60)
                            .background(Color.orange).foregroundColor(.white).clipShape(Circle())
                    }.buttonStyle(KiddyButtonStyle())
                }
            }
            if solvedIndices.count == hiddenIndices.count {
                Button("Next Level ➔") {
                    currentGroupIndex = (currentGroupIndex + 1) % groups.count
                    setupQuiz()
                }.buttonStyle(.borderedProminent).tint(.green)
            }
            Spacer()
        }.padding().onAppear { setupQuiz() }
    }
    
    func checkAnswer(_ ans: String) {
        let group = groups[currentGroupIndex]
        let generator = UINotificationFeedbackGenerator()
        if let i = group.firstIndex(of: ans), hiddenIndices.contains(i), !solvedIndices.contains(i) {
            solvedIndices.insert(i); generator.notificationOccurred(.success)
            if solvedIndices.count == hiddenIndices.count { feedbackMessage = "Great Job! 🎉"; playSound("Excellent!") }
        } else { generator.notificationOccurred(.error); feedbackMessage = "Try again!" }
    }
    func setupQuiz() { solvedIndices.removeAll(); hiddenIndices = Set((0..<groups[currentGroupIndex].count).shuffled().prefix(2)); feedbackMessage = "Find the missing letter!" }
    func playSound(_ str: String) {
        let ut = AVSpeechUtterance(string: str); ut.rate = 0.5; synthesizer.speak(ut)
    }
}

// MARK: - 5. 第三关：左右连连看 (重制版)

struct LevelThreeView: View {
    @State private var leftItems: [LinkGameItem] = []
    @State private var rightItems: [LinkGameItem] = []
    
    @State private var selectedLeftID: UUID?
    @State private var selectedRightID: UUID?
    
    // 游戏状态
    @State private var isHardMode = false // 默认简单模式（明牌）
    @State private var round = 1
    
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            // 顶部：回合数 + 难度开关 + 刷新
            HStack {
                Text("Round \(round)").font(.title3.bold())
                Spacer()
                
                // 难度切换
                Picker("Difficulty", selection: $isHardMode) {
                    Text("☀️ Easy").tag(false)
                    Text("🌙 Hard").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
                .onChange(of: isHardMode) { _ in startNewRound() }
                
                Spacer()
                Button(action: startNewRound) {
                    Image(systemName: "arrow.clockwise.circle.fill").font(.largeTitle).foregroundColor(.blue)
                }
            }
            .padding()

            // 游戏主区域：左右分栏
            HStack(spacing: 40) {
                // 左侧：大写字母
                VStack(spacing: 20) {
                    Text("Big Letter").font(.caption).foregroundColor(.gray)
                    ForEach(leftItems) { item in
                        LinkCardView(item: item, isSelected: selectedLeftID == item.id, isHardMode: isHardMode)
                            .onTapGesture { handleTap(item: item, isLeft: true) }
                    }
                }
                
                // 右侧：小写字母
                VStack(spacing: 20) {
                    Text("Small Letter").font(.caption).foregroundColor(.gray)
                    ForEach(rightItems) { item in
                        LinkCardView(item: item, isSelected: selectedRightID == item.id, isHardMode: isHardMode)
                            .onTapGesture { handleTap(item: item, isLeft: false) }
                    }
                }
            }
            .padding()
            
            Spacer()
            
            // 胜利动画
            if !leftItems.isEmpty && leftItems.allSatisfy({ $0.isMatched }) {
                Text("🎉 Perfect Match! 🎉")
                    .font(.largeTitle.bold())
                    .foregroundColor(.orange)
                    .transition(.scale)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            startNewRound()
                        }
                    }
            }
        }
        .onAppear(perform: startNewRound)
    }

    // 逻辑：开始新回合
    func startNewRound() {
        let allLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }.shuffled().prefix(4)
        
        var newLeft: [LinkGameItem] = []
        var newRight: [LinkGameItem] = []
        
        for letter in allLetters {
            newLeft.append(LinkGameItem(text: letter, letterKey: letter, isUppercase: true, isFaceUp: !isHardMode))
            newRight.append(LinkGameItem(text: letter.lowercased(), letterKey: letter, isUppercase: false, isFaceUp: !isHardMode))
        }
        
        leftItems = newLeft // 左边固定顺序 A,B,C,D (其实是随机抽取的4个)
        rightItems = newRight.shuffled() // 右边打乱顺序
        
        selectedLeftID = nil
        selectedRightID = nil
        if leftItems.allSatisfy({ $0.isMatched }) { round += 1 }
    }

    // 逻辑：处理点击
    func handleTap(item: LinkGameItem, isLeft: Bool) {
        if item.isMatched { return } // 已经消掉的不能点
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // 困难模式翻牌逻辑
        if isHardMode {
            withAnimation {
                if isLeft {
                    // 如果点了左边，把左边其他的盖回去，把当前翻开
                    leftItems.indices.forEach { leftItems[$0].isFaceUp = ($0 == leftItems.firstIndex(where: {$0.id == item.id})) }
                } else {
                    rightItems.indices.forEach { rightItems[$0].isFaceUp = ($0 == rightItems.firstIndex(where: {$0.id == item.id})) }
                }
            }
        }

        // 选中逻辑
        if isLeft {
            selectedLeftID = item.id
        } else {
            selectedRightID = item.id
        }
        
        // 检查配对
        checkMatch()
    }
    
    func checkMatch() {
        guard let leftID = selectedLeftID, let rightID = selectedRightID else { return }
        guard let leftIndex = leftItems.firstIndex(where: { $0.id == leftID }),
              let rightIndex = rightItems.firstIndex(where: { $0.id == rightID }) else { return }
        
        let leftItem = leftItems[leftIndex]
        let rightItem = rightItems[rightIndex]
        
        if leftItem.letterKey == rightItem.letterKey {
            // 配对成功
            playMatchSound(letter: leftItem.letterKey)
            withAnimation(.easeInOut(duration: 0.5)) {
                leftItems[leftIndex].isMatched = true
                rightItems[rightIndex].isMatched = true
            }
            selectedLeftID = nil
            selectedRightID = nil
        } else {
            // 配对失败
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            // 延迟一点点取消选中，让孩子看到选错了
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    selectedLeftID = nil
                    selectedRightID = nil
                    // 困难模式下，配对失败要盖回去
                    if isHardMode {
                        leftItems[leftIndex].isFaceUp = false
                        rightItems[rightIndex].isFaceUp = false
                    }
                }
            }
        }
    }
    
    func playMatchSound(letter: String) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        let word = AlphabetData.items[letter]?.word ?? ""
        let ut = AVSpeechUtterance(string: "Yes! \(letter) is for \(word)")
        ut.voice = AVSpeechSynthesisVoice(language: "en-US"); ut.rate = 0.5
        synthesizer.speak(ut)
    }
}

// 连连看卡片视图
struct LinkCardView: View {
    let item: LinkGameItem
    let isSelected: Bool
    let isHardMode: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(item.isMatched ? Color.clear : (isSelected ? Color.yellow : (item.isUppercase ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))))
                .frame(width: 100, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.yellow : (item.isUppercase ? Color.orange : Color.blue), lineWidth: item.isMatched ? 0 : 3)
                )
            
            if !item.isMatched {
                if item.isFaceUp {
                    Text(item.text)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(item.isUppercase ? .orange : .blue)
                } else {
                    Text("?")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

// MARK: - 6. 第四关：AI 对话

struct LevelFourView: View {
    @State private var chatHistory: [(isUser: Bool, text: String)] = [(false, "Hello! Let's talk!")]
    @State private var currentScenarioIndex = 0
    @State private var isWaitingForAnswer = true
    private let synthesizer = AVSpeechSynthesizer()
    
    let scenarios: [ChatScenario] = [
        ChatScenario(question: "Which color do you like?", options: [
            ChatOption(text: "Red", emoji: "🔴", reply: "Wow, Red is like an Apple!"),
            ChatOption(text: "Blue", emoji: "🔵", reply: "Cool, Blue is like the Sky!"),
            ChatOption(text: "Green", emoji: "🟢", reply: "Nice, Green is like a Tree!")
        ]),
        ChatScenario(question: "Which animal is fast?", options: [
            ChatOption(text: "Turtle", emoji: "🐢", reply: "Oh no, Turtle is slow."),
            ChatOption(text: "Rabbit", emoji: "🐰", reply: "Yes! Rabbit is very fast!"),
            ChatOption(text: "Snail", emoji: "🐌", reply: "Haha, Snail is very slow.")
        ]),
        ChatScenario(question: "What do you like to eat?", options: [
            ChatOption(text: "Pizza", emoji: "🍕", reply: "Yummy! Pizza is delicious."),
            ChatOption(text: "Broccoli", emoji: "🥦", reply: "Good! Broccoli is healthy."),
            ChatOption(text: "Ice Cream", emoji: "🍦", reply: "Sweet! But don't eat too much.")
        ])
    ]
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(chatHistory.indices, id: \.self) { index in
                            let chat = chatHistory[index]
                            HStack(alignment: .top) {
                                if !chat.isUser { Text("🤖").font(.largeTitle).padding(.top, 5) }
                                Text(chat.text).padding().background(chat.isUser ? Color.blue : Color.white)
                                    .foregroundColor(chat.isUser ? .white : .black).cornerRadius(15).shadow(radius: 2)
                                if chat.isUser { Spacer() } else { Spacer() }
                            }.id(index)
                        }
                    }.padding()
                }.onChange(of: chatHistory.count) { _ in withAnimation { proxy.scrollTo(chatHistory.count - 1, anchor: .bottom) } }
            }
            Divider()
            VStack {
                if isWaitingForAnswer {
                    HStack(spacing: 15) {
                        ForEach(scenarios[currentScenarioIndex].options, id: \.text) { option in
                            Button(action: { handleUserSelection(option) }) {
                                VStack { Text(option.emoji).font(.largeTitle); Text(option.text).font(.headline) }
                                .frame(maxWidth: .infinity).padding().background(Color.orange.opacity(0.1))
                                .cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange, lineWidth: 2))
                            }
                        }
                    }.padding()
                } else {
                    Button(action: nextQuestion) {
                        Text("Next Question ➔").font(.title3.bold()).padding().frame(maxWidth: .infinity)
                            .background(Color.green).foregroundColor(.white).cornerRadius(12)
                    }.padding()
                }
            }.background(Color.white)
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { speak(scenarios[currentScenarioIndex].question) }
        }
    }
    
    func handleUserSelection(_ option: ChatOption) {
        chatHistory.append((true, "\(option.emoji) \(option.text)")); isWaitingForAnswer = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            chatHistory.append((false, option.reply)); speak(option.reply)
        }
    }
    func nextQuestion() {
        currentScenarioIndex = (currentScenarioIndex + 1) % scenarios.count; isWaitingForAnswer = true
        let nextQ = scenarios[currentScenarioIndex].question; chatHistory.append((false, nextQ)); speak(nextQ)
    }
    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate); let ut = AVSpeechUtterance(string: text)
        ut.voice = AVSpeechSynthesisVoice(language: "en-US"); ut.rate = 0.35; ut.pitchMultiplier = 1.1
        synthesizer.speak(ut)
    }
}

struct KiddyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}
