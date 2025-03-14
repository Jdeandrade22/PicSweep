# PicSweep

A modern, cross-platform photo management application built with SwiftUI that helps users organize, secure, and analyze their photos using advanced AI capabilities.

## Features

### Photo Management
- Intuitive swipe-based interface for quick photo organization
- Smart photo categorization and tagging
- Cross-platform compatibility (iOS and macOS)
- Efficient batch processing capabilities

### AI-Powered Analysis
- Face detection and recognition
- Scene classification
- Object detection
- Text recognition in images
- Smart photo suggestions

### Security
- Private vault for sensitive photos
- Biometric authentication support
- End-to-end encryption
- Secure photo ownership verification
- Blockchain-based ownership records

### Cloud Integration
- iCloud sync support
- Efficient photo backup
- Cross-device synchronization
- Metadata preservation

## Requirements

### iOS
- iOS 14.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

### macOS
- macOS 11.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Jdeandrade22/PicSweep.git
```

2. Open the project in Xcode:
```bash
cd PicSweep
open Package.swift
```

3. Build and run the project in Xcode

## Architecture

PicSweep follows a modern SwiftUI architecture with:
- MVVM design pattern
- Combine for reactive programming
- Swift Package Manager for dependencies
- Feature-based module organization

### Key Components
- `PhotoManager`: Core photo management functionality
- `PhotoAnalyzer`: AI-powered photo analysis
- `PrivateVault`: Secure photo storage
- `CloudSync`: iCloud integration
- `PhotoOwnership`: Blockchain-based ownership tracking

## Testing

The project includes comprehensive unit tests covering:
- Photo management functionality
- AI analysis capabilities
- Security features
- Cloud sync operations
- Ownership verification

Run tests using:
```bash
swift test
```

## Recent Updates

- Added cross-platform image handling with `PlatformImage` type
- Improved CloudKit record compatibility
- Enhanced photo analysis with Vision framework
- Added secure photo ownership verification
- Fixed platform-specific image handling
- Improved test coverage and reliability

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## Support

For support, please open an issue in the GitHub repository or contact the development team.

---


