# 🤖 AI Туслагч — Тайлбар Material

## Төслийн нэр
**SportBet MN** — Монголын спортын бооцооны платформ + AI туслагч

## Шинэ функц
Google **Gemini 2.5 Flash AI**-г сайтад интеграц хийж, хэрэглэгч асуулт асуух, тоглолтын дүн шинжилгээ авах боломжтой болгосон.

## Технологийн стэк
| Хэсэг | Технологи |
|---|---|
| Frontend | Flutter (Dart), Provider state mgmt |
| Backend | Python Flask, REST API |
| AI Model | Google Gemini 2.5 Flash (үнэгүй tier) |
| Deployment | Render.com (auto-deploy from GitHub) |
| Сайт | https://sportbet-mn.onrender.com |

---

## Архитектур

```
┌─────────────────────┐         ┌─────────────────────┐         ┌──────────────────┐
│  Flutter Web App    │ ───────>│   Flask Backend     │ ───────>│  Gemini API      │
│  (Хэрэглэгч UI)     │  HTTP   │   (server.py)       │  HTTPS  │  (Google AI)     │
│                     │ <───────│                     │ <───────│                  │
└─────────────────────┘  JSON   └─────────────────────┘  JSON   └──────────────────┘
       │                              │
       │  AI Chat Screen              │  /api/ai/chat
       │  Match Cards (AI товч)       │  /api/ai/analyze
       │                              │  /api/ai/status
```

---

## Шинээр бичсэн/өөрчилсөн файлууд

### Backend (Python)

**`backend/server.py`** — Гол серверийн файл. Дараах endpoint-ууд нэмсэн:

| Endpoint | Method | Үүрэг |
|---|---|---|
| `/api/ai/chat` | POST | AI-тай яриа өрнүүлэх |
| `/api/ai/analyze` | POST | Тоглолтын дүн шинжилгээ |
| `/api/ai/status` | GET | AI тохиргоо шалгах |
| `/api/ai/models` | GET | Боломжтой Gemini model-уудыг харах |

**Гол логик** (`server.py` доторх AI хэсэг):

```python
# Орчны хувьсагчаас API key унших
GEMINI_KEY = os.environ.get("GEMINI_API_KEY", "")

@app.route("/api/ai/chat", methods=["POST"])
def ai_chat():
    data = request.get_json()
    messages = data.get("messages", [])
    
    # Gemini API руу хүсэлт илгээх
    r = requests.post(
        f"https://generativelanguage.googleapis.com/v1beta/"
        f"models/gemini-2.5-flash:generateContent?key={GEMINI_KEY}",
        json={
            "contents": [...],
            "systemInstruction": {"parts": [{"text": _AI_SYSTEM}]},
        }
    )
    return jsonify({"reply": r.json()["candidates"][0]["content"]["parts"][0]["text"]})
```

### Frontend (Flutter/Dart)

**`lib/screens/ai_chat_screen.dart`** — AI чат дэлгэц (шинэ файл)
- Хэрэглэгчийн мессеж/AI хариулт харуулах
- "Бичиж байна..." анимац
- Чат түүх хадгалах

**`lib/services/api_service.dart`** — API дуудлагын функцууд
- `aiChat(messages)` — AI чат API дуудах
- `aiAnalyze(event)` — Тоглолтын дүн шинжилгээ хүсэх

**`lib/widgets/match_card.dart`** — Тоглолтын card дээр `🤖 AI` товч нэмсэн
- Дарахад тухайн тоглолтын дүн шинжилгээг харуулна

**`lib/widgets/top_bar.dart`** — Дээд навигацид **🤖 AI** tab нэмсэн

**`lib/screens/app_shell.dart`** — Page 11 (AI Chat) роутинг нэмсэн

---

## Хэрхэн ажилладаг вэ?

### 1. Хэрэглэгч AI tab дарна
→ AiChatScreen нээгдэнэ → "Сайн байна уу" гэсэн мэндчилгээ харагдана

### 2. Асуулт бичнэ
Жишээ: `"manchester city bagiin medeelel"`

### 3. Frontend → Backend
```dart
ApiService.aiChat([{"role": "user", "content": "manchester city bagiin medeelel"}])
```

### 4. Backend → Gemini API
- System prompt: "Та SportBet MN-ийн AI туслагч..."
- User message: "manchester city bagiin medeelel"

### 5. Gemini хариулт буцаана
Real, дэлгэрэнгүй хариулт: багийн нэр, стадион, тоглогчид, аварга цолууд гэх мэт

### 6. Frontend хариултыг харуулна

---

## Онцлог боломжууд

✅ **Олон хэлээр** — Кирилл монгол, латин монгол (transliteration), Англи
✅ **Бодит мэдээлэл** — Тоглолтын статистик, багуудын мэдээлэл
✅ **Тоглолт-тусгай дүн шинжилгээ** — Тоглолт дээр AI товчоор шинжилгээ авах
✅ **Олон model fallback** — `gemini-2.5-flash` → `gemini-2.0-flash` → `gemini-flash-latest`
✅ **Demo mode** — API key байхгүй бол урьдчилан бичсэн хариулт өгнө
✅ **Аюулгүй байдал** — API key орчны хувьсагчид хадгалагдана, код дотор биш

---

## Аюулгүй байдлын зарчмууд

1. **API key never in code** — `.env` файл болон Render environment variables-д хадгалагдсан
2. **`.gitignore`-д `.env`** — GitHub руу key хэзээ ч push хийгдэхгүй
3. **Error sanitization** — Алдааны мэдэгдэлд URL/key илчлэгдэхгүй
4. **HTTPS only** — Бүх API дуудлага HTTPS ашигладаг

---

## Git commits (өөрчлөлтийн түүх)

```bash
git log --oneline
3634afd Use Gemini 2.5/2.0 models (1.5 deprecated)
c0000f5 Add /api/ai/models to debug + try more model names
e8dcb42 Add multi-model Gemini fallback + rich team info in demo mode
e136d27 Fix Gemini 400 error: skip leading assistant welcome message
d3ef5d7 Sanitize AI error messages to prevent API key leakage
1ff5f04 Bump version to v3-bugfix to track deploy
6643007 Fix bug: Gemini/Groq were never used because Anthropic check came first
e9a837f Add /api/ai/status endpoint to debug AI config
76eb404 AI understands transliterated Mongolian (Latin script)
c89e77c Add Google Gemini support (free tier priority)
425d1f0 Add AI chat feature with Groq (free) + Claude support
```

---

## Хэрхэн ажиллуулах (Demo)

### Локал орчинд
```powershell
cd C:\Users\hitech\OneDrive\Desktop\sportbet-mn-master\sportbet-mn-master
python backend/server.py
# Браузерт http://localhost:3001 нээх
```

### Production (Live)
🌐 **https://sportbet-mn.onrender.com** — AI tab дээр шууд туршаарай

---

## Үр дүн
- ✅ Бүрэн ажиллагаатай AI чат
- ✅ Спортын тусгайлсан системд AI интеграц хийсэн
- ✅ Cloud деплой (Render.com)
- ✅ Олон хэлний дэмжлэг
- ✅ Хэрэглэгчийн UX-д сайжруулалт (товч, дэлгэц, чатын анимац)
