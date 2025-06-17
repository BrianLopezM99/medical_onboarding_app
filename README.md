¡Genial, Brian! Aquí tienes un `README.md` en inglés, **muy detallado**, ideal para incluir en tu repositorio de GitHub. Este archivo describe el propósito del proyecto, cómo está estructurado, cómo ejecutarlo, tecnologías utilizadas, y detalles del flujo de chat IA simulado.

---

```markdown
# 🦷 Medical Onboarding Assistant (Flutter Web)

This is a **technical test project** built using **Flutter Web** to simulate a **medical onboarding assistant**. The app provides a chat interface for support agents to interact with new clients and collect their medical documents through a guided conversation powered by a simulated AI assistant.

---

## ✨ Features

- ✅ Chat system with simulated encrypted messaging
- ✅ Simulated AI assistant that guides document collection
- ✅ File upload support with simulated data extraction
- ✅ Automatic response timing for realism (typing delays, read receipts)
- ✅ Persistent local storage for chat history (per customer)
- ✅ Clean Architecture using Riverpod for state management

---

## 📁 Project Structure (Clean Architecture)

```

lib/
├── core/
│   └── utils/               # Common utility classes
├── features/
│   ├── customer/            # Customer-related logic
│   ├── messaging/           # Chat and message flow
│   └── ai\_assistant/        # AI logic and prompts
├── shared/                  # Shared components/widgets
└── main.dart                # App entry point

````

---

## 🧠 AI Assistant Flow

The assistant collects documents in a specific **ordered flow**:

1. Insurance card
2. Medical report
3. COVID vaccine certificate
4. Allergy documentation
5. ID

Each step includes:

- Confirmation message (e.g., _“Thanks for the insurance card!”_)
- Next prompt (e.g., _“Please upload your medical report”_)

After the last step (`ID`), the assistant says:

> _"ID received. Registration is now complete."_

Then, the process **restarts automatically**, showing:

> _"Hello. Please upload your insurance card."_

---

## 📦 Tech Stack

- **Flutter Web** (latest stable)
- **Riverpod** – state management
- **Clean Architecture Lite** – domain/data separation
- **Local Storage** – simulated persistence
- **Responsive UI** – works in browser (desktop/mobile)
- **Fake AI logic** – rule-based prompt system

---

## 🚀 Getting Started

### 1. Requirements

- Flutter SDK (latest stable)  
- Dart >= 3.x  
- A browser (Chrome recommended)

### 2. Clone the Repo

```bash
git clone https://github.com/yourusername/medical-onboarding-assistant.git
cd medical-onboarding-assistant
````

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App (Web)

```bash
flutter run -d chrome
```

---

## 🧪 Simulated AI Logic

The assistant uses a simple function to generate replies and simulate data extraction:

* Based on file name and current prompt
* Each file uploaded produces a confirmation + next instruction
* JSON data is printed in chat from a simulated extraction

Example:

```json
{
  "insuranceProvider": "Blue Shield",
  "policyNumber": "1234567890",
  "groupNumber": "BSH123"
}
```

---

## 🧼 Code Highlights

### Message Sending (Text or File)

* Includes delays for:

  * Sending
  * Received
  * Read
* Triggers typing state while "AI" responds
* Response delays are randomized for realism

### State Management

* Each customer has isolated chat
* Messages are saved and retrieved using a simulated repository

---

## 🧊 Limitations

* No real backend (data is stored in memory or simulated locally)
* AI is rule-based, not powered by real ML models
* No authentication/login flow implemented

---

## 📄 License

This project is for technical demonstration purposes only and does not include a license for production use.

---

## 👤 Author

**Brian López**
Flutter Developer – Technical Test

