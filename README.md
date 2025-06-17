
```markdown
# 🩺 Medical Onboarding Chat App (Flutter Web)

This is a **Flutter Web** application built as part of a technical assessment. It simulates a medical onboarding assistant that guides users (patients) through a step-by-step document collection process using a chat interface.

---

## ✨ Features

- 📄 Document-based conversation flow
- 🧠 AI-like assistant with scripted responses
- 📦 File upload simulation (insurance card, medical report, ID, etc.)
- 📥 Local message persistence (simulated backend)
- 💬 Typing indicator
- ✅ Clean Architecture Lite with Riverpod for state management

---

## 📁 Project Structure

```

lib/
├── app/                  # App-level config (routes, themes)
├── core/                 # Shared core utils and base classes
├── features/
│   ├── chat/             # Chat assistant module
│   │   ├── data/         # Simulated API + model
│   │   ├── domain/       # Entity, use case, repository
│   │   ├── presentation/ # UI widgets and screens
│   │   └── application/  # Riverpod notifiers and logic
│   └── customer/         # Customer management (if needed)

````

---

## 🧠 AI Simulation Behavior

The chat assistant walks the user through this document request flow:

1. Insurance card  
2. Medical report  
3. COVID vaccine certificate  
4. Allergy documentation  
5. Official ID

Each uploaded file triggers:
- A confirmation response
- A simulated data extraction in JSON
- The next document request

At the end, it restarts the loop with a welcome prompt again.

---

## 🧪 Run the App Locally

```bash
flutter pub get
flutter run -d chrome
````

To build for web:

```bash
flutter build web
```

---

## 🚀 Deploy to Netlify

1. Run:

   ```bash
   flutter build web
   ```

2. Go to: [https://app.netlify.com/drop](https://app.netlify.com/drop)

3. Drag the `build/web` folder into the browser.

### Optional: Set up with GitHub

You can also connect the repo with Netlify and use:

* **Build command:** `flutter build web`
* **Publish directory:** `build/web`

> For single-page app routing, add a `_redirects` file with:
>
> ```
> /* /index.html 200
> ```

---

## 🙋‍♂️ About the Author

This project was built by **Brian López** as part of a technical assessment.
The main goal was to create a clear and structured medical onboarding chatbot UI using Flutter Web and Clean Architecture principles.

---

## 🧠 AI-Assisted Notes

AI assistance was used primarily for:

* Building the **basic layout** of the app (containers, styles, buttons)
* Improving the **structure and readability** of this `README.md`

⚠️ No functional code or business logic was written by the AI. All architecture, logic, and app behavior were implemented manually.

---

## 📸 Screenshots

*(Add screenshots here if needed)*

---

## 📜 License

This project is for demonstration and evaluation purposes only.

```