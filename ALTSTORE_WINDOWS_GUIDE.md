# How to Sideload AALDiam Admin on iPhone Using Windows (No Mac Required)

This guide walks you through installing the native AALDiam Admin application onto your iPhone using your **Windows PC** and **AltServer** with a free Apple ID.

---

## Prerequisites (One-Time Setup on Windows PC)

1. **Download and Install Apple iTunes (Windows 64-bit)**:
   - *Note: Do NOT install from the Microsoft Store. Apple's driver files are only present in the direct installer.*
   - Direct Download: [iTunes 64-bit Direct Installer](https://www.apple.com/itunes/download/win64)
2. **Download and Install Apple iCloud (Windows direct installer)**:
   - Direct Download: [iCloud Direct Installer](https://updates.cdn-apple.com/2020/windows/001-39935-20200911-1A70AA56-F448-11EA-8109-814808226C72/iCloudSetup.exe)
   - Open iCloud and sign in with your Apple ID.
3. **Download and Install AltServer for Windows**:
   - Download from: [altstore.io](https://altstore.io)
   - Extract the `.zip` and run `setup.exe`.

---

## Step 1: Install AltStore on Your iPhone

1. Plug your iPhone into your Windows PC using your normal USB charging cable.
2. If prompted on your iPhone, tap **"Trust This Computer"** and enter your iPhone passcode.
3. In iTunes on your PC, make sure your iPhone shows up, and check the box **"Sync with this iPhone over Wi-Fi"**.
4. In your Windows taskbar (bottom-right notification icons, near the clock), find the diamond-shaped **AltServer** icon.
5. Click **AltServer ➔ Install AltStore ➔ [Your iPhone's Name]**.
6. Enter your personal Apple ID email and password when prompted. (This is sent directly to Apple's servers to generate a free 7-day developer certificate).
7. In ~30 seconds, the **AltStore** icon will appear on your iPhone home screen!

---

## Step 2: Trust the Certificate on Your iPhone

Before opening AltStore for the first time:
1. On your iPhone, open **Settings**.
2. Go to **General ➔ VPN & Device Management**.
3. Under *Developer App*, tap your Apple ID email.
4. Tap **"Trust [Your Email]"**, then tap **Trust** again to confirm.
5. On iOS 16+, go to **Settings ➔ Privacy & Security ➔ Developer Mode** and toggle it **ON** (the iPhone will restart once to activate Developer Mode).

---

## Step 3: Install AALDiam Admin (`aaldiam-admin.ipa`)

> [!WARNING]
> ### ⚠️ If AltStore Asks to "Submit the Application" — DO NOT SUBMIT!
> If you see a prompt or link asking to **"Submit Application"** or **"Submit Source to AltStore"**, this is AltStore's public directory system for open-source public apps.
> **AALDiam Admin is a private enterprise application. You do NOT submit it to AltStore.**
> Submitting it would make your superadmin tool public or wait for AltStore team review. Follow the private sideloading steps below:

### Method A: Direct Sideloading via the "+" Button (Recommended)
1. On your iPhone, download the IPA file from your server:
   👉 **`https://aaldiam.com/download/aaldiam-admin.ipa`** (saves into your iPhone **Files** app).
2. Open the **AltStore** app on your iPhone.
3. Tap the **My Apps** tab at the bottom (do *not* tap "Browse" or "Sources").
4. Tap the **'+'** icon in the **top-left corner**.
5. Select the downloaded `aaldiam-admin.ipa` from your Files.
6. AltStore will sign and install the app with your personal Apple ID!
7. **AALDiam Vault** is now installed natively on your iPhone Home Screen with hardware Face ID unlock and native Camera integration.

### Method B: Add Our Private AltStore Source (1-Tap Install)
If you prefer installing directly from an in-app catalog without manually picking files:
1. In AltStore on your iPhone, tap the **Sources** tab.
2. Tap the **'+'** icon in the top-right corner.
3. Enter our private enterprise source URL:
   👉 **`https://aaldiam.com/altstore-source.json`**
   *(Or tap this direct link in iPhone Safari: `altstore://source?url=https://aaldiam.com/altstore-source.json`)*
4. Tap **Add**.
5. **AALDiam Enterprise** will appear in your private sources list with a direct **FREE / INSTALL** button for **AALDiam Admin**. Tap **INSTALL**!
6. Zero submission required!

---

## Step 4: Wireless Refreshing via SideStore (Never Use PC Again)

Free Apple IDs have a 7-day certificate validity period. To avoid having to plug into your Windows PC once a week:
1. Inside AltStore, sideload **SideStore** ([sidestore.io](https://sidestore.io)).
2. SideStore creates a local, on-device WireGuard loopback VPN profile on your iPhone.
3. This allows your iPhone to refresh its own certificates **wirelessly over Wi-Fi or cellular data** anywhere in the world, without ever needing to connect to your PC again.
