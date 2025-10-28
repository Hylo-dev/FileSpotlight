//
//  Mock.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

// MARK: - Mock Data Source per Preview

struct MockFileDataSource: SpotlightDataSource {
	func allItems() async -> [SpotlightFileItem] {
		return mockFiles
	}
	
	func search(query: String) async -> [SpotlightFileItem] {
		guard !query.isEmpty else { return [] }
		return mockFiles.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
	}
	
	private var mockFiles: [SpotlightFileItem] {
		[
			SpotlightFileItem(
				name: "Cap_01_compressed.pdf",
				subtitle: "/Users/eliorodr2104/Downloads",
				icon: .systemImage("doc.text")
			)
		]
	}
}

// MARK: - Preview con Mock Data

#Preview("Spotlight with Mock Data") {
	@Previewable @StateObject var viewModel = {
		let vm = SpotlightViewModel<SpotlightFileItem>(
			dataSource: MockFileDataSource(),
			configuration: .init(
				placeholder: "Search files...",
				searchIcon: "magnifyingglass",
				debounceInterval: 150,
				maxHeight: 400,
				cornerRadius: 24,
				showDividers: true
			),
			rowStyle: .init(
				backgroundColor: { selected in
					selected ? Color.accentColor.opacity(0.2) : Color.clear
				},
				cornerRadius: 10,
				iconSize: 28
			)
		)
		return vm
	}()
	
	ZStack {
		// Background gradient
		LinearGradient(
			colors: [
				Color(red: 0.1, green: 0.1, blue: 0.2),
				Color(red: 0.2, green: 0.1, blue: 0.3)
			],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
		.ignoresSafeArea()
		
		VStack(spacing: 20) {
			Text("SpotlightKit Demo")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundColor(.white)
			
			Text("Try searching: 'View', 'Swift', 'README'")
				.font(.subheadline)
				.foregroundColor(.white.opacity(0.7))
			
			SpotlightView(viewModel: viewModel, width: 600)
				.padding(.top, 20)
			
			Spacer()
			
			// Info panel
			VStack(alignment: .leading, spacing: 8) {
				HStack {
					Image(systemName: "keyboard")
						.foregroundColor(.white.opacity(0.7))
					Text("Keyboard Shortcuts:")
						.font(.headline)
						.foregroundColor(.white)
				}
				
				Group {
					shortcutRow(icon: "arrow.up", text: "Navigate Up")
					shortcutRow(icon: "arrow.down", text: "Navigate Down")
					shortcutRow(icon: "return", text: "Select Item")
					shortcutRow(icon: "escape", text: "Clear/Reset")
				}
			}
			.padding()
			.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
			.padding(.horizontal, 40)
			.padding(.bottom, 40)
		}
		.padding(.top, 60)
	}
	.frame(width: 900, height: 700)
}

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
	@Previewable @StateObject var viewModel = {
		let vm = SpotlightViewModel<SpotlightFileItem>(
			configuration: .init(
				placeholder: "Search everywhere...",
				cornerRadius: 20
			)
		)
		
		// Recent files section
		vm.addSection(
			SpotlightSection(
				id: "recent",
				title: "Recent Files",
				icon: "clock",
				items: {
					[
						SpotlightFileItem(
							name: "MainView.swift",
							subtitle: "Opened 2 minutes ago",
							icon: .systemImage("doc.text.fill")
						),
						SpotlightFileItem(
							name: "Settings.swift",
							subtitle: "Opened 1 hour ago",
							icon: .systemImage("gearshape")
						)
					]
				},
				onSelect: { file in
					print("Selected recent: \(file.displayName)")
				}
			)
		)
		
		// Favorites section
		vm.addSection(
			SpotlightSection(
				id: "favorites",
				title: "Favorites",
				icon: "star.fill",
				items: {
					[
						SpotlightFileItem(
							name: "AppCore.swift",
							subtitle: "Core functionality",
							icon: .systemImage("star.fill")
						),
						SpotlightFileItem(
							name: "Utils.swift",
							subtitle: "Utility functions",
							icon: .systemImage("star.fill")
						),
						SpotlightFileItem(
							name: "Constants.swift",
							subtitle: "App constants",
							icon: .systemImage("star.fill")
						)
					]
				},
				onSelect: { file in
					print("Selected favorite: \(file.displayName)")
				}
			)
		)
		
		return vm
	}()
	
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
			
			MultiSectionSpotlightView(viewModel: viewModel, width: 650)
			
			Spacer()
		}
		.padding(.top, 80)
	}
	.frame(width: 900, height: 700)
}

// MARK: - Preview Custom Commands

struct CommandItem: SpotlightItem {
	let id = UUID()
	let displayName: String
	let subtitle: String?
	let iconProvider: SpotlightIconProvider
	let action: @Sendable () -> Void
	
	init(name: String, subtitle: String, icon: String, action: @Sendable @escaping () -> Void = {}) {
		self.displayName = name
		self.subtitle = subtitle
		self.iconProvider = .systemImage(icon)
		self.action = action
	}
	
	static func == (lhs: CommandItem, rhs: CommandItem) -> Bool {
		lhs.id == rhs.id
	}
}

struct MockCommandDataSource: SpotlightDataSource {
	func allItems() async -> [CommandItem] {
		return commands
	}
	
	func search(query: String) async -> [CommandItem] {
		guard !query.isEmpty else { return [] }
		return commands.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
	}
	
	private var commands: [CommandItem] {
		[
			CommandItem(
				name: "New File",
				subtitle: "Create a new file in current directory",
				icon: "doc.badge.plus",
				action: { print("Creating new file") }
			),
			CommandItem(
				name: "Open Settings",
				subtitle: "Configure application preferences",
				icon: "gearshape.fill",
				action: { print("Opening settings") }
			),
			CommandItem(
				name: "Toggle Theme",
				subtitle: "Switch between light and dark mode",
				icon: "moon.stars.fill",
				action: { print("Toggling theme") }
			),
			CommandItem(
				name: "Run Build",
				subtitle: "Compile and build the project",
				icon: "hammer.fill",
				action: { print("Building project") }
			),
			CommandItem(
				name: "Search Files",
				subtitle: "Find files in project",
				icon: "magnifyingglass",
				action: { print("Searching files") }
			),
			CommandItem(
				name: "Git Commit",
				subtitle: "Commit current changes",
				icon: "arrow.triangle.branch",
				action: { print("Committing changes") }
			),
			CommandItem(
				name: "Terminal",
				subtitle: "Open integrated terminal",
				icon: "terminal.fill",
				action: { print("Opening terminal") }
			)
		]
	}
}

#Preview("Command Palette") {
	@Previewable @StateObject var viewModel = {
		let vm = SpotlightViewModel<CommandItem>(
			dataSource: MockCommandDataSource(),
			configuration: .init(
				placeholder: "Type a command...",
				searchIcon: "command",
				maxHeight: 450, cornerRadius: 16
			),
			rowStyle: .init(
				backgroundColor: { selected in
					selected ? Color.blue.opacity(0.15) : Color.clear
				},
				textColor: .primary,
				subtitleColor: .secondary,
				cornerRadius: 8,
				iconSize: 24
			)
		)
		return vm
	}()
	
	ZStack {
		// Dark background
		Color.black
			.ignoresSafeArea()
		
		VStack(spacing: 25) {
			HStack(spacing: 15) {
				Image(systemName: "command.circle.fill")
					.font(.system(size: 50))
					.foregroundColor(.blue)
				
				VStack(alignment: .leading, spacing: 4) {
					Text("Command Palette")
						.font(.title)
						.fontWeight(.bold)
						.foregroundColor(.white)
					
					Text("Quick access to all commands")
						.font(.subheadline)
						.foregroundColor(.white.opacity(0.7))
				}
			}
			
			SpotlightView(viewModel: viewModel, width: 600)
			
			Spacer()
		}
		.padding(.top, 80)
	}
	.frame(width: 900, height: 700)
}

// MARK: - Preview Compact Style

#Preview("Compact Style") {
	@Previewable @StateObject var viewModel = {
		let vm = SpotlightViewModel<SpotlightFileItem>(
			dataSource: MockFileDataSource(),
			configuration: .init(
				placeholder: "Quick search...",
				searchIcon: "sparkle.magnifyingglass",
				debounceInterval: 100,
				maxHeight: 250,
				cornerRadius: 12
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
			
			SpotlightView(viewModel: viewModel, width: 450)
				.padding(.top, 20)
			
			Spacer()
		}
		.padding(.top, 100)
	}
	.frame(width: 600, height: 500)
}
