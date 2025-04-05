//
//  ContentView.swift
//  PostLanguage
//
//  Created by Jiacheng Mao on 2025/1/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CollectionCreateView(viewModel: CollectionViewModel())
    }
}

#Preview {
    ContentView()
}
