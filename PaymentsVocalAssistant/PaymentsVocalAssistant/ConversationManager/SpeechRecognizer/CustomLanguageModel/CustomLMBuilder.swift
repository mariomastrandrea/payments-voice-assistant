//
//  CustomLMBuilder.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 30/01/24.
//

import Foundation

import Foundation
import Speech

@available(iOS 17, *)
class CustomLMBuilder {
    private var customLM: SFCustomLanguageModelData?
    private let locale: Locale
    
    init(locale: Locale) {
        self.locale = locale
    }
    
    func build(
        withNames names: [String],
        surnames: [String],
        banks: [String],
        andTemplatesFromCsv fileName: String
    ) -> Bool {
        guard let sentencesTemplates = Self.importDataset(fromCsv: fileName) else { return false }
        let multiplier = 3  // generate 3 sentences from each template
        
        // manually substitute entities placeholders with user's contacts names and banks
        let filledSentencesWithCustomNames = sentencesTemplates.flatMap { template in
            (0..<multiplier).map { _ in
                randomlyFill(template: template, withNames: names, surnames: surnames, andBanks: banks)
            }
        }
        
        logInfo("Filled templates for Custom LM: #\(filledSentencesWithCustomNames.count)")
        
        self.customLM = SFCustomLanguageModelData(locale: self.locale, identifier: SpeechConfig.CustomLM.identifier, version: "1.0")
        {
            // use each filled template to customize the Custom Language model
            for sentence in filledSentencesWithCustomNames {
                SFCustomLanguageModelData.PhraseCount(phrase: sentence, count: 1)
            }
        }
        
        return true
    }
    
    private func randomlyFill(template: String, withNames names: [String], surnames: [String], andBanks banks: [String]) -> String {
        // choose random name, surname and bank. Name and surname are chosen from the same contact
        let randomNameIndex = names.indices.randomElement() ?? 0
        let randomName = names[safe: randomNameIndex] ?? "John"
        let randomSurname = surnames[safe: randomNameIndex] ?? "Doe"
        let randomBank = banks.randomElement() ?? "Top Bank"
        
        let filledSentence = template.replacingOccurrences(of: "<name>", with: randomName)
                                     .replacingOccurrences(of: "<surname>", with: randomSurname)
                                     .replacingOccurrences(of: "<bank>", with: randomBank)
        return filledSentence
    }
    
    private static func importDataset(fromCsv fileName: String, atColumn col: Int = 0) -> [String]? {
        let fileNameComponents = fileName.components(separatedBy: ".")
        
        guard let path = Bundle(for: Self.self).path(
            forResource: fileNameComponents[0],
            ofType: fileNameComponents[1]
        ) else {
            print("Error: dataset file not found")
            return nil
        }
        
        let fileContent: String
        
        do {
            fileContent = try String(contentsOfFile: path)
        }
        catch let error {
            print("Error: failed to read file.\n\(error.localizedDescription)")
            return nil
        }
        
        let sentences = fileContent.components(separatedBy: .newlines).map { line in
            line.components(separatedBy: ",")[col]
        }
            
        return sentences
    }
    
    func export(fileName modelFileName: String) async -> Result<URL, SpeechRecognizerError> {
        do {
            // create url to export the custom model
            let modelUrl = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent(modelFileName)
                        
            try await self.customLM?.export(to: modelUrl)
            
            logSuccess("* exported model at: \(modelUrl.absoluteString)")
            return .success(modelUrl)
        }
        catch let error {
            return .failure(.customLMnotExported(localizedDescription: error.localizedDescription))
        }
    }
}
