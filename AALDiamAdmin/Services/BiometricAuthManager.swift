import Foundation
import LocalAuthentication

public class BiometricAuthManager: ObservableObject {
    @Published public var isUnlocked: Bool = false
    @Published public var errorMessage: String? = nil

    public init() {}

    public func authenticate(completion: ((Bool) -> Void)? = nil) {
        let context = LAContext()
        var error: NSError?

        let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics

        if context.canEvaluatePolicy(policy, error: &error) {
            let reason = "Verify your Face ID or Touch ID to access the AALDiam Superadmin Vault"

            context.evaluatePolicy(policy, localizedReason: reason) { [weak self] success, evalError in
                DispatchQueue.main.async {
                    if success {
                        self?.isUnlocked = true
                        self?.errorMessage = nil
                        completion?(true)
                    } else {
                        // Fallback to device PIN
                        self?.authenticateWithPasscode(completion: completion)
                    }
                }
            }
        } else {
            // Biometrics not enrolled on device; fallback to passcode
            authenticateWithPasscode(completion: completion)
        }
    }

    private func authenticateWithPasscode(completion: ((Bool) -> Void)? = nil) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter device passcode to unlock Vault") { [weak self] success, evalError in
                DispatchQueue.main.async {
                    self?.isUnlocked = success
                    self?.errorMessage = success ? nil : evalError?.localizedDescription
                    completion?(success)
                }
            }
        } else {
            // Device has no lock code at all: allow pass-through
            DispatchQueue.main.async {
                self.isUnlocked = true
                completion?(true)
            }
        }
    }
}
