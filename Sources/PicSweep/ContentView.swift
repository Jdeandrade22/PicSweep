//
//  ContentView.swift
//  PicSweeper
//
//  Created by Jordan on 1/8/25.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to PicSweep")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Text("Swipe right to save a photo or left to delete it.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                PhotoSwipeView() // The primary swipe functionality

                Spacer()

                Button(action: {
                    showSettings.toggle()
                }) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding([.leading, .trailing], 20)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }
            .navigationTitle("PicSweep")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Toggle("Enable Notifications", isOn: .constant(false))
                .padding()

            Spacer()
        }
        .padding()
    }
}
