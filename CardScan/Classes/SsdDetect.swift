//
//  SsdDetect.swift
//  CardScan
//
//  Created by Zain on 8/5/19.
//

import Foundation
import os.log

/**
 Documentation on how SSD works
 
 */


@available(iOS 11.2, *)
public struct SsdDetect {
    static var ssdModel: SSD? = nil
    static var priors:[[Float]]? = nil
    
    // SSD Model Parameters
    
    let SSDCardWidth = 300
    let SSDCardHeight = 300
   
    
    let NoOfPriorsPerLocation = 6
    let NoOfClasses = 8
    let TotalNumberOfPriors = 2766
    let NoOfCordinates = 4
    let featureMapSizes = [19, 10]
    let probThreshold: Float = 0.2
    let iouThreshold: Float = 0.45
    let candidateSize = 200
    let topK = 10
    var ssdBoxes:[DetectedSSDBox] = []
    
    
    
    func warmUp() {
        //SsdDetect.initializeModels()
        
        UIGraphicsBeginImageContext(CGSize(width: SSDCardWidth, height: SSDCardHeight))
        UIColor.white.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: SSDCardWidth, height: SSDCardHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let ssdModel = SsdDetect.ssdModel else {
            print("Models not initialized")
            return
        }
        
        if let pixelBuffer = newImage?.pixelBuffer(width: SSDCardWidth, height: SSDCardHeight) {
            let _ = try? ssdModel.prediction(_0: pixelBuffer)
        }
        
    }
    
    public static func initializeModels( contentsOf url: URL) throws {
        if SsdDetect.ssdModel == nil {
            SsdDetect.ssdModel = try SSD(contentsOf: url)
            }
        if SsdDetect.priors == nil{
            SsdDetect.priors = PriorsGen.combinePriors()
        }
        }
   
    func detectObjects(prediction: SSDOutput, image: UIImage) -> [DetectedSSDBox]{
        var DetectedSSDBoxes : [DetectedSSDBox] = []
        
        var startTime = CFAbsoluteTimeGetCurrent()
        let boxes = prediction.getBoxes()
        let scores = prediction.getScores()
        var endTime = CFAbsoluteTimeGetCurrent() - startTime
        os_log("%@", type: .debug, "Get boxes and scores from mult-array time: \(endTime)")
        
        startTime = CFAbsoluteTimeGetCurrent()
        let normalizedScores = prediction.fasterSoftmax2D(scores)
        let regularBoxes = prediction.convertLocationsToBoxes(locations: boxes, priors: SsdDetect.priors ?? PriorsGen.combinePriors(), centerVariance: 0.1, sizeVariance: 0.2)
        let cornerFormBoxes = prediction.centerFormToCornerForm(regularBoxes: regularBoxes)

        let predAPI = PredictionAPI()
        var result:Result = predAPI.predictionAPI(scores:normalizedScores, boxes: cornerFormBoxes, probThreshold: probThreshold, iouThreshold: iouThreshold, candidateSize:candidateSize, topK: topK)
        endTime = CFAbsoluteTimeGetCurrent() - startTime
        os_log("%@", type: .debug, "Rest of the forward pass time: \(endTime)")
        
        for idx in 0..<result.pickedBoxes.count{
            DetectedSSDBoxes.append(DetectedSSDBox(category: result.pickedLabels[idx], XMin: Double(result.pickedBoxes[idx][0]), YMin: Double(result.pickedBoxes[idx][1]), XMax: Double(result.pickedBoxes[idx][2]), YMax: Double(result.pickedBoxes[idx][3]), imageSize: image.size))
        }


       return DetectedSSDBoxes
        
    }
    
    
    public mutating func predict(image: UIImage) -> String? {
        //SsdDetect.initializeModels()
        
        guard let pixelBuffer = image.pixelBuffer(width: SSDCardWidth, height: SSDCardHeight) else {
            os_log("Couldn't convert to pixel buffer", type: .error)
            return nil
        }
        
        
        guard let detectModel = SsdDetect.ssdModel else {
            os_log("Model not initialized", type: .error)
            return nil
        }
       
        let startTime = CFAbsoluteTimeGetCurrent()
        guard let prediction = try? detectModel.prediction(_0: pixelBuffer) else {
            os_log("Couldn't predict", type: .error)
            return nil
        }
        let endTime = CFAbsoluteTimeGetCurrent() - startTime
        os_log("%@", type: .debug, "Model Run without post-process time: \(endTime)")

        self.ssdBoxes = self.detectObjects(prediction: prediction, image: image)
        return "Sucess"
    }
    

}