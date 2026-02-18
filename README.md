# YKS Master Tablet

Flutter tabanlı tablet uygulaması (iPad ve Android Tabletler için - Landscape Mode)

## 📱 Proje Özellikleri

- **Platform**: iPad ve Android Tabletler
- **Yönlendirme**: Yalnızca Landscape (Yatay) Mod
- **Mimari**: Clean Architecture
- **Durum Yönetimi**: Flutter Riverpod
- **Dependency Injection**: get_it

## 🏗️ Klasör Yapısı

Proje Clean Architecture prensiplerine uygun olarak yapılandırılmıştır:

```
lib/
├── core/                    # Temel işlevsellik ve paylaşılan kodlar
│   ├── constants/          # Sabitler
│   ├── error/              # Hata yönetimi
│   ├── network/            # Ağ katmanı
│   ├── usecases/           # Temel use case sınıfları
│   └── utils/              # Yardımcı fonksiyonlar
│
├── features/               # Özellik modülleri (her özellik kendi klasöründe)
│
├── data/                   # Veri katmanı
│   ├── datasources/        # Veri kaynakları (API, DB vb.)
│   ├── models/             # Veri modelleri
│   └── repositories/       # Repository implementasyonları
│
├── domain/                 # Domain katmanı (iş mantığı)
│   ├── entities/           # İş varlıkları
│   ├── repositories/       # Repository arayüzleri
│   └── usecases/           # Use case'ler
│
└── presentation/           # Sunum katmanı
    ├── pages/              # Sayfalar
    ├── widgets/            # Özel widget'lar
    └── providers/          # Riverpod provider'ları
```

## 📦 Bağımlılıklar

- **flutter_svg** (^2.0.10+1): SVG görüntü desteği
- **pdfx** (^2.7.0): PDF görüntüleme
- **get_it** (^8.0.3): Dependency injection
- **flutter_riverpod** (^2.6.1): Durum yönetimi

## 🔧 Kurulum

1. Flutter SDK'nın yüklü olduğundan emin olun
2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

3. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## 📐 Orientation Yapılandırması

Uygulama yalnızca landscape (yatay) modda çalışacak şekilde yapılandırılmıştır:

### Android
`android/app/src/main/AndroidManifest.xml` dosyasında:
```xml
android:screenOrientation="landscape"
```

### iOS
`ios/Runner/Info.plist` dosyasında:
```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

### Flutter
`lib/main.dart` dosyasında:
```dart
SystemChrome.setPreferredOrientations([
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
```

## 🚀 Geliştirme

Yeni özellikler eklerken Clean Architecture prensiplerine uygun olarak `features/` klasörü altında modüler yapı oluşturun.

### Örnek Feature Yapısı:
```
features/
└── example_feature/
    ├── data/
    ├── domain/
    └── presentation/
```
