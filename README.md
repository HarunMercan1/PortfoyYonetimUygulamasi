# 💼 Portföy Yönetim Sistemi

Bu proje, **Gazi Üniversitesi Bilgisayar Mühendisliği — Veritabanı Yönetim Sistemleri** dersi kapsamında geliştirilmiştir.  
Kullanıcıların yatırım portföylerini **merkezi bir sistem üzerinden yönetmesini** sağlayan bir uygulamadır.

Uygulama; hisse senetleri, kripto paralar, emtialar ve diğer varlık türlerini destekler.  
Kullanıcılar varlıklarını ekleyebilir, silebilir, türlerine göre analiz edebilir ve portföy dağılımını grafiksel olarak görüntüleyebilir. 📊

---

## 🧱 Mimari Yapı

| Katman               | Teknolojiler                         |
| :------------------- | :----------------------------------- |
| **Frontend (Mobil)** | Flutter (Material 3, http, fl_chart) |
| **Backend (API)**    | Node.js + Express.js                 |
| **Veritabanı (DB)**  | PostgreSQL                           |
| **Araçlar**          | Postman, VSCode, Android Studio      |

---

## 🗄️ Veritabanı Yapısı

Yeni veritabanı ilişkisel şekilde tasarlanmıştır.  
Aşağıdaki tablolar birbirine **foreign key** bağlantıları ile bağlıdır:

| Tablo            | Açıklama                                            |
| :--------------- | :-------------------------------------------------- |
| **users**        | Kullanıcı bilgilerini tutar                         |
| **asset_types**  | Varlık türlerini (Hisse, Kripto, Emtia vb.) tutar   |
| **currencies**   | Para birimlerini (TRY, USD, EUR vb.) tutar          |
| **assets**       | Kullanıcıya ait tüm varlık kayıtlarını tutar        |
| **transactions** | (Hazırlıkta) Varlık alım-satım geçmişini saklayacak |

> 💡 Bu yapı sayesinde uygulama artık **çoklu kullanıcı, çoklu para birimi ve çoklu varlık türü** destekler hale gelmiştir.

---

## ⚙️ Backend Özellikleri

- 🔹 Express.js tabanlı RESTful API
- 🔹 PostgreSQL bağlantısı (pg Pool)
- 🔹 CRUD işlemleri (GET, POST, DELETE — PUT yakında)
- 🔹 JOIN yapılarıyla ilişkisel veri çekimi
- 🔹 Dinamik varlık türü ve para birimi listeleri
- 🔹 JSON tabanlı cevap yapısı

---

## 📱 Frontend Özellikleri

- 🎨 Flutter (Material 3, koyu/açık tema desteği)
- 📊 fl_chart ile portföy dağılım grafiği
- 🔁 Gerçek zamanlı veri yenileme
- ➕ Varlık ekleme (bottom sheet formu)
- ❌ Silme işlemi (onay dialog ile)
- 🧩 REST API ile tam senkronizasyon
- 🔜 Düzenleme ekranı ve işlem geçmişi eklenecek

---

## 📸 Ekran Görüntüleri

<p align="center">
  <img src="flutter/assets/4.0/1.png" alt="Ekran 1" width="300"/>
  <img src="flutter/assets/4.0/2.png" alt="Ekran 2" width="300"/>
  <img src="flutter/assets/4.0/3.png" alt="Ekran 3" width="300"/>
</p>

---

👨‍💻 Geliştirici

Harun Reşit Mercan
🎓 Gazi Üniversitesi — Bilgisayar Mühendisliği
🌍 Flutter • Node.js • PostgreSQL Developer
