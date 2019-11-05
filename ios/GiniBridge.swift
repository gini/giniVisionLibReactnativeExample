//
//  GiniBridgeSwift.swift
//  giniReactnative
//
//  Created by Maciej Trybilo on 31.10.19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import GiniVision
import Gini

@objc(GiniBridge)
class GiniBridge: NSObject {
  
  private lazy var giniConfiguration: GiniConfiguration = {
      let giniConfiguration = GiniConfiguration()
      giniConfiguration.debugModeOn = true
      giniConfiguration.fileImportSupportedTypes = .pdf_and_images
      giniConfiguration.openWithEnabled = true
      giniConfiguration.qrCodeScanningEnabled = true
      giniConfiguration.multipageEnabled = true
      giniConfiguration.flashToggleEnabled = true
      giniConfiguration.navigationBarItemTintColor = .white
      giniConfiguration.customDocumentValidations = { document in
          // As an example of custom document validation, we add a more strict check for file size
          let maxFileSize = 5 * 1024 * 1024
          if document.data.count > maxFileSize {
              let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als 5MB")
              return CustomDocumentValidationResult.failure(withError: error)
          }
          return CustomDocumentValidationResult.success()
      }
      return giniConfiguration
  }()
  
  private weak var gvlViewController: UIViewController?
  
  @objc func showGini() {
    
    DispatchQueue.main.async {
      
      let client = CredentialsManager.fetchClientFromBundle()
      
      let vc = GiniVision.viewController(withClient: client,
                                         importedDocuments: nil,
                                         configuration: self.giniConfiguration,
                                         resultsDelegate: self,
                                         documentMetadata: nil)
      
      self.gvlViewController = vc
            
      UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
    }
  }
}

extension GiniBridge: GiniVisionResultsDelegate {
  
  func giniVisionAnalysisDidFinishWith(result: AnalysisResult,
                                       sendFeedbackBlock: @escaping ([String: Extraction]) -> Void) {
    let message = result.extractions.map({ (key, value) -> String in
      "\(key): \(value.value)\n"
      }).reduce("", +)
    
    let alertView = UIAlertController(title: "Results", message: message, preferredStyle: .alert)
    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
      
      self.gvlViewController?.dismiss(animated: true, completion: nil)
      
      sendFeedbackBlock(result.extractions.values.reduce([:]) {
        guard let name = $1.name else { return $0 }
        var result = $0
        result[name] = $1
        return result
      })
      
    }))
    
    gvlViewController?.present(alertView, animated: true, completion: nil)
    
    print("analysis did finish with result:\n\(message)")
  }
  
  func giniVisionDidCancelAnalysis() {
    gvlViewController?.dismiss(animated: true, completion: nil)
  }
  
  func giniVisionAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool) {
    gvlViewController?.dismiss(animated: true, completion: nil)
  }
}
