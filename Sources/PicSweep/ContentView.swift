//
//  ContentView.swift
//  PicSweeper
//
//  Created by Jordan on 1/8/25.
//

import SwiftUI
import Photos

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct Theme {
    static let primary = Color("AccentColor")
    static let secondary = Color.orange
    #if os(iOS)
    static let background = Color(UIColor.systemBackground)
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let text = Color(UIColor.label)
    static let secondaryText = Color(UIColor.secondaryLabel)
    #else
    static let background = Color(NSColor.windowBackgroundColor)
    static let cardBackground = Color(NSColor.controlBackgroundColor)
    static let text = Color(NSColor.labelColor)
    static let secondaryText = Color(NSColor.secondaryLabelColor)
    #endif
    static let deleteColor = Color.red
    static let keepColor = Color.green
    
    static let cardShadow = Color.black.opacity(0.1)
    static let animationDuration: Double = 0.3
}

struct ContentView: View {
    @State private var showSettings = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("PicSweep")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.primary)
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                        
                        Text("Organize your photos")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    // Instructions Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundColor(Theme.deleteColor)
                            Text("Delete")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Text("Keep")
                                .font(.system(.body, design: .rounded))
                            Image(systemName: "arrow.right")
                                .foregroundColor(Theme.keepColor)
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(15)
                        .shadow(color: Theme.cardShadow, radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Main Content
                    PhotoSwipeView()
                        .frame(maxHeight: .infinity)
                        .padding()
                    
                    // Settings Button
                    Button(action: {
                        withAnimation(.spring()) {
                            showSettings.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Theme.text)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.cardBackground)
                        .cornerRadius(15)
                        .shadow(color: Theme.cardShadow, radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("About")) {
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("5.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/Jdeandrade22/PicSweep")!) {
                        Label("GitHub", systemImage: "link")
                    }
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
}
