//
//  ContentView.swift
//  Instafilter
//
//  Created by Oliver Lippold on 01/02/2020.
//  Copyright © 2020 Oliver Lippold. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var currentFilter:  CIFilter = CIFilter.sepiaTone()
    @State private var currentFilterTitle = "Sepia Tone"
    @State private var showingFilterSheet = false
    @State private var processedImage: UIImage?
    @State private var saveText = "Save"
    
    let context = CIContext()
    
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
        },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
        }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    
                    // display the image
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                    self.saveText = "Save"
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }.padding(.vertical)
                
                HStack {
                    Button("Change Filter (\(self.currentFilterTitle))") {
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button(saveText) {
                        guard let processedImage = self.processedImage else {
                            self.saveText = "No image"
                            return
                            
                        }
                        
                        let imageSaver = ImageSaver()
                        imageSaver.successHandler = {
                            print("Success")
                        }
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                            
                        }
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                }
            }
            .padding([.horizontal, .bottom] )
            .navigationBarTitle("InstaFilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
                
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallise")) {
                        self.setFilter(CIFilter.crystallize())
                        self.currentFilterTitle = "Crystallise"
                        
                    },
                    .default(Text("Edges")) {
                        self.setFilter(CIFilter.edges())
                        self.currentFilterTitle = "Edges"
                    },
                    .default(Text("Gaussian Blur")) {
                        self.setFilter(CIFilter.gaussianBlur())
                        self.currentFilterTitle = "Gaussian Blur"
                    },
                    .default(Text("Pixellate")) {
                        self.setFilter(CIFilter.pixellate())
                        self.currentFilterTitle = "Pixellate"
                    },
                    .default(Text("Sepia Tone")) {
                        self.setFilter(CIFilter.sepiaTone())
                        self.currentFilterTitle = "Sepia Tone"
                    },
                    .default(Text("Unsharp Mask")) {
                        self.setFilter(CIFilter.unsharpMask())
                        self.currentFilterTitle = "Unsharp Mask"
                    },
                    .default(Text("Vignette")) {
                        self.setFilter(CIFilter.vignette())
                        self.currentFilterTitle = "Vignette"
                    },
                    .cancel()
                ])
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)}
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)}
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
