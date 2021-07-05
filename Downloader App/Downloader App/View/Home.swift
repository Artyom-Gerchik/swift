//
//  Home.swift
//  Downloader App
//
//  Created by Artyom on 28.06.21.
//

import SwiftUI

struct Home: View {
    @StateObject var downloadModel = DownloadTaskModel()
    @State var urlText = ""
    var body: some View {
        
        NavigationView{
            VStack(spacing: 15){
                TextField("URL: ", text: $urlText)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.06), radius: 5, x: 5, y: 5) // bottom
                    .shadow(color: Color.black.opacity(0.06), radius: 5, x: -5, y: -5) // top
                
                Button(action: {downloadModel.startDownload(urlString: urlText)}, label: {
                    Text("Download Content")
                        .fontWeight(.heavy)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                })
                .padding(.top)
                
                Button(action: {downloadModel.testFunc()}, label: {
                    Text("testButton")
                        .fontWeight(.heavy)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                })
                .padding(.top)
            }
            .padding()
            .navigationTitle("Downloader")
        }
        .preferredColorScheme(.light)
        .alert(isPresented: $downloadModel.showAlert, content: {
            Alert(title: Text("Error."), message: Text(downloadModel.alertMsg), dismissButton: .destructive(Text("OK"), action: {
                
            }))
        })
        .overlay(
            ZStack{
                if downloadModel.showDownloadProgress{
                    DownloadProgressView(progress: $downloadModel.downloadProgressForUI)
                        .environmentObject(downloadModel)
                }
            }
        )
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
