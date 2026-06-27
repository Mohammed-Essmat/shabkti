# Shabakti (شبكتي) — Complete UI/UX Design Prompt

---

## App Overview

**Shabakti** is an Arabic mobile app for managing internet data package subscriptions.
Users can register, browse packages, pay, track data usage, and add beneficiaries
who share the same subscription.

- Platform: Mobile (iOS & Android)
- Language: Arabic (RTL — Right-to-Left layout)
- Design System: Material Design 3
- Modes: Light Mode + Dark Mode (identical layout, only colors change)

---

## Design Tokens

### Light Mode Colors

```
background:           #f8f9ff
surface:              #f8f9ff
surface-container:    #e5eeff
surface-container-low:  #eff4ff
surface-container-high: #dce9ff
card-background:      #ffffff
on-surface (text):    #0b1c30
on-surface-variant:   #434655
primary:              #004ac6
primary-container:    #2563eb
on-primary:           #ffffff
on-primary-container: #eeefff
secondary:            #5c5f61
on-secondary:         #ffffff
secondary-container:  #e0e3e5
tertiary:             #515659
error:                #ba1a1a
on-error:             #ffffff
error-container:      #ffdad6
outline:              #737686
outline-variant:      #c3c6d7
success:              #22c55e
warning:              #f59e0b
```

### Dark Mode Colors

```
background:           #0b1326
surface:              #0b1326
surface-container:    #171f33
surface-container-low:  #131b2e
surface-container-high: #222a3d
card-background:      #222a3d
on-surface (text):    #dae2fd
on-surface-variant:   #c2c6d6
primary:              #adc6ff
primary-container:    #4d8eff
on-primary:           #002e6a
on-primary-container: #00285d
secondary:            #b7c8e1
on-secondary:         #213145
secondary-container:  #3a4a5f
tertiary:             #ffb786
error:                #ffb4ab
on-error:             #690005
error-container:      #93000a
outline:              #8c909f
outline-variant:      #424754
success:              #4ade80
warning:              #fbbf24
```

### Typography

```
Font Family: Inter (fallback: system sans-serif)

display-large:   48px / 700 / 56px line-height / -0.02em spacing
headline-large:  32px / 700 / 40px line-height / -0.01em spacing
headline-medium: 24px / 600 / 32px line-height
title-large:     20px / 600 / 28px line-height
body-large:      16px / 400 / 24px line-height
body-medium:     14px / 400 / 20px line-height
label-large:     14px / 500 / 20px line-height / 0.1px spacing
label-small:     11px / 500 / 16px line-height / 0.5px spacing
```

### Spacing (8px base unit)

```
xs:  4px
sm:  8px
md:  16px
lg:  24px
xl:  32px
screen-padding: 16px (horizontal margins)
```

### Shapes

```
small:    4px  radius (chips, badges)
default:  8px  radius (buttons, inputs)
medium:  12px  radius (cards, containers)
large:   16px  radius (modals, bottom sheets)
xl:      24px  radius (large containers)
full:    9999px (avatars, circular progress)
```

### Component Specs

```
Button height:     48-56px, full width, 12px radius
Input field:       48px height, 12px radius, light background fill
Cards:             white/dark surface, 12px radius, soft shadow (light) or 1px border 10% white (dark)
Bottom nav:        white/dark surface, 3 items, active = tonal pill background
Touch targets:     minimum 48x48px
Avatar:            circular, 40px (list) / 80px (profile)
Status badges:     pill shape, 15% opacity colored background
```

---

## Screen-by-Screen Specification

### IMPORTANT RULES:
- Every screen must be designed in BOTH Light Mode and Dark Mode
- All text is Arabic, right-aligned (RTL layout)
- Back arrows point RIGHT (→) not left
- Progress bars fill from RIGHT to LEFT
- Navigation and reading direction: RIGHT to LEFT

---

### Screen 1: Splash Screen

```
Layout:
┌─────────────────────────┐
│                         │
│                         │
│                         │
│       [App Logo]        │
│       "شبكتي"           │
│                         │
│                         │
│    [Loading spinner]    │
│                         │
└─────────────────────────┘

- Background: gradient from primary to primary-container
- Logo: centered, large (120px)
- App name below logo in display-large, white
- Circular loading indicator at bottom, white
- No navigation bars
```

---

### Screen 2: Login Screen

```
Layout:
┌─────────────────────────┐
│                         │
│       [App Logo]        │
│       "شبكتي"           │
│                         │
│  ┌───────────────────┐  │
│  │ البريد الإلكتروني │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ كلمة السر     👁  │  │
│  └───────────────────┘  │
│                         │
│  "نسيت كلمة السر؟"      │
│                         │
│  ┌───────────────────┐  │
│  │  تسجيل الدخول     │  │ ← Primary button
│  └───────────────────┘  │
│                         │
│  "ليس لديك حساب؟        │
│   إنشاء حساب جديد"      │ ← Text link, primary color
│                         │
└─────────────────────────┘

- Logo at top (80px), smaller than splash
- Email input: keyboard type = email
- Password input: obscured + show/hide toggle icon
- "نسيت كلمة السر؟" link aligned right (RTL)
- Primary button full width
- Register link at bottom, centered
```

---

### Screen 3: Registration — Step 1 (Personal Info)

```
Layout:
┌─────────────────────────┐
│  →                      │ ← Back button (right side for RTL)
│                         │
│  ■ ■ ■ ○ ○ ○ ○ ○ ○     │ ← Progress: step 1 of 3 (fills right to left)
│  "الخطوة 1 من 3"        │
│                         │
│  "البيانات الشخصية"      │ ← headline-medium
│                         │
│  ┌───────────────────┐  │
│  │ الاسم الكامل      │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ رقم الهاتف    🇪🇬 │  │ ← Country code prefix +20
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ البريد الإلكتروني │  │
│  └───────────────────┘  │
│                         │
│                         │
│  ┌───────────────────┐  │
│  │ إرسال كود التحقق  │  │ ← Primary button
│  └───────────────────┘  │
│                         │
│  "لديك حساب بالفعل؟     │
│   تسجيل الدخول"         │
└─────────────────────────┘

- 3-step progress indicator at top
- Name: text input, min 2 chars
- Phone: with Egypt country code (+20), numeric keyboard
- Email: email keyboard type
- All fields required
```

---

### Screen 4: Registration — Step 2 (OTP Verification)

```
Layout:
┌─────────────────────────┐
│  →                      │
│                         │
│  ■ ■ ■ ■ ■ ■ ○ ○ ○     │ ← Progress: step 2 of 3
│  "الخطوة 2 من 3"        │
│                         │
│  "كود التحقق"           │ ← headline-medium
│                         │
│  "تم إرسال الكود على    │
│   بريدك الإلكتروني      │
│   ورقم هاتفك"           │ ← body-medium, secondary color
│                         │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ │
│  │  │ │  │ │  │ │  │ │  │ │  │ │ ← 6 separate digit boxes
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘ │
│                         │
│  "إعادة الإرسال خلال    │
│   02:30"                │ ← Countdown timer, secondary color
│                         │
│  ┌───────────────────┐  │
│  │  تأكيد الكود      │  │ ← Primary button (disabled until 6 digits)
│  └───────────────────┘  │
│                         │
│  "لم يصلك الكود؟        │
│   إعادة الإرسال"        │ ← Grayed out during countdown
└─────────────────────────┘

- 6 individual square input boxes for OTP digits
- Auto-focus moves to next box after each digit
- 2:30 minute countdown timer
- "إعادة الإرسال" link disabled during countdown, enabled after
- Button disabled until all 6 digits entered
```

---

### Screen 5: Registration — Step 3 (Set Password)

```
Layout:
┌─────────────────────────┐
│  →                      │
│                         │
│  ■ ■ ■ ■ ■ ■ ■ ■ ■     │ ← Progress: step 3 of 3 (full)
│  "الخطوة 3 من 3"        │
│                         │
│  "إنشاء كلمة السر"      │ ← headline-medium
│                         │
│  ┌───────────────────┐  │
│  │ كلمة السر     👁  │  │ ← Password with toggle
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ تأكيد كلمة السر👁 │  │ ← Confirm password with toggle
│  └───────────────────┘  │
│                         │
│  ┌═══════════════════┐  │
│  │ ████████░░░░░░░░░ │  │ ← Password strength bar
│  └═══════════════════┘  │
│  "قوة كلمة السر: متوسطة" │ ← Strength label
│                         │
│  ┌───────────────────┐  │
│  │  إنشاء الحساب     │  │ ← Primary button
│  └───────────────────┘  │
└─────────────────────────┘

- Password strength indicator: red (weak), orange (medium), green (strong)
- Minimum 6 characters
- Button disabled until both fields match and min length met
- On success → navigate to Login screen with success message
```

---

### Screen 6: Home Dashboard (Tab 1)

```
Layout:
┌─────────────────────────┐
│                         │
│  [Avatar] "مرحباً،      │
│           أحمد"         │ ← Greeting with user name + profile pic
│                         │
│  ┌───────────────────┐  │ ← Active subscription card (if exists)
│  │ الباقة الأسبوعية   │  │
│  │                   │  │
│  │   ╭───────╮       │  │
│  │   │ 7.2GB │       │  │ ← Circular progress ring
│  │   │ متبقي  │       │  │
│  │   ╰───────╯       │  │
│  │                   │  │
│  │ 7.2 من 10 جيجا    │  │
│  │ ▓▓▓▓▓▓▓░░░  72%   │  │ ← Linear progress bar
│  │                   │  │
│  │ ⏱ 4 أيام متبقية   │  │ ← Days remaining chip
│  │ ● نشط             │  │ ← Status badge (green)
│  └───────────────────┘  │
│                         │
│  "اختر باقتك"           │ ← Section title
│                         │
│  ┌─────────┐ ┌─────────┐│ ← 2x2 grid of package cards
│  │☀ يومية  │ │📅 أسبوعية││
│  │ 2GB     │ │ 10GB    ││
│  │ 15 ج.م  │ │ 50 ج.م  ││
│  └─────────┘ └─────────┘│
│  ┌─────────┐ ┌─────────┐│
│  │📆 شهرية │ │➕ إضافية ││
│  │ 50GB    │ │ 5GB     ││
│  │ 150 ج.م │ │ 25 ج.م  ││
│  └─────────┘ └─────────┘│
│                         │
│  ━━━━━━━━━━━━━━━━━━━━━  │
│  🏠 الرئيسية  📊 الاستهلاك  👤 حسابي │ ← Bottom nav (3 tabs)
└─────────────────────────┘

- Top: Circle avatar (40px) + greeting text
- Subscription card: only shown if user has active subscription
- If no active subscription → show empty state (Screen 13)
- Package cards: each has icon, name, data amount, price
- Tapping a package card → Package Details (Screen 7)
- Bottom nav: 3 tabs — Home (active), Usage, Profile
```

---

### Screen 7: Package Details

```
Layout:
┌─────────────────────────┐
│  →              ✕       │ ← Back + Close
│                         │
│       [Package Icon]    │ ← Large icon (64px)
│       "الباقة الأسبوعية" │ ← Package name
│       ┌──────────┐      │
│       │ أسبوعية  │      │ ← Type badge pill
│       └──────────┘      │
│                         │
│       "50.00 ج.م"       │ ← Price, display-large
│                         │
│  ┌───────────────────┐  │
│  │ 📦 حجم البيانات   10 جيجابايت │
│  │ ⏱ مدة الصلاحية   7 أيام      │
│  │ ⚡ السرعة         عالية       │
│  └───────────────────┘  │
│                         │
│  "المميزات"             │
│  ✓ 10 جيجابايت          │
│  ✓ 7 أيام               │
│  ✓ سرعة عالية           │
│                         │
│                         │
│  ┌───────────────────┐  │ ← Sticky bottom bar
│  │  اشترك الآن — 50 ج.م │ ← Primary button
│  └───────────────────┘  │
└─────────────────────────┘

- Hero section: icon + name + type badge
- Price prominent in display-large
- Info rows with icons
- Features list with checkmarks (green)
- Sticky button at bottom with price
- Tapping "اشترك" → creates subscription → Payment Screen
```

---

### Screen 8: Payment Screen

```
Layout:
┌─────────────────────────┐
│  →    "إتمام الدفع"     │
│                         │
│  ┌───────────────────┐  │ ← Order summary card
│  │ الباقة الأسبوعية   │  │
│  │ 10 جيجابايت — 7 أيام│ │
│  │                   │  │
│  │ المبلغ: 50.00 ج.م │  │ ← Bold price
│  └───────────────────┘  │
│                         │
│  "اختر طريقة الدفع"     │
│                         │
│  ┌───────────────────┐  │ ← Radio card (selectable)
│  │ ○ فودافون كاش     │  │
│  │   01234567890      │  │ ← Number to transfer to
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │ ← Radio card (selectable)
│  │ ○ Instapay         │  │
│  │   internet.packages│  │
│  │   @instapay        │  │
│  └───────────────────┘  │
│                         │
│  ℹ "حوّل المبلغ على    │
│    الرقم المحدد واحتفظ  │
│    بصورة إيصال التحويل" │ ← Info text, secondary color
│                         │
│  ┌───────────────────┐  │
│  │ رفع إثبات الدفع ↑ │  │ ← Primary button
│  └───────────────────┘  │
└─────────────────────────┘

- Order summary card at top
- Two payment method radio cards (only one selectable at a time)
- Selected card gets primary border (2px)
- Instructions text below
- Button → opens Payment Upload (Screen 9)
```

---

### Screen 9: Payment Upload Screen

```
Layout:
┌─────────────────────────┐
│  →  "رفع إثبات الدفع"  │
│                         │
│  ┌──────────┐           │
│  │فودافون كاش│           │ ← Selected method chip (read-only)
│  └──────────┘           │
│                         │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─┐  │
│  │                   │  │ ← Dashed border upload zone
│  │                   │  │
│  │    [Upload Icon]  │  │
│  │                   │  │
│  │  "اضغط لاختيار    │  │
│  │   صورة الإيصال"   │  │
│  │                   │  │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─┘  │
│                         │
│  --- AFTER SELECTION --- │
│                         │
│  ┌───────────────────┐  │
│  │  [Image Preview]  │  │ ← Thumbnail of selected image
│  │                   │  │
│  │       ✕ إزالة     │  │ ← Remove button
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │  تأكيد الدفع      │  │ ← Primary (disabled until image selected)
│  └───────────────────┘  │
└─────────────────────────┘

- Shows selected payment method as chip at top
- Large dashed upload area (tappable)
- Opens image picker (camera or gallery)
- After selection: shows image thumbnail + remove option
- Confirm button disabled until image selected
- On confirm → uploads image → activates subscription → Success screen
```

---

### Screen 10: Payment Success

```
Layout:
┌─────────────────────────┐
│                         │
│                         │
│                         │
│      ╭─────────╮       │
│      │  ✓      │       │ ← Large green checkmark in circle
│      ╰─────────╯       │
│                         │
│  "تم تفعيل الباقة      │ ← headline-medium
│   بنجاح!"              │
│                         │
│  ┌───────────────────┐  │
│  │ الباقة: الأسبوعية  │  │ ← Subscription summary card
│  │ البيانات: 10 جيجا  │  │
│  │ تنتهي: 2026-06-06 │  │
│  │ الحالة: ● نشط      │  │ ← Green badge
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ الذهاب للرئيسية   │  │ ← Primary button
│  └───────────────────┘  │
│                         │
│  "عرض تفاصيل الاشتراك" │ ← Text link
│                         │
└─────────────────────────┘

- Full screen success state
- Animated green checkmark (scale + fade in)
- Summary card with subscription details
- Two actions: go home (primary) or view details (link)
- No back button — user must choose an action
```

---

### Screen 11: Usage Dashboard (Tab 2)

```
Layout:
┌─────────────────────────┐
│  "استهلاك الإنترنت"     │ ← Title
│                         │
│      ╭───────────╮      │
│      │           │      │ ← Large circular donut chart (160px)
│      │   7.2GB   │      │ ← Remaining data, display-large
│      │   متبقي    │      │ ← Label below number
│      ╰───────────╯      │
│                         │
│  ┌──────┐┌──────┐┌──────┐│ ← 3 stat chips row
│  │الإجمالي││المستهلك││المتبقي││
│  │ 10GB ││ 2.8GB││ 7.2GB││
│  └──────┘└──────┘└──────┘│
│                         │
│  ▓▓▓▓▓▓▓░░░░░░░ 28%    │ ← Linear progress bar + percentage
│                         │
│  ┌───────────────────┐  │
│  │ ⏱ 4 أيام متبقية   │  │ ← Days remaining card
│  │   تنتهي 2026-06-06│  │
│  └───────────────────┘  │
│                         │
│  "سجل الاشتراكات"       │ ← Section title + "عرض الكل" link
│                         │
│  ┌───────────────────┐  │ ← Recent subscription card
│  │ الأسبوعية | نشط ● │  │
│  │ 30/5 → 6/6        │  │
│  └───────────────────┘  │
│                         │
│  ━━━━━━━━━━━━━━━━━━━━━  │
│  🏠 الرئيسية  📊 الاستهلاك  👤 حسابي │
└─────────────────────────┘

- Circular donut: primary color for used, gray track for remaining
- Center text: remaining GB large + "متبقي" small
- 3 stat chips: total, used, remaining
- Progress bar with percentage
- Days card with calendar icon
- Recent subscriptions mini-list
- "عرض الكل" link → Subscription History screen
```

---

### Screen 12: Subscription History

```
Layout:
┌─────────────────────────┐
│  →  "سجل الاشتراكات"    │
│                         │
│  [الكل] [نشطة] [منتهية] [ملغاة] │ ← Filter chips row (scrollable)
│                         │
│  ┌───────────────────┐  │
│  │ الباقة الأسبوعية   │  │ ← Subscription card
│  │ ┌────────┐        │  │
│  │ │أسبوعية │  ● نشط │  │ ← Type badge + Status badge (green)
│  │ └────────┘        │  │
│  │ 30/5/2026 → 6/6/2026│ │ ← Date range
│  │ ▓▓▓▓▓▓▓░░░ 72%    │  │ ← Mini progress bar
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ الباقة اليومية     │  │
│  │ ┌────────┐        │  │
│  │ │ يومية  │  ○ منتهي│ │ ← Status badge (gray)
│  │ └────────┘        │  │
│  │ 28/5/2026 → 29/5  │  │
│  │ ▓▓▓▓▓▓▓▓▓▓ 100%   │  │
│  └───────────────────┘  │
│                         │
│  --- EMPTY STATE ---    │
│  "لا توجد اشتراكات"     │
└─────────────────────────┘

- Filter chips: one active at a time, primary background when selected
- Status badge colors: green=نشط, gray=منتهي, red=ملغي
- Cards are tappable → show subscription details
```

---

### Screen 13: Empty State (No Active Subscription)

```
Layout:
┌─────────────────────────┐
│                         │
│                         │
│                         │
│    [WiFi illustration   │ ← SVG/illustration: disconnected WiFi
│     with X mark]        │
│                         │
│  "لا يوجد اشتراك نشط"   │ ← headline-medium
│                         │
│  "اختر باقة من الباقات  │ ← body-medium, secondary color
│   المتاحة وابدأ         │
│   الاستمتاع بالإنترنت"  │
│                         │
│  ┌───────────────────┐  │
│  │  اشترك الآن       │  │ ← Primary button
│  └───────────────────┘  │
│                         │
│                         │
│  ━━━━━━━━━━━━━━━━━━━━━  │
│  🏠 الرئيسية  📊 الاستهلاك  👤 حسابي │
└─────────────────────────┘

- Shown on Home tab when no active subscription
- Also shown on Usage tab when no subscription
- "اشترك الآن" scrolls to packages section or navigates to packages
```

---

### Screen 14: Profile Tab (Tab 3)

```
Layout:
┌─────────────────────────┐
│  "حسابي"                │
│                         │
│      ╭─────────╮       │
│      │ [Photo] │       │ ← Large avatar (80px) + camera overlay
│      ╰─────────╯       │
│      "أحمد محمد"        │ ← User name, headline-medium
│      "ahmed@test.com"   │ ← Email, body-medium, secondary
│      ┌────────┐        │
│      │ مستخدم │        │ ← Role badge
│      └────────┘        │
│                         │
│  ┌───────────────────┐  │ ← Settings list
│  │ ✏️ تعديل البيانات   → │  │
│  ├───────────────────┤  │
│  │ 🔒 تغيير كلمة السر → │  │
│  ├───────────────────┤  │
│  │ 👥 المستفيدون (2) → │  │ ← Count badge
│  ├───────────────────┤  │
│  │ 📋 سجل الاشتراكات → │  │
│  ├───────────────────┤  │
│  │ 🗑 حذف الحساب     → │  │ ← Red text (destructive)
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │  تسجيل الخروج     │  │ ← Outlined button (not filled)
│  └───────────────────┘  │
│                         │
│  ━━━━━━━━━━━━━━━━━━━━━  │
│  🏠 الرئيسية  📊 الاستهلاك  👤 حسابي │
└─────────────────────────┘

- Large avatar at top with camera icon overlay (bottom-left for RTL)
- Settings items in a card/list with arrow indicators
- Each item navigates to its respective screen
- Delete account in red/error color
- Logout button: outlined style (not primary filled)
```

---

### Screen 15: Edit Profile

```
Layout:
┌─────────────────────────┐
│  →  "تعديل البيانات"    │
│                         │
│      ╭─────────╮       │
│      │ [Photo] │       │ ← Avatar with camera icon overlay
│      │  📷     │       │   Tappable → image picker
│      ╰─────────╯       │
│   "تغيير الصورة"        │ ← Text link below avatar
│                         │
│  ┌───────────────────┐  │
│  │ الاسم الكامل      │  │ ← Editable
│  │ "أحمد محمد"       │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ البريد الإلكتروني │  │ ← Read-only (grayed out)
│  │ ahmed@test.com    │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ رقم الهاتف       │  │ ← Read-only (grayed out)
│  │ +201234567890     │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │  حفظ التغييرات    │  │ ← Primary button
│  └───────────────────┘  │
└─────────────────────────┘

- Only name is editable
- Email and phone are read-only with visual indicator (grayed/dimmed)
- Profile picture tappable to change
```

---

### Screen 16: Change Password

```
Layout:
┌─────────────────────────┐
│  →  "تغيير كلمة السر"   │
│                         │
│  ┌───────────────────┐  │
│  │ كلمة السر الحالية 👁│ │ ← Current password
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ كلمة السر الجديدة 👁│ │ ← New password
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ تأكيد كلمة السر  👁│  │ ← Confirm new password
│  └───────────────────┘  │
│                         │
│  ┌═══════════════════┐  │
│  │ ████████████░░░░░ │  │ ← Strength bar
│  └═══════════════════┘  │
│  "قوة كلمة السر: قوية"  │
│                         │
│  ┌───────────────────┐  │
│  │  حفظ              │  │ ← Primary button
│  └───────────────────┘  │
└─────────────────────────┘

- All 3 fields have show/hide toggle
- Password strength indicator for new password
- Strength levels: ضعيفة (red), متوسطة (orange), قوية (green)
```

---

### Screen 17: Beneficiaries Management

```
Layout:
┌─────────────────────────┐
│  →  "المستفيدون"  (2)   │ ← Title + count badge
│                         │
│  ┌───────────────────┐  │ ← Info banner
│  │ ℹ يشاركون نفس    │  │
│  │   بيانات باقتك    │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │ ← Beneficiary card
│  │ ╭──╮ سارة أحمد    │  │ ← Initials avatar + name
│  │ │سا│ sara@test.com│  │ ← Email below name
│  │ ╰──╯       ✏️  🗑  │  │ ← Edit + Delete icons
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │ ← Another beneficiary card
│  │ ╭──╮ محمد علي     │  │
│  │ │مع│ mo@test.com  │  │
│  │ ╰──╯       ✏️  🗑  │  │
│  └───────────────────┘  │
│                         │
│  --- EMPTY STATE ---    │
│  "لا يوجد مستفيدون"     │
│  "أضف مستفيد لمشاركة   │
│   باقتك"                │
│                         │
│                    [+]  │ ← FAB button (bottom-left for RTL)
└─────────────────────────┘

- Title with count badge (circle, primary color)
- Info banner: light blue/primary at 10% opacity background
- Each card: initials circle avatar + name + email + action icons
- Delete icon: error/red color with confirmation dialog
- FAB (+) opens Add Beneficiary bottom sheet
- Empty state when no beneficiaries
```

---

### Screen 18: Add Beneficiary (Bottom Sheet)

```
Layout:
┌─────────────────────────┐
│                         │ ← Dimmed background overlay
│                         │
│  ┌───────────────────┐  │ ← Bottom sheet (75% height)
│  │    ━━━━━━━━       │  │ ← Drag handle
│  │                   │  │
│  │  "إضافة مستفيد"   │  │ ← Title
│  │                   │  │
│  │  ┌─────────────┐  │  │
│  │  │ الاسم الكامل │  │  │
│  │  └─────────────┘  │  │
│  │                   │  │
│  │  ┌─────────────┐  │  │
│  │  │ البريد      │  │  │
│  │  │ الإلكتروني  │  │  │
│  │  └─────────────┘  │  │
│  │                   │  │
│  │  ┌─────────────┐  │  │
│  │  │ رقم الهاتف  │  │  │
│  │  └─────────────┘  │  │
│  │                   │  │
│  │  ┌─────────────┐  │  │
│  │  │ كلمة السر 👁│  │  │
│  │  └─────────────┘  │  │
│  │                   │  │
│  │  ┌─────────────┐  │  │
│  │  │ إضافة المستفيد│ │  │ ← Primary button
│  │  └─────────────┘  │  │
│  └───────────────────┘  │
└─────────────────────────┘

- Modal bottom sheet with drag handle
- Slides up from bottom, 75% screen height
- Background dimmed/blurred
- All 4 fields required
- On success: closes sheet, refreshes list, shows snackbar "تمت الإضافة"
```

---

### Screen 19: Delete Confirmation Dialog

```
Layout:
┌─────────────────────────┐
│                         │ ← Dimmed overlay
│  ┌───────────────────┐  │
│  │                   │  │ ← Centered dialog card
│  │  ⚠️ "حذف الحساب"  │  │
│  │                   │  │
│  │  "هل أنت متأكد    │  │
│  │   من حذف حسابك؟   │  │
│  │   لا يمكن التراجع │  │
│  │   عن هذا الإجراء"  │  │
│  │                   │  │
│  │  [إلغاء] [حذف]    │  │ ← Cancel (text) + Delete (red button)
│  └───────────────────┘  │
└─────────────────────────┘

- Used for: delete account, delete beneficiary
- Warning icon in error color
- Cancel: text button
- Delete: filled button in error color
- Reusable dialog pattern
```

---

## Interaction Notes

1. **Loading states**: Show skeleton loaders (pulsing gray rectangles) while fetching data
2. **Error states**: Show inline error below input fields, red color, shake animation
3. **Snackbars**: Bottom snackbar for success messages (green) and errors (red)
4. **Transitions**: Slide transitions between screens (right-to-left for push, left-to-right for pop — reversed for RTL)
5. **Pull to refresh**: On Home and Usage tabs
6. **Haptic feedback**: On button press and successful actions

---

## Deliverables

For EACH of the 19 screens above:
1. **Light Mode** design
2. **Dark Mode** design
3. Both must have identical layout — only surface/text colors change
