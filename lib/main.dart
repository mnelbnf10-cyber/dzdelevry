import 'package:flutter/material.dart';

void main() => runApp(const DzDeliveryApp());

const Color purple = Color(0xFF8D65D8);
const Color purpleDark = Color(0xFF6843B5);
const Color lavender = Color(0xFFF3EDFC);
const Color ink = Color(0xFF28233A);
const Color muted = Color(0xFF8C8799);
const Color green = Color(0xFF39C995);

class DzDeliveryApp extends StatelessWidget {
  const DzDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DzDelivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF8FD),
        colorScheme: ColorScheme.fromSeed(seedColor: purple),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF8FD),
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class FoodItem {
  final String name, shop, category, emoji;
  final int price, minutes;
  final Color tint;
  const FoodItem(this.name, this.shop, this.category, this.emoji, this.price,
      this.minutes, this.tint);
}

const foods = <FoodItem>[
  FoodItem('برغر دجاج', 'Burger House', 'برغر', '🍔', 650, 25, Color(0xFFFFE6D7)),
  FoodItem('بيتزا مارغريتا', 'Pizza Roma', 'بيتزا', '🍕', 950, 35, Color(0xFFFFE8C5)),
  FoodItem('تاكوس ميكس', 'Tacos City', 'تاكوس', '🌯', 800, 20, Color(0xFFE4F4D9)),
  FoodItem('شاورما دجاج', 'Le Snack', 'شاورما', '🥙', 550, 20, Color(0xFFFFE6E8)),
  FoodItem('كيكة الشوكولا', 'Sweet Corner', 'حلويات', '🍰', 400, 15, Color(0xFFF0E1FA)),
  FoodItem('عصير فريش', 'Juice Lab', 'مشروبات', '🧋', 300, 10, Color(0xFFDFF5F1)),
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;
  final Map<FoodItem, int> cart = {};
  final List<Map<String, dynamic>> orders = [];
  String category = 'الكل';
  String search = '';

  int get cartCount => cart.values.fold(0, (a, b) => a + b);
  int get cartTotal => cart.entries.fold(0, (a, e) => a + e.key.price * e.value);

  void add(FoodItem food) {
    setState(() => cart[food] = (cart[food] ?? 0) + 1);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('تمت إضافة ${food.name} إلى السلة'),
      duration: const Duration(milliseconds: 900),
      backgroundColor: purpleDark,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void changeQty(FoodItem food, int delta) {
    setState(() {
      final next = (cart[food] ?? 0) + delta;
      if (next <= 0) {
        cart.remove(food);
      } else {
        cart[food] = next;
      }
    });
  }

  void placeOrder() {
    if (cart.isEmpty) return;
    setState(() {
      orders.insert(0, {
        'number': 'DZ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'items': Map<FoodItem, int>.from(cart),
        'total': cartTotal,
        'status': 'جديد',
        'time': TimeOfDay.now().format(context),
      });
      cart.clear();
      tab = 2;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('تم تسجيل طلبك بنجاح!'),
      backgroundColor: green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        category: category,
        search: search,
        onCategory: (v) => setState(() => category = v),
        onSearch: (v) => setState(() => search = v),
        onAdd: add,
        onShop: () => setState(() => tab = 1),
      ),
      ShopPage(onAdd: add),
      OrdersPage(orders: orders),
      MerchantPage(orders: orders, onStatus: (i, s) => setState(() => orders[i]['status'] = s)),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: IndexedStack(index: tab, children: pages)),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          backgroundColor: Colors.white,
          indicatorColor: lavender,
          elevation: 8,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront_rounded), label: 'المحلات'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'طلباتي'),
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'لوحة المحل'),
          ],
        ),
        floatingActionButton: tab == 0 || tab == 1
            ? FloatingActionButton.extended(
                onPressed: () => showCart(context),
                backgroundColor: purple,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text('السلة ($cartCount)  •  $cartTotal دج'),
              )
            : null,
      ),
    );
  }

  void showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(builder: (ctx, setModal) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 18),
                Row(children: [const Expanded(child: Text('سلة المشتريات', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))), Text('$cartCount منتجات', style: const TextStyle(color: muted))]),
                const SizedBox(height: 14),
                if (cart.isEmpty)
                  const Padding(padding: EdgeInsets.all(28), child: Text('السلة فارغة، أضف وجبتك المفضلة!'))
                else
                  ...cart.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: e.key.tint, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(e.key.emoji, style: const TextStyle(fontSize: 25)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.key.name, style: const TextStyle(fontWeight: FontWeight.w700)), Text('${e.key.price} دج', style: const TextStyle(color: purpleDark))])),
                      IconButton(onPressed: () { changeQty(e.key, -1); setModal(() {}); }, icon: const Icon(Icons.remove_circle_outline)),
                      Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () { changeQty(e.key, 1); setModal(() {}); }, icon: const Icon(Icons.add_circle_outline, color: purple)),
                    ]),
                  )),
                const Divider(height: 24),
                Row(children: [const Expanded(child: Text('المجموع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))), Text('$cartTotal دج', style: const TextStyle(fontSize: 20, color: purpleDark, fontWeight: FontWeight.w900))]),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, height: 52, child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: cart.isEmpty ? null : () { Navigator.pop(ctx); showCheckout(context); },
                  child: const Text('متابعة وإتمام الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
                )),
              ]),
            ),
          );
        }),
      ),
    );
  }

  void showCheckout(BuildContext context) {
    final name = TextEditingController();
    final phone = TextEditingController();
    final address = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              const Text('تأكيد الطلب', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('أدخل معلومات التوصيل الخاصة بك', style: TextStyle(color: muted)),
              const SizedBox(height: 18),
              field(name, 'الاسم الكامل', Icons.person_outline),
              field(phone, 'رقم الهاتف', Icons.phone_outlined, type: TextInputType.phone),
              field(address, 'العنوان بالتفصيل', Icons.location_on_outlined),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: lavender, borderRadius: BorderRadius.circular(15)), child: Row(children: [const Icon(Icons.payments_outlined, color: purple), const SizedBox(width: 10), const Expanded(child: Text('الدفع نقدًا عند الاستلام')), Text('$cartTotal دج', style: const TextStyle(fontWeight: FontWeight.w900, color: purpleDark))])),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 52, child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  if (name.text.trim().isEmpty || phone.text.trim().isEmpty || address.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء جميع معلومات التوصيل')));
                    return;
                  }
                  Navigator.pop(ctx);
                  placeOrder();
                },
                child: const Text('تأكيد الطلب الآن', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
            ])),
          ),
        ),
      ),
    );
  }

  Widget field(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: TextField(controller: c, keyboardType: type, decoration: InputDecoration(prefixIcon: Icon(icon, color: purple), labelText: label, filled: true, fillColor: const Color(0xFFF8F6FB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
  );
}

class HomePage extends StatelessWidget {
  final String category, search;
  final ValueChanged<String> onCategory, onSearch;
  final ValueChanged<FoodItem> onAdd;
  final VoidCallback onShop;
  const HomePage({super.key, required this.category, required this.search, required this.onCategory, required this.onSearch, required this.onAdd, required this.onShop});

  @override
  Widget build(BuildContext context) {
    final cats = ['الكل', 'برغر', 'بيتزا', 'تاكوس', 'شاورما', 'حلويات', 'مشروبات'];
    final filtered = foods.where((f) => (category == 'الكل' || f.category == category) && ('${f.name} ${f.shop}'.toLowerCase().contains(search.toLowerCase()))).toList();
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFBFA0F3), purpleDark]), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 31)),
            const SizedBox(width: 11),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DzDelivery', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: ink)), Text('طلبك المفضل، حتى لباب دارك', style: TextStyle(color: muted, fontSize: 12))])),
            Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.notifications_none_rounded, color: purpleDark)),
          ]),
          const SizedBox(height: 22),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFB99AF0), Color(0xFF8D65D8), Color(0xFF7950C4)]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: purple.withOpacity(.20), blurRadius: 22, offset: const Offset(0, 10))]),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(20)), child: const Text('توصيل سريع • خدمة محلية', style: TextStyle(color: Colors.white, fontSize: 11))),
                const SizedBox(height: 12),
                const Text('الجوع ما يستناش!', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                const Text('اكتشف أفضل المأكولات في منطقتك', style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 14),
                FilledButton(onPressed: onShop, style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: purpleDark), child: const Text('اكتشف المحلات')),
              ])),
              const SizedBox(width: 6),
              const Text('🍔', style: TextStyle(fontSize: 65)),
            ]),
          ),
          const SizedBox(height: 22),
          TextField(onChanged: onSearch, decoration: InputDecoration(hintText: 'ابحث عن وجبة أو محل...', prefixIcon: const Icon(Icons.search_rounded, color: purple), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 15), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          const SizedBox(height: 22),
          Row(children: [const Expanded(child: Text('التصنيفات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: ink))), TextButton(onPressed: onShop, child: const Text('كل المحلات ←', style: TextStyle(color: purpleDark)))]),
          const SizedBox(height: 10),
          SizedBox(height: 43, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: cats.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) {
            final active = category == cats[i];
            return ChoiceChip(label: Text(cats[i]), selected: active, onSelected: (_) => onCategory(cats[i]), selectedColor: purple, backgroundColor: Colors.white, labelStyle: TextStyle(color: active ? Colors.white : ink, fontWeight: FontWeight.w600), side: BorderSide.none, showCheckmark: false);
          })),
          const SizedBox(height: 21),
          Row(children: [const Expanded(child: Text('الأكثر طلبًا 🔥', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: ink))), Text('${filtered.length} وجبات', style: const TextStyle(color: muted, fontSize: 12))]),
          const SizedBox(height: 12),
        ]),
      )),
      if (filtered.isEmpty)
        const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('لم نعثر على نتائج'))))
      else
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, i) => FoodCard(food: filtered[i], onAdd: () => onAdd(filtered[i])), childCount: filtered.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 13, mainAxisSpacing: 13, childAspectRatio: .69),
        )),
    ]);
  }
}

class FoodCard extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onAdd;
  const FoodCard({super.key, required this.food, required this.onAdd});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF6E5696).withOpacity(.05), blurRadius: 15, offset: const Offset(0, 5))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Stack(children: [
        Container(width: double.infinity, decoration: BoxDecoration(color: food.tint, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))), child: Center(child: Text(food.emoji, style: const TextStyle(fontSize: 66)))),
        Positioned(top: 9, right: 9, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.9), borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.access_time_rounded, size: 12, color: purpleDark), const SizedBox(width: 3), Text('${food.minutes} د', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]))),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(11, 10, 11, 11), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: ink)),
        const SizedBox(height: 3),
        Text(food.shop, maxLines: 1, style: const TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(child: Text('${food.price} دج', style: const TextStyle(color: purpleDark, fontWeight: FontWeight.w900, fontSize: 14))),
          InkWell(onTap: onAdd, borderRadius: BorderRadius.circular(12), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: purple, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.add_rounded, color: Colors.white))),
        ]),
      ])),
    ]),
  );
}

class ShopPage extends StatelessWidget {
  final ValueChanged<FoodItem> onAdd;
  const ShopPage({super.key, required this.onAdd});
  @override
  Widget build(BuildContext context) {
    final shops = <String, List<FoodItem>>{};
    for (final f in foods) { shops.putIfAbsent(f.shop, () => []).add(f); }
    return CustomScrollView(slivers: [
      const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(20, 22, 20, 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('المحلات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)), SizedBox(height: 5), Text('اختار محلك واطلب واش تحب', style: TextStyle(color: muted))]))),
      SliverList(delegate: SliverChildBuilderDelegate((context, i) {
        final name = shops.keys.elementAt(i);
        final items = shops[name]!;
        final f = items.first;
        return Container(margin: const EdgeInsets.fromLTRB(20, 6, 20, 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [
          Container(width: 68, height: 68, decoration: BoxDecoration(color: f.tint, borderRadius: BorderRadius.circular(17)), child: Center(child: Text(f.emoji, style: const TextStyle(fontSize: 36)))),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${items.map((e) => e.category).toSet().join(' • ')}', style: const TextStyle(color: muted, fontSize: 11)), const SizedBox(height: 6), const Row(children: [Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFB547)), SizedBox(width: 3), Text('4.8', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), SizedBox(width: 9), Icon(Icons.delivery_dining, size: 15, color: purple), Text('20–35 دقيقة', style: TextStyle(fontSize: 11, color: muted))])])),
          IconButton(onPressed: () => onAdd(f), icon: const Icon(Icons.add_circle, color: purple, size: 29)),
        ]));
      }, childCount: shops.length)),
    ]);
  }
}

class OrdersPage extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  const OrdersPage({super.key, required this.orders});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('طلباتي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
      const SizedBox(height: 5),
      const Text('تابع طلباتك بكل سهولة', style: TextStyle(color: muted)),
      const SizedBox(height: 20),
      if (orders.isEmpty) Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 104, height: 104, decoration: const BoxDecoration(color: lavender, shape: BoxShape.circle), child: const Icon(Icons.receipt_long_rounded, size: 49, color: purple)), const SizedBox(height: 17), const Text('ما عندك حتى طلب لحد الآن', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), const SizedBox(height: 6), const Text('كي تطلب، تلقى طلبك هنا', style: TextStyle(color: muted))])))
      else Expanded(child: ListView.separated(itemCount: orders.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, i) {
        final o = orders[i];
        final items = o['items'] as Map<FoodItem, int>;
        return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('#${o['number']}', style: const TextStyle(fontWeight: FontWeight.w900))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: lavender, borderRadius: BorderRadius.circular(10)), child: Text('${o['status']}', style: const TextStyle(color: purpleDark, fontWeight: FontWeight.bold, fontSize: 12)))]),
          const Divider(height: 24),
          ...items.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(children: [Text(e.key.emoji), const SizedBox(width: 8), Expanded(child: Text('${e.key.name} × ${e.value}')), Text('${e.key.price * e.value} دج', style: const TextStyle(fontWeight: FontWeight.bold))]))),
          const Divider(height: 20),
          Row(children: [const Expanded(child: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))), Text('${o['total']} دج', style: const TextStyle(color: purpleDark, fontWeight: FontWeight.w900, fontSize: 17))]),
        ]));
      })),
    ]),
  );
}

class MerchantPage extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final void Function(int, String) onStatus;
  const MerchantPage({super.key, required this.orders, required this.onStatus});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('لوحة المحل', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
      const SizedBox(height: 5),
      const Text('نموذج أولي لإدارة الطلبات الواردة', style: TextStyle(color: muted)),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: metric('كل الطلبات', '${orders.length}', Icons.receipt_long_rounded)),
        const SizedBox(width: 10),
        Expanded(child: metric('طلبات جديدة', '${orders.where((o) => o['status'] == 'جديد').length}', Icons.notifications_active_outlined)),
        const SizedBox(width: 10),
        Expanded(child: metric('مكتملة', '${orders.where((o) => o['status'] == 'تم التسليم').length}', Icons.task_alt_rounded)),
      ]),
      const SizedBox(height: 22),
      const Text('الطلبات الواردة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      if (orders.isEmpty) Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.storefront_rounded, size: 65, color: purple.withOpacity(.45)), const SizedBox(height: 12), const Text('لا توجد طلبات حاليًا', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('ستظهر الطلبات هنا بعد تأكيدها', style: TextStyle(color: muted, fontSize: 12))])))
      else Expanded(child: ListView.separated(itemCount: orders.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) {
        final o = orders[i];
        final items = o['items'] as Map<FoodItem, int>;
        return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('#${o['number']}', style: const TextStyle(fontWeight: FontWeight.w900))), Text('${o['total']} دج', style: const TextStyle(color: purpleDark, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 8),
          Text(items.entries.map((e) => '${e.key.name} ×${e.value}').join('، '), style: const TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: o['status'] as String,
            decoration: InputDecoration(labelText: 'حالة الطلب', filled: true, fillColor: lavender, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5)),
            items: const ['جديد', 'قيد التحضير', 'خرج للتوصيل', 'تم التسليم', 'ملغي'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (s) { if (s != null) onStatus(i, s); },
          ),
        ]));
      })),
    ]),
  );
}

Widget metric(String label, String value, IconData icon) => Container(
  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 9),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
  child: Column(children: [Icon(icon, color: purple, size: 23), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: muted))]),
);
