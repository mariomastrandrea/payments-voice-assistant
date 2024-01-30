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
        
        self.customLM = SFCustomLanguageModelData(locale: self.locale, identifier: SpeechConfig.CustomLM.identifier, version: "1.0")
        {
            SFCustomLanguageModelData.PhraseCountsFromTemplates(classes: [
                "name": names,
                "surname": surnames,
                "bank": banks
            ]) {
                // generate one sentence from each template, choosing among the specified names, surnames and bank names
                for template in sentencesTemplates {
                    SFCustomLanguageModelData.TemplatePhraseCountGenerator.Template(
                        template, count: 1
                    )
                }
            }
        }
        
        return true
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
    
    func export(fileName modelFileName: String) async -> URL? {
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
            return modelUrl
        }
        catch let error {
            logError("Error: custom LM export failed.\n\(error.localizedDescription)")
            return nil
        }
    }
}
