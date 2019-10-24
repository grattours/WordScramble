//
//  ContentView.swift
//  WordScramble
//
//  Created by Luc Derosne on 22/10/2019.
//  Copyright © 2019 Luc Derosne. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score: Int = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationView {
            VStack {
                //TextField("Enter your word", text: $newWord)
                TextField("Saisir votre mot", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Score: \(score)")
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading: Button("Rejouer", action: startGame))
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        score = 0
        if let startWordsURL = Bundle.main.url(forResource: "StarFr", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "geologie"

                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("fichier starFr.txt non chargé.")
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "fr")

        return misspelledRange.location == NSNotFound
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Mot déja utilisé", message: "Trouvez en un autre")
            return
        }

        guard !isTooShort(word: answer) else {
            wordError(title: "Mot trop court", message: "Au moins 3 caractères")
            return
        }
        
        guard !isStartWord(word: answer) else {
            wordError(title: "Mot de départ", message: "Gros malin !")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Mot inconnu", message: "On ne peut las les inventer")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Mot impossible", message: "Ce n'est pas un vrai mot")
            return
        }
        
        usedWords.insert(answer, at: 0)
        score += calculateScore(for: newWord)
        newWord = ""
    }
    
    func isTooShort(word: String) -> Bool {
        return word.count < 3
    }
    
    func isStartWord(word: String) -> Bool {
        let tempWord = rootWord.lowercased()
        return word.lowercased() == tempWord
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
}

func calculateScore(for word: String) -> Int {
    var scoreWord = 0
    scoreWord = word.count + 1
    return scoreWord
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
