import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var mode: AuthMode = .login
    @State private var showOTP = false
    @State private var phoneNumber = ""
    @State private var otpCode = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var errorMessage: String?

    enum AuthMode {
        case login, register
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Logo/Title
                    VStack(spacing: 12) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.white)

                        Text("FaceApp")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Nightlife Verification")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    VStack(spacing: 20) {
                        if !showOTP {
                            // Mode picker — only visible on the form step
                            Picker("Mode", selection: $mode) {
                                Text("Login").tag(AuthMode.login)
                                Text("Register").tag(AuthMode.register)
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: mode) { _, _ in
                                errorMessage = nil
                            }

                            if mode == .register {
                                NameInputView(firstName: $firstName, lastName: $lastName)
                            }

                            PhoneInputView(phoneNumber: $phoneNumber)
                        } else {
                            OTPInputView(otpCode: $otpCode)
                        }

                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                        // Action button
                        Button(action: handleAction) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Text(buttonTitle)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(authManager.isLoading || !isFormValid)
                        .opacity(isFormValid ? 1 : 0.6)

                        if showOTP {
                            Button("Change Phone Number") {
                                withAnimation {
                                    showOTP = false
                                    otpCode = ""
                                    errorMessage = nil
                                }
                            }
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
        }
    }

    private var buttonTitle: String {
        if showOTP {
            return mode == .login ? "Verify & Login" : "Confirm Registration"
        } else {
            return "Send Code"
        }
    }

    private var isFormValid: Bool {
        let validPhone = phoneNumber.filter { $0.isNumber }.count == 9
        if showOTP {
            return otpCode.count == 6
        } else if mode == .register {
            return validPhone && !firstName.trimmingCharacters(in: .whitespaces).isEmpty
                               && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
        } else {
            return validPhone
        }
    }

    private func handleAction() {
        errorMessage = nil

        Task {
            do {
                if !showOTP {
                    if mode == .login {
                        try await authManager.login(phoneNumber: formatPhoneNumber())
                    } else {
                        try await authManager.register(
                            phoneNumber: formatPhoneNumber(),
                            firstName: firstName,
                            lastName: lastName
                        )
                    }
                    withAnimation { showOTP = true }
                } else {
                    if mode == .login {
                        try await authManager.confirmLogin(
                            phoneNumber: formatPhoneNumber(),
                            smsCode: otpCode
                        )
                    } else {
                        try await authManager.confirmRegistration(
                            phoneNumber: formatPhoneNumber(),
                            smsCode: otpCode
                        )
                    }
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func formatPhoneNumber() -> String {
        let digits = phoneNumber.filter { $0.isNumber }
        return "+995\(digits)"
    }
}

// MARK: - Phone Input View

struct PhoneInputView: View {
    @Binding var phoneNumber: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Phone Number")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 12) {
                Text("+995")
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                TextField("5XX XXX XXX", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: phoneNumber) { _, newValue in
                        phoneNumber = formatGeorgianInput(newValue)
                    }
            }
        }
    }

    private func formatGeorgianInput(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }.prefix(9)
        var result = ""
        for (i, digit) in digits.enumerated() {
            if i == 3 || i == 6 { result += " " }
            result.append(digit)
        }
        return result
    }
}

// MARK: - OTP Input View

struct OTPInputView: View {
    @Binding var otpCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter Verification Code")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            TextField("000000", text: $otpCode)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onChange(of: otpCode) { _, newValue in
                    if newValue.count > 6 {
                        otpCode = String(newValue.prefix(6))
                    }
                }

            Text("We sent a 6-digit code to your phone")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Name Input View

struct NameInputView: View {
    @Binding var firstName: String
    @Binding var lastName: String

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("First Name")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                TextField("John", text: $firstName)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Last Name")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                TextField("Doe", text: $lastName)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthManager())
}
