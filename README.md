# 💼 Portföy Yönetim Sistemi v7.0 (Premium Destekli)

Kullanıcıların yatırım portföylerini **kişisel hesapları üzerinden güvenli bir şekilde yönetmesini** sağlayan bir uygulamadır.

Artık her kullanıcı, sadece **kendi varlıklarını** görebilir, ekleyebilir, silebilir ve düzenleyebilir.  
JWT tabanlı kimlik doğrulama ve **premium/normal kullanıcı rolleri** sayesinde sistem daha güvenli ve esnek hale getirilmiştir.

---

## 🧱 Mimari Yapı

| Katman               | Teknolojiler                                           |
| :------------------- | :----------------------------------------------------- |
| **Frontend (Mobil)** | Flutter (Material 3, http, fl_chart, secure_storage)   |
| **Backend (API)**    | Node.js + Express.js + JWT + RBAC (Role-Based Control) |
| **Veritabanı (DB)**  | PostgreSQL                                             |
| **Araçlar**          | Postman, VSCode, Android Studio                        |

---

## 🗄️ Veritabanı Yapısı

Veritabanı ilişkisel olarak tasarlanmıştır ve **her varlık doğrudan bir kullanıcıya bağlıdır.**  
Aşağıdaki tablolar foreign key bağlantıları ile birbirine bağlıdır:

| Tablo           | Açıklama                                              |
| :-------------- | :---------------------------------------------------- |
| **users**       | Kullanıcı bilgileri + kullanıcı rolü (normal/premium) |
| **asset_types** | Varlık türleri (Hisse, Kripto, Emtia, Fon, Tahvil…)   |
| **currencies**  | Para birimleri (TRY, USD, EUR vb.)                    |
| **assets**      | Kullanıcıya ait varlık kayıtları                      |
| **stocks**      | BIST hisseleri                                        |
| **cryptos**     | Kripto listesi                                        |
| **commodities** | Emtialar                                              |
| **funds**       | Fon listesi                                           |
| **bonds**       | Tahvil listesi                                        |
| **forex**       | Döviz verileri                                        |

> 💡 Sistem **çoklu kullanıcı** desteklidir; her kullanıcı sadece kendi portföyünü görür.

---

## 🔐 Kullanıcı Rolleri

### 👤 Normal Kullanıcı

- Sadece **Hisse + Emtia** ekleyebilir
- Diğer türleri görebilir ama ekleyemez

### ⭐ Premium Kullanıcı

- Tüm varlık türlerini ekleyebilir:
  - Hisse
  - Kripto
  - Emtia
  - Fon
  - Tahvil
  - Döviz

---

## ⚙️ Backend Özellikleri

- Express.js tabanlı RESTful API
- PostgreSQL bağlantısı (pg Pool)
- JWT tabanlı kimlik doğrulama (Login/Register)
- BCrypt ile güvenli şifre hashleme
- Rol bazlı yetkilendirme (RBAC)
- CRUD işlemleri:
  - GET → Kullanıcıya ait varlıkları getirir
  - POST → Rol kontrolü ile yeni varlık ekleme
  - PUT → Varlık düzenleme
  - DELETE → Varlık silme
- Dropdown verileri için özel endpointler:
  - /stocks
  - /cryptos
  - /commodities
  - /funds
  - /bonds
  - /forex

---

## 📱 Frontend Özellikleri (v7.0)

- 🎨 Flutter (Material 3)
- 🔐 JWT token yönetimi (secure_storage)
- 🔁 Tüm isteklerde otomatik Authorization header
- 🧩 CRUD işlemleri:
  - Yeni varlık ekleme (dinamik bottom sheet)
  - Düzenleme (EditAssetSheet)
  - Silme (dialog onay)
- 🧠 Rol bazlı UI:
  - Normal kullanıcı → sadece Hisse + Emtia dropdown gösterilir
  - Premium kullanıcı → tüm varlık türleri aktif
- 📊 Modern Pie Chart (FL Chart)
- 🔄 Ekleme / düzenleme sonrası ekran otomatik güncellenir
- 💬 Snackbar bildirimleri
- 📱 Responsive arayüz

---

## 🚀 Yeni Eklenenler (v7.0 Güncellemesi)

| Özellik                            | Açıklama                                            |
| :--------------------------------- | :-------------------------------------------------- |
| ⭐ Premium / Normal roller         | Kullanıcı girişinde rol kontrolü                    |
| 📊 Yeni varlık türleri             | Fon, Tahvil, Döviz entegre edildi                   |
| 🔄 Dinamik dropdown                | Her tür için veriler backend’den yükleniyor         |
| 🔐 Rol tabanlı varlık sınırlaması  | Normal kullanıcı sadece Hisse + Emtia ekleyebiliyor |
| 🧱 AddAssetSheet tamamen yenilendi | Kod yapısı düzenlendi, hata yönetimi iyileştirildi  |
| 🗄️ Yeni tablolar                   | funds, bonds, forex tabloları eklendi               |

---

## 📸 Ekran Görüntüleri (v7.0)

> Yeni ekran görüntüleri eklendikten sonra güncellenecek.

---

## 🧩 Klasör Yapısı

## 📸 Ekran Görüntüleri (v6.0)

<p align="center">
  <img src="flutter/assets/6.0/5.png" alt="Login" width="300"/>
  <img src="flutter/assets/6.1/1.png" alt="Kayıt ol" width="300"/>
  <img src="flutter/assets/6.0/1.png" alt="Dashboard" width="300"/>
  <img src="flutter/assets/6.0/2.png" alt="Hisseler" width="300"/>
  <img src="flutter/assets/6.0/3.png" alt="Yeni Varlık" width="300"/>
  <img src="flutter/assets/6.0/4.png" alt="Düzenle" width="300"/>
  <img src="flutter/assets/6.2/1.png" alt="Hisseler" width="300"/>
</p>

## 🧩 Klasör Yapısı

```
lib/
┣ core/
┃ ┗ theme/
┃   ┗ app_theme.dart
┣ data/
┃ ┗ api/
┃   ┗ api_service.dart
┣ models/
┃ ┗ asset_model.dart
┣ screens/
┃ ┣ add_asset/
┃ ┃ ┗ add_asset_sheet.dart
┃ ┣ auth/
┃ ┃ ┗ login_screen.dart
┃ ┣ edit_asset/
┃ ┃ ┗ edit_asset_sheet.dart
┃ ┣ home/
┃ ┃ ┣ widgets/
┃ ┃ ┃ ┣ asset_card.dart
┃ ┃ ┃ ┣ portfolio_chart.dart
┃ ┃ ┃ ┗ summary_card.dart
┃ ┃ ┗ home_screen.dart
┃ ┗ main_page.dart
┗ main.dart

```

## 👨‍💻 Geliştirici

**Harun Reşit Mercan**  
🎓 Gazi Üniversitesi — Bilgisayar Mühendisliği  
🌍 Flutter Developer  
📬 [LinkedIn](https://linkedin.com/in/harunresitmercan) • [GitHub](https://github.com/HarunMercan1)
