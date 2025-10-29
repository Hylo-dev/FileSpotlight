//
//  Mock.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI
// MARK: - Preview con Mock Data

private func shortcutRow(icon: String, text: String) -> some View {
	HStack(spacing: 12) {
		Image(systemName: icon)
			.frame(width: 20)
			.foregroundColor(.white.opacity(0.6))
		Text(text)
			.font(.subheadline)
			.foregroundColor(.white.opacity(0.8))
	}
}

// MARK: - Preview Multi-Section

#Preview("Multi-Section Spotlight") {
	let viewModelSpotlight = MultiSectionSpotlightViewModel<SpotlightFileItem>(
		dataSource: FileSystemDataSource(
			directory: URL(fileURLWithPath: "/Users/eliorodr2104/Downloads"),
			fileExtensions: ["pdf"],
		),
		sections: [
			SpotlightSection(
				id: "recent",
				title: "Recent Files",
				icon: "clock",
				view	: { Text("Test 0") },
				onSelect: { file in
					print("Selected recent: \(file.displayName)")
				}
			),
			
			SpotlightSection(
				id: "favorites",
				title: "Favorites",
				icon: "star.fill",
				view	: { Text("Test 1") },
				onSelect: { file in
					print("Selected favorite: \(file.displayName)")
				}
			)
		]
	)
	
	ZStack {
		Color.black
			.ignoresSafeArea()
		
		VStack(spacing: 30) {
			Text("Multi-Section Spotlight")
				.font(.largeTitle)
				.fontWeight(.bold)
			
			Text("Browse by sections or search across all items")
				.font(.subheadline)
				.foregroundColor(.secondary)
			
			MultiSectionSpotlightView(viewModel: viewModelSpotlight, width: 650)
				.clipShape(.rect(cornerRadius: 20))
			
			Spacer()
		}
		.padding(.top, 80)
	}
	.frame(width: 900, height: 700)
}

// MARK: - Preview Compact Style

#Preview("Compact Style") {
	@Previewable @StateObject var viewModel = {
		let dataSource = FileSystemDataSource(
			directory: URL(fileURLWithPath: "/Users/eliorodr2104/Downloads"),
			fileExtensions: ["pdf"]
		)
		
		let vm = FileSearchSpotlightViewModel<SpotlightFileItem>(
			dataSource: dataSource,
			configuration: .init(
				debounceInterval: 100,
				maxHeight: 250
			),
			rowStyle: .init(
				backgroundColor: { selected in
					selected ? Color.purple.opacity(0.2) : Color.clear
				},
				cornerRadius: 6,
				padding: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
				spacing: 10,
				iconSize: 22
			)
		)
		
		return vm
	}()
	
	ZStack {
		LinearGradient(
			colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
		.ignoresSafeArea()
		
		VStack {
			Text("Compact Spotlight")
				.font(.title2)
				.fontWeight(.semibold)
			
			FileSearchSpotlightView(viewModel: viewModel, width: 450)
				.padding(.top, 20)
				.clipShape(.rect(cornerRadius: 12))
			
			Spacer()
		}
		.padding(.top, 100)
	}
	.frame(width: 600, height: 500)
}
