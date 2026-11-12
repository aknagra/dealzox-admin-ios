import SwiftUI

public struct PinView: View {
    @Binding public var isAuthenticated: Bool
    @State private var pin: String = ""
    @State private var showError = false
    @State private var attempts = 0
    private let correctPin = "8034"

    public init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
    }

    public var body: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)

                Text("DealZox Admin")
                    .font(.system(size: 28, weight: .bold))

                Text("Enter 4-digit Admin PIN to continue")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // PIN Dots
            HStack(spacing: 16) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(index < pin.count ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.vertical, 10)

            if showError {
                Text("Invalid PIN! Please try again.")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Spacer()

            // Keypad
            VStack(spacing: 16) {
                ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { row in
                    HStack(spacing: 24) {
                        ForEach(row, id: \.self) { num in
                            Button(action: { appendDigit("\(num)") }) {
                                Text("\(num)")
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .frame(width: 72, height: 72)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }

                HStack(spacing: 24) {
                    Spacer().frame(width: 72, height: 72)

                    Button(action: { appendDigit("0") }) {
                        Text("0")
                            .font(.title)
                            .fontWeight(.medium)
                            .frame(width: 72, height: 72)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }

                    Button(action: { deleteDigit() }) {
                        Image(systemName: "delete.backward")
                            .font(.title2)
                            .frame(width: 72, height: 72)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .padding()
    }

    private func appendDigit(_ digit: String) {
        guard pin.count < 4 else { return }
        pin.append(digit)
        showError = false

        if pin.count == 4 {
            verifyPin()
        }
    }

    private func deleteDigit() {
        if !pin.isEmpty {
            pin.removeLast()
            showError = false
        }
    }

    private func verifyPin() {
        if pin == correctPin {
            withAnimation {
                isAuthenticated = true
            }
        } else {
            showError = true
            attempts += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                pin = ""
            }
        }
    }
}
