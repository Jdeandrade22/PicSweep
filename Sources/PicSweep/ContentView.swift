//
//  ContentView.swift
//  PicSweeper
//
//  Created by Jordan on 1/8/25.
//

import SwiftUI
import Photos

struct Theme {
    static let primary = Color("AccentColor")
    static let secondary = Color.orange
    static let background = Color(.systemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
    static let text = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
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
                        
                        Text("Organize your memories")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    // Instructions Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.red)
                            Text("Delete")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Text("Keep")
                                .font(.system(.body, design: .rounded))
                            Image(systemName: "arrow.right")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Main Content
                    PhotoSwipeView()
                        .frame(maxHeight: .infinity)
                        .padding()
                    
                    // Bottom Bar
                    HStack(spacing: 20) {
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
                            .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
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
    @State private var notificationsEnabled = false
    @State private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Enable Notifications", systemImage: "bell.fill")
                    }
                    
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/Jdeandrade22/PicSweep")!) {
                        Label("GitHub", systemImage: "link")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
