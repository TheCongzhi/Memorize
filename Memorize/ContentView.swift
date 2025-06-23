//
//  ContentView.swift
//  Memorize
//
//  Created by Du Zhi on 2025/5/9.
//

import SwiftUI

struct Theme {
    let name: String
    let systemImageName: String
    let emojis: [String] // Same as Array<String>
    let color: Color
}

struct Card {
    let content: String
    var isFaceUp = false
    var isMatched = false
}

struct ContentView: View {
    let themes: [Theme] = [
        Theme(name: "Vehicles", systemImageName: "car", emojis: ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐"], color: .black),
        Theme(name: "Faces", systemImageName: "face.smiling", emojis: ["😀", "😂", "🥳", "😍", "🤔", "😎", "😭", "😡", "👻", "👾"], color: .yellow),
        Theme(name: "Fruits", systemImageName: "carrot", emojis: ["🍎", "🍌", "🍊", "🍇", "🍓", "🍉", "🍑", "🍒", "🍈", "🍋"], color: .red),
        Theme(name: "Animals", systemImageName: "dog", emojis: ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯"], color: .brown)
    ]
    
    
    @State private var selectedTheme: Theme
    @State private var themeColor: Color
    @State private var cards: [Card]
    @State private var faceUpCards: [Int] = []

    init() {
        let defaultTheme = Theme(
            name: "Vehicles",
            systemImageName: "car",
            emojis: ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐"],
            color: .black
        )
        _selectedTheme = State(initialValue: defaultTheme)
        _themeColor = State(initialValue: defaultTheme.color)
        _cards = State(initialValue: defaultTheme.emojis.prefix(10).flatMap { [Card(content: $0), Card(content: $0)] }.shuffled())
    }

    
    var body: some View {
        VStack(content: {
            Text("Memorize!")
                .bold()
                .font(.largeTitle)
                .foregroundColor(themeColor)
                .padding()
            Spacer()
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))]) {
                ForEach(0..<cards.count, id: \.self) { index in
                    CardView(card: cards[index], themeColor: themeColor)
                        .onTapGesture {
                            handleCardTap(at: index)
                        }
                        .animation(.spring(), value: cards[index].isFaceUp)
                        .animation(.spring(), value: cards[index].isMatched)
                    }
                }
                .padding()
            Spacer()
            HStack(content: {
                ForEach(Array(themes.enumerated()), id: \.offset) { index, theme in
                    ThemeButton(
                        theme: theme,
                        themeIndex: index,
                        isToggled: theme.name == selectedTheme.name
                    ) {
                        selectedTheme = theme
                        themeColor = theme.color
                        cards = theme.emojis.shuffled().prefix(10).flatMap {
                            [Card(content: $0), Card(content: $0)]
                        }.shuffled()
                    }
                }
            })
        })
    }
    private func handleCardTap(at index: Int) {
        guard !cards[index].isFaceUp && !cards[index].isMatched else {return}
        if faceUpCards.count == 2 {
            cardMatch()
        }
        var updateCards = cards
        updateCards[index].isFaceUp = true
        cards = updateCards
        faceUpCards.append(index)
        if faceUpCards.count == 2 {
            cardMatch()
        }
    }
    private func cardMatch() {
        guard faceUpCards.count == 2 else {return}
        var updateCards = cards
        let card1Index = faceUpCards[0]
        let card2Index = faceUpCards[1]
        
        // Cards matched
        if cards[card1Index].content == cards[card2Index].content {
            updateCards[card1Index].isMatched = true
            updateCards[card2Index].isMatched = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        var delayUpdate = cards
                        delayUpdate[card1Index].isFaceUp = false
                        delayUpdate[card2Index].isFaceUp = false
                        self.cards = delayUpdate
            }
        }
        cards = updateCards
        faceUpCards.removeAll()
    }
}

struct ThemeButton: View {
    
    let theme: Theme
    let themeIndex: Int
    let isToggled: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(content: {
            Button(action: action) {
                Image(systemName: isToggled ? theme.systemImageName : "questionmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(isToggled ? theme.color : .blue)
            }
            Text(isToggled ? theme.name : "Theme\(themeIndex + 1)")
                .foregroundColor(isToggled ? theme.color : .blue)
                .bold()
        })
        .frame(width: 80)
    }
}

struct CardView: View {
    let card: Card
    let themeColor: Color
    var body: some View {
        ZStack {
            var base: RoundedRectangle = RoundedRectangle(cornerRadius: 12)
                base.fill(card.isFaceUp ? Color.white : themeColor)
                .shadow(radius: 3)
            if card.isFaceUp {
                Text(card.content)
                    .font(.largeTitle)
                    .padding()
                base.strokeBorder(card.isMatched ? .green : themeColor, lineWidth: 3)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
    }
}

#Preview {
    ContentView()
}
