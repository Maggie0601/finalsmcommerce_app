import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedMainDishes() async {
  final firestore = FirebaseFirestore.instance;

  final List<dynamic> mainDishes = [
    {
      'productName': 'Baby Back Ribs',
      'category': 'Main Dishes',
      'price': 668.0,
      'description': 'Tender baby back ribs glazed with savory BBQ sauce, served with potato chips (2-3 pax).',
      'stock': 30,
      'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': "Yeyi's Bulalo",
      'category': 'Main Dishes',
      'price': 558.0,
      'description': 'Beef shank and bone marrow simmered in a rich, savory broth (2-3 pax).',
      'stock': 25,
      'imageUrl': 'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Chili Garlic Shrimp',
      'category': 'Main Dishes',
      'price': 448.0,
      'description': 'Juicy shrimp sautéed in a flavorful chili garlic sauce (2 pax).',
      'stock': 30,
      'imageUrl': 'https://images.unsplash.com/photo-1559742811-82286364ceaf?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Crispy Pata (Regular)',
      'category': 'Main Dishes',
      'price': 628.0,
      'description': 'Crispy pork knuckle served with a savory native sauce (2-3 pax).',
      'stock': 20,
      'imageUrl': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Crispy Pata (Large)',
      'category': 'Main Dishes',
      'price': 848.0,
      'description': 'Crispy pork knuckle served with a savory native sauce (3-5 pax).',
      'stock': 15,
      'imageUrl': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Classic Grilled Liempo',
      'category': 'Main Dishes',
      'price': 428.0,
      'description': 'Marinated pork liempo served with fried eggplant, atchara, and red egg (2-3 pax).',
      'stock': 35,
      'imageUrl': 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Beef Salpicao',
      'category': 'Main Dishes',
      'price': 408.0,
      'description': 'Beef short plate sauté in olive oil, garlic, and chili (2-3 pax).',
      'stock': 30,
      'imageUrl': 'https://images.unsplash.com/photo-1588168333986-5078d3ae3976?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Crispy Pork Binagoongan',
      'category': 'Main Dishes',
      'price': 368.0,
      'description': 'Crispy pork tossed in savory bagoong sauce (2 pax).',
      'stock': 30,
      'imageUrl': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': '1/2 Chicken Savory',
      'category': 'Main Dishes',
      'price': 368.0,
      'description': 'Tender chicken simmered in rich and savory sauce, served with specialty gravy (2 pax).',
      'stock': 25,
      'imageUrl': 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Grilled Chicken Pesto',
      'category': 'Main Dishes',
      'price': 398.0,
      'description': 'Tender grilled chicken topped with flavorful pesto sauce (2-3 pax).',
      'stock': 30,
      'imageUrl': 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Fried Pompano',
      'category': 'Main Dishes',
      'price': 388.0,
      'description': 'Split fried pompano served with native sauce (2 pax).',
      'stock': 20,
      'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Pork Ribs (Sweet Chili Sesame)',
      'category': 'Main Dishes',
      'price': 388.0,
      'description': 'Pork ribs glazed with sweet chili sesame flavor (2-3 pax).',
      'stock': 25,
      'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Pork Ribs (Salt & Pepper)',
      'category': 'Main Dishes',
      'price': 388.0,
      'description': 'Pork ribs prepared with seasoned salt & pepper (2-3 pax).',
      'stock': 25,
      'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Pork Ribs (Buttered Duck Egg)',
      'category': 'Main Dishes',
      'price': 388.0,
      'description': 'Pork ribs tossed in rich buttered duck egg flavor (2-3 pax).',
      'stock': 25,
      'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Chicken in The Basket',
      'category': 'Main Dishes',
      'price': 368.0,
      'description': 'Fried chicken thigh fillet with fries and special gravy (2-3 pax).',
      'stock': 30,
      'imageUrl': 'https://images.unsplash.com/photo-1562967914-608f82629710?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
    {
      'productName': 'Weekend Platter',
      'category': 'Main Dishes',
      'price': 1588.0,
      'description': 'Available ONLY on weekends: A combination of Red Wine Beef Stew, Baby Back Ribs, Grilled Liempo, and Stuffed Chicken Parmigiana (4-6 pax).',
      'stock': 15,
      'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500&auto=format&fit=crop&q=60',
      'isAvailable': true,
    },
  ];

  final WriteBatch batch = firestore.batch();

  for (final item in mainDishes) {
    final docRef = firestore.collection('products').doc();
    batch.set(docRef, item);
  }

  await batch.commit();
}