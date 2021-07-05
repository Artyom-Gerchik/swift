//
//  DownloadTaskModel.swift
//  Downloader App
//
//  Created by Artyom on 28.06.21.
//

import SwiftUI

class DownloadTaskModel: NSObject, ObservableObject, URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate {
    
    @Published var downloadURL: URL!
    
    @Published var alertMsg = ""
    @Published var showAlert = false
    
    @Published var downloadTaskSession: URLSessionDownloadTask!
    
    @Published var downloadProgressForUI: CGFloat = 0
    
    @Published var showDownloadProgress = false
    
    func reportError(error: String){
        alertMsg = error
        showAlert.toggle()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print(location)
        guard let url = downloadTask.originalRequest?.url else {
            self.reportError(error: "Error.")
            return
        }
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = directoryPath.appendingPathComponent(url.lastPathComponent)
        
        try? FileManager.default.removeItem(at: destinationURL)
        
        do{
            try FileManager.default.copyItem(at: location, to: destinationURL)
            print("Saving Success.")
            
            
            DispatchQueue.main.async{
                withAnimation{ self.showDownloadProgress = false }
                
                let controller = UIDocumentInteractionController(url: destinationURL)
                
                controller.delegate = self
                controller.presentPreview(animated: true)
                
            }
        }
        catch{
            self.reportError(error: "Error in Saving File.")
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let downloadProgress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        print(downloadProgress)
        
        DispatchQueue.main.async {
            self.downloadProgressForUI = downloadProgress
        }
        
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
    
    func cancelDownload(){
        if let task = downloadTaskSession, task.state == .running{
            downloadTaskSession.cancel()
            withAnimation{self.showDownloadProgress = false}
        }
    }
    
    func testFunc(){
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {

            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            print(directoryContents)

            //mp3:
            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
            print("mp3 urls:",mp3Files)
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            print("mp3 list:", mp3FileNames)
            
            //mp4
            let mp4Files = directoryContents.filter{ $0.pathExtension == "mp4" }
            print("mp4 urls:",mp4Files)
            let mp4FileNames = mp4Files.map{ $0.deletingPathExtension().lastPathComponent }
            print("mp4 list:", mp4FileNames)
            
            //png
            let pngFiles = directoryContents.filter{ $0.pathExtension == "png" }
            print("png urls:",pngFiles)
            let pngFileNames = pngFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print("png list:", pngFileNames)
            
            //pdf
            let pdfFiles = directoryContents.filter{ $0.pathExtension == "pdf" }
            print("pdf urls:",pdfFiles)
            let pdfFileNames = pdfFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print("pdf list:", pdfFileNames)
        
        } catch {
            print(error)
        }
    }
    
    func startDownload(urlString: String){
        
        guard let ValidUrl = URL(string: urlString) else {
            self.reportError(error: "InValid URL.")
            return
        }
        
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        if FileManager.default.fileExists(atPath: directoryPath.appendingPathComponent(ValidUrl.lastPathComponent).path){
            print("File Exist Yet, Opening.")
            
            let controller = UIDocumentInteractionController(url: directoryPath.appendingPathComponent(ValidUrl.lastPathComponent))
            
            controller.delegate = self
            controller.presentPreview(animated: true)
            
        }
        else{
            print("File Not Exist Yet, Downloading")
            downloadProgressForUI = 0
            withAnimation{showDownloadProgress = true}
            
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            downloadTaskSession = session.downloadTask(with: ValidUrl)
            downloadTaskSession.resume()
        }
    }
}
