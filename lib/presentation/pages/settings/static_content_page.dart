import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class StaticContentPage extends ConsumerWidget {
  final String title;
  final String contentId; // 'faq', 'privacy', 'terms'

  const StaticContentPage({
    super.key,
    required this.title,
    required this.contentId,
  });

  String _getContent() {
    switch (contentId) {
      case 'faq':
        return '''
### Soru 1: Bu uygulama ne işe yarar?
YKS Master, üniversite sınavına hazırlanan öğrenciler için geliştirilmiş kapsamlı bir çalışma asistanıdır. Deneme sınavları çözebilir, konulara göre eksiklerini görebilir ve hedefine ne kadar yaklaştığını takip edebilirsin.

### Soru 2: Verilerim nerede saklanıyor?
Tüm verilerin cihazında yerel olarak saklanmaktadır. Herhangi bir sunucuya veri gönderilmemektedir. Uygulamayı silersen verilerin kaybolabilir.

### Soru 3: Başka cihazdan devam edebilir miyim?
Şu an için bulut senkronizasyonu bulunmamaktadır. Verilerin sadece bu tablette erişilebilirdir.
''';
      case 'privacy':
        return '''
### Gizlilik Politikası

Son güncelleme: 10 Şubat 2026

**1. Veri Toplama**
YKS Master Tablet uygulaması, kişisel verilerinizi sunucularında toplamaz veya saklamaz. İsim, alan ve sınav istatistikleri gibi tüm veriler sadece cihazınızın yerel hafızasında tutulur.

**2. Veri Kullanımı**
Toplanan veriler sadece size istatistik sunmak ve ilerlemenizi takip etmek amacıyla uygulama içerisinde işlenir. 

**3. Üçüncü Taraflar**
Verileriniz hiçbir üçüncü taraf reklam şirketi veya veri analiz firması ile paylaşılmaz.
''';
      case 'terms':
        return '''
### Kullanım Şartları

**1. Kabul**
Bu uygulamayı kullanarak aşağıdaki şartları kabul etmiş sayılırsınız.

**2. Lisans**
Uygulamanın tüm hakları saklıdır. Kopyalanması, çoğaltılması veya ticari amaçla kullanılması yasaktır.

**3. Sorumluluk Reddi**
Uygulama eğitim amaçlı bir yardımcı araçtır. Sınav sonuçlarınızın garantisi değildir. İçerikteki olası hatalardan geliştirici sorumlu tutulamaz.
''';
      default:
        return 'İçerik bulunamadı.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final content = _getContent();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: theme.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.surface,
        iconTheme: IconThemeData(color: theme.text),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                content,
                style: TextStyle(color: theme.text, fontSize: 16, height: 1.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
