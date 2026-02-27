# FaceApp iOS

iOS client for the Nightlife Venue Verification Platform.

## Features

- **Phone Authentication**: Passwordless login with OTP verification
- **Profile Management**: Upload profile photo and ID card
- **Venue Discovery**: Browse venues and upcoming events
- **Approval Requests**: Request global or event-specific access
- **QR Code Passes**: View and present QR codes at venue entry

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

### Option 1: Using XcodeGen (Recommended)

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```

2. Generate the Xcode project:
   ```bash
   cd face-app-ios
   xcodegen generate
   ```

3. Open the project:
   ```bash
   open FaceApp.xcodeproj
   ```

### Option 2: Create Project Manually

1. Open Xcode and create a new iOS App project
2. Name it "FaceApp"
3. Copy all files from the `FaceApp` folder into your project
4. Update the Bundle Identifier to `com.faceapp.nightlife`

## Configuration

### API Base URL

Update the API base URL in `Services/APIConfig.swift`:

```swift
static let baseURL = "http://localhost:3000"  // Development
// static let baseURL = "https://api.yourserver.com"  // Production
```

For iOS Simulator connecting to localhost, use `http://localhost:3000`.
For physical device, use your machine's local IP address.

## Project Structure

```
FaceApp/
├── App/
│   ├── FaceAppApp.swift          # App entry point
│   ├── ContentView.swift         # Root view with auth routing
│   └── MainTabView.swift         # Main tab navigation
├── Models/
│   ├── User.swift                # User & auth models
│   ├── Venue.swift               # Venue model
│   ├── Event.swift               # Event model
│   └── Approval.swift            # Approval & QR models
├── Services/
│   ├── APIConfig.swift           # API configuration
│   ├── APIService.swift          # Network layer
│   ├── KeychainService.swift     # Secure token storage
│   ├── AuthManager.swift         # Authentication state
│   ├── VenueService.swift        # Venue operations
│   └── ApprovalService.swift     # Approval operations
├── Views/
│   ├── Auth/
│   │   └── AuthenticationView.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   └── EditProfileView.swift
│   ├── Venues/
│   │   ├── VenuesView.swift
│   │   └── VenueDetailView.swift
│   └── Approvals/
│       ├── ApprovalsView.swift
│       └── ApprovalDetailView.swift
├── Assets.xcassets/
└── Info.plist
```

## Architecture

- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: ViewModels manage state, Views render UI
- **Async/Await**: Modern Swift concurrency for network calls
- **Keychain**: Secure storage for JWT tokens
- **Core Image**: QR code generation

## Authentication Flow

1. User enters phone number
2. App requests OTP via `/api/v1/auth/request_otp`
3. User receives SMS with 6-digit code
4. User enters code
5. App verifies via `/api/v1/auth/login` or `/api/v1/auth/register`
6. Access token stored in Keychain
7. Token automatically included in authenticated requests

## Key Features

### Profile Verification
Users must upload:
- Profile photo
- Government-issued ID card

Before they can request venue access.

### Venue Access Types
- **Global Access**: Entry to all events that accept global passes
- **Event-Specific**: Entry to a specific event only

### QR Code Passes
- Generated server-side when approved
- Displayed as scannable QR code
- Single-use by default (marked as used after scan)

## Development

### Running with Backend

1. Start the Rails backend:
   ```bash
   cd ../face-app
   rails server
   ```

2. Run the iOS app in Simulator

### Testing

For development, OTP codes are logged to the Rails console when Twilio is not configured.

## License

MIT
