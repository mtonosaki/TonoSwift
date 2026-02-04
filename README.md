# TonoSwift

**TonoSwift** is a comprehensive Swift library designed to boost productivity by providing a collection of essential utilities for iOS and macOS development. It includes tools for cryptography, image processing, string manipulation, Japanese text handling, geometry calculations, and optimization algorithms.

## Features

### 🧠 Algorithms & Solvers
Advanced algorithmic solvers for optimization and distribution problems.

- **Traveling Salesperson Problem (TSP)**: Solve path optimization problems with customizable cost functions.
    - **Loop Resolver**: Finds the optimal path that returns to the starting point.
    - **Start-End Fixed Resolver**: Optimizes the path between a specific start and end node.
    - **Shuffle Resolver**: Finds a total optimized sequence without path constraints (reordering).
- **Goal Chasing Method (GCM) Distributer**: An algorithm for leveling or smoothing sequences based on frequency weights (often used in Heijunka/production leveling). It generates a sequence that distributes items as evenly as possible according to their specified counts.

### 🔐 Cryptography
- **AES-GCM Encryption**: Secure encryption and decryption using `CryptoKit`. Includes HKDF-based key derivation from string passwords with salt.
- **RSA Protocol**: Interfaces for RSA key management and operations.
- **Digital Envelope**: A hybrid encryption scheme that combines AES speed with RSA security. It encrypts the message payload with a randomly generated AES key, then encrypts that AES key with the recipient's RSA public key.

### 🖼️ Image Processing
- **Image Resizing**: Easily resize SwiftUI `Image` objects while obtaining the underlying PNG data. Supports both iOS (`UIImage`) and macOS (`NSImage`) backends.
- **Pixel Occupancy**: Algorithms for calculating pixel coverage, useful for anti-aliasing or graphical analysis.

### 🇯🇵 Japanese Text Support
- **Fuzzy Search Keys**: Generate normalized keys for Japanese text to facilitate fuzzy searching (ignores Hiragana/Katakana differences, long vowels, and minor character variations).
- **Indexing**: Helper to categorize strings into "Akasatana" (syllabary) rows for index bars.
- **Normalization**: Convert between Half-width and Full-width characters.

### 🛠️ Utilities
- **String Tools**: BASIC-style functions (`mid`, `left`, `right`), URL-safe Base64 conversion, UUID validation, and fuzzy boolean parsing.
- **Color Extensions**: Initialize SwiftUI `Color` from Hex strings (`#RRGGBB`, `#RGB`) and convert back to Hex.
- **Geometry**: Calculate Great-circle distance between coordinates (GeoEu).

## Usage Examples

### Algorithms: GCM Distributer (Heijunka)

Distribute items evenly based on their frequency.

```swift
import Tono

var gcm = GcmDistributer()
gcm.append("Apples", frequency: 2)
gcm.append("Oranges", frequency: 1)

// Iterates 3 times: likely "Apples", "Oranges", "Apples"
for item in gcm {
    print(item)
}
```

### Algorithms: TSP Solver

```swift
import Tono

class MyLocation: TspNode {
    let name: String
    let x: Double, y: Double
    init(_ name: String, x: Double, y: Double) { self.name = name; self.x = x; self.y = y }
}

class MyRouteSolver: TspResolverDelegate {
    func getTspCost(from: TspNode, to: TspNode, stage: TspCaluclationStage) -> Double {
        let p1 = from as! MyLocation
        let p2 = to as! MyLocation
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)) // Euclidean distance
    }
}

let locations = [
    MyLocation("A", x: 0, y: 0),
    MyLocation("B", x: 10, y: 10),
    MyLocation("C", x: 0, y: 10)
]

let solver = TspResolverLoop()
solver.delegate = MyRouteSolver()
let optimizedPath = solver.solve(data: locations)
```

### Digital Envelope (Hybrid Encryption)

Securely send a message to a recipient using their public key.

```swift
import Tono

// 1. Sender (Tomomi) seals a message for Recipient (Masahiko)
let masahikoPublicKey = try rsaMasahiko.getMyPublicKey() // Assume we have Masahiko's public key
let secretMessage = "Meet me at station at 5 PM."

let sealedEnvelope = try DigitalEnvelope.seal(
    plainText: secretMessage,
    recipientPublicKeyBase64: masahikoPublicKey
)
// 'sealedEnvelope' is now a Base64 string safe to transmit over open networks.

// 2. Recipient (Masahiko) opens the envelope using his private key
let openedMessage = try DigitalEnvelope.open(
    sealedString: sealedEnvelope,
    myRsa: rsaMasahiko // Masahiko's RSA instance with his private key
)

print(openedMessage) // Output: "Meet me at station at 5 PM."
```

### AES Encryption

```swift
import Tono
import CryptoKit

let password = "MySecretPassword"
let aes = Aes(password)

do {
    // Encrypt
    let secretText = "Hello, World!"
    let encryptedBase64 = try aes.encrypt(plainText: secretText)
    print("Encrypted: \(encryptedBase64)")

    // Decrypt
    let decryptedText = try aes.decrypt(base64String: encryptedBase64)
    print("Decrypted: \(decryptedText)")
} catch {
    print("Error: \(error)")
}
```

### Japanese Fuzzy Matching

```swift
import Tono

let jp = Japanese.def

// Generate a fuzzy key for searching
let key = jp.getKeyJp("セロファンテープ") 
// Output might be normalized to "セロハンテプ" for easier matching

// Get Index Row (Akasatana)
let indexChar = jp.getあかさたな("あいしてる") 
// Output: "ああさたら"
```

## Requirements

- iOS 13.0+
- macOS 10.15+
- Swift 5.5+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
