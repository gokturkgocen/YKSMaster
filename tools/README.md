# YKS Master - Question Uploader Tool 🚀

This tool allows you to upload questions to Firestore without modifying the application code. This keeps the APK light and allows you to update questions at any time.

## Setup Instructions

1.  **Prepare your questions**: Open `questions.json` and add your questions following the JSON structure provided in the template.
2.  **Navigate to the tools directory**:
    ```bash
    cd tools
    ```
3.  **Install dependencies**:
    ```bash
    dart pub get
    ```

## Usage

To upload questions, you need your Firebase **Project ID** and an **API Key**.

### 1. Get Project ID & API Key
- Go to [Firebase Console](https://console.firebase.google.com/).
- Project ID: Found in **Project Settings**.
- API Key: Found in **Project Settings -> Web API Key**.

### 2. Run the Uploader
```bash
dart run uploader.dart <PROJECT_ID> <API_KEY>
```

Example:
```bash
dart run uploader.dart yks-master-123 AIzaSyB-EXAMPLE-KEY
```

## Security Note
Make sure to keep your API Key private. This tool is intended for personal/admin use only.
