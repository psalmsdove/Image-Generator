//
//  ContentView.swift
//  Image Generator with OpenAI
//
//  Created by Ali Erdem Kökcik on 1.01.2023.
//
import OpenAIKit
import SwiftUI

final class ViewModel: ObservableObject{
    private var openai: OpenAI?
    
    func setup(){
        openai = OpenAI(Configuration(organization: "Personal", apiKey: "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"))
    }
    func generateImage(prompt: String) async -> UIImage?{
        guard let openai = openai else{
            return nil
        }
        do {
            let params = ImageParameters(prompt: prompt, resolution: .medium, responseFormat: .base64Json)
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
        }
        catch {
            print(String(describing: error))
            return nil
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    
    var body: some View {
        NavigationView{
            VStack{
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                } else {
                    Text("Type a sentence to generate image.")
                        .fontWeight(.bold)
                }
                Spacer()
                TextField("Type a sentence here", text: $text)
                    .padding()
                    .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black, lineWidth: 2)
                        )
                Button("Generate"){
                        if !text.trimmingCharacters(in: .whitespaces).isEmpty{
                            Task {
                                let result = await viewModel.generateImage(prompt: text)
                                if result == nil{
                                    print("Failed to get the image.")
                                }
                                self.image = result
                        }
                    }
                }
                .buttonStyle(.bordered)
                .tint(.black)
            }
            .navigationTitle("Image Generator")
            .onAppear{
                viewModel.setup()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
