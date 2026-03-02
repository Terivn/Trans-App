# MarianMT Translator App

A Flutter translation application using HuggingFace's translation models (Opus-MT).

## Features

- Real-time text translation
- Support for multiple language pairs (English, Vietnamese, French, German)
- Translation history with persistence
- Swap language functionality
- Copy translated text to clipboard
- Dark mode support

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0+
- Dart 3.0.0+
- A HuggingFace API key (get it from [huggingface.co](https://huggingface.co/settings/tokens))

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd transappwithmarian
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Copy the `.env.example` file to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Open `.env` and add your HuggingFace API key:
     ```
     HUGGINGFACE_API_KEY=your_actual_api_key_here
     ```

4. **Run the app**
   ```bash
   flutter run --dart-define=HUGGINGFACE_API_KEY=$(grep HUGGINGFACE_API_KEY .env | cut -d '=' -f2)
   ```
   
   Or on Windows PowerShell:
   ```powershell
   $env:HUGGINGFACE_API_KEY = (Select-String -Path .\.env -Pattern 'HUGGINGFACE_API_KEY' | ForEach-Object { $_.Line.Split('=')[1] })
   flutter run --dart-define=HUGGINGFACE_API_KEY=$env:HUGGINGFACE_API_KEY
   ```

## Security Notes

- **Never commit the `.env` file** - it contains sensitive API keys
- The `.env` file is automatically excluded from git via `.gitignore`
- Always use environment variables for sensitive credentials
- Keep your HuggingFace API key private

## Supported Language Pairs

- English ↔ Vietnamese (en-vi, vi-en)
- English ↔ French (en-fr)
- English ↔ German (en-de)

## Architecture

- **Provider Pattern**: State management using the `provider` package
- **Clean Architecture**: Separation of concerns with services, models, and providers
- **Persistence**: Translation history saved to local storage using `shared_preferences`

## Dependencies

- `flutter`: Flutter SDK
- `provider`: State management
- `huggingface_client`: HuggingFace API client
- `shared_preferences`: Local persistence
- `intl`: Internationalization
- `http`: HTTP client

## For more help

- [Flutter Documentation](https://docs.flutter.dev/)
- [HuggingFace API Documentation](https://huggingface.co/docs/api-inference/quicktour)

