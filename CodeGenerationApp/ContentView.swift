////
////  ContentView.swift
////  CodeGenerationApp
////
////  Created by Omveer Panwar on 27/09/24.
 
import SwiftUI
import CoreData
import Firebase

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ColorEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ColorEntity.timestamp, ascending: true)],
        animation: .default)
    private var savedColors: FetchedResults<ColorEntity>
    
    @State private var generatedColors: [String] = []
    @State private var syncedColors: Set<String> = []
    @State private var syncCount: Int = 0
    @State private var timer: Timer? = nil
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Color(UIColor(red: 0.11, green: 0.24, blue: 0.31, alpha: 1.0))
                        .frame(height: 130)
                        .ignoresSafeArea(edges: .top)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Color Generator")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.leading)
                        }
                        Spacer()
                        syncButton // Place the sync button in the header
                    }
                }
                
                Button(action: generateRandomColor) {
                    Text("Generate Random Color").bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.leading)
                }
                
                ScrollView {
                    VStack {
                        if !generatedColors.isEmpty {
                            Text("Generated Colors:")
                                .font(.headline)
                                .padding(.top)
                        }
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(generatedColors, id: \.self) { colorHex in
                                ColorCard(hex: colorHex)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("") // Clear the default title
            .onDisappear {
                timer?.invalidate() // Invalidate timer when the view disappears
            }
        }
    }
    
    private var syncButton: some View {
        Button(action: syncColors) {
            HStack {
                Text("Sync")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                
                Text("\(syncCount)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            .padding(.trailing, 5)
            .background(Color.green)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            .padding(.trailing, 10)
        }
    }

    func generateRandomColor() {
        let randomColor = String(format: "#%06X", Int.random(in: 0x000000...0xFFFFFF))
        generatedColors.append(randomColor)
        saveColor(randomColor)

        // Check if the color is already synced
        if !syncedColors.contains(randomColor) {
            syncCount += 1 // Increment count for unsynced colors
        }
    }
    
    func saveColor(_ hex: String) {
        let newColor = ColorEntity(context: viewContext)
        newColor.colorCode = hex
        newColor.timestamp = Date()
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save color: \(error.localizedDescription)")
        }
    }
    
    func syncColors() {
        guard !generatedColors.isEmpty else { return }
        
        let db = Firestore.firestore()
        
        // Sync only unsynced colors
        for color in generatedColors {
            if !syncedColors.contains(color) {
                let data: [String: Any] = [
                    "colorCode": color,
                    "timestamp": FieldValue.serverTimestamp()
                ]
                db.collection("colors").addDocument(data: data) { error in
                    if let error = error {
                        print("Error adding document: \(error.localizedDescription)")
                    } else {
                        print("Color \(color) synced to Firestore!")
                        syncedColors.insert(color)
                    }
                }
            }
        }
        
        // Start countdown timer
        startCountdown()
    }
    
    func startCountdown() {
        syncCount = generatedColors.filter { !syncedColors.contains($0) }.count
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.syncCount > 0 {
                self.syncCount -= 1
            } else {
                self.timer?.invalidate()
            }
        }
    }
}

struct ColorCard: View {
    let hex: String
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color(hex: hex))
                .frame(height: 100)
                .cornerRadius(10)
                .padding()
            
            Text(hex)
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

#Preview {
    ContentView()
}
