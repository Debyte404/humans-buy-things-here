"""
Sample Data Seeder
Populates MongoDB with sample products and orders for testing.
Run with: python -m app.seed_data
"""
import os
import sys
from datetime import datetime, timedelta
import random

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dotenv import load_dotenv
load_dotenv()

from pymongo import MongoClient

# Sample product data
SAMPLE_PRODUCTS = [
    # Electronics - Laptops
    {'name': 'ProBook Elite 15', 'price': 89999, 'category_id': 'electronics', 'brand': 'TechPro', 'tier_indicator': 'luxury', 'high_anchor_price': 110000, 'tags': ['laptop', 'professional', 'premium']},
    {'name': 'WorkStation Pro X1', 'price': 75999, 'category_id': 'electronics', 'brand': 'TechPro', 'tier_indicator': 'luxury', 'high_anchor_price': 95000, 'tags': ['laptop', 'workstation']},
    {'name': 'UltraBook Air 14', 'price': 54999, 'category_id': 'electronics', 'brand': 'SwiftTech', 'tier_indicator': 'mid', 'high_anchor_price': 65000, 'tags': ['laptop', 'ultrabook', 'portable']},
    {'name': 'ValueBook 15.6', 'price': 35999, 'category_id': 'electronics', 'brand': 'BudgetTech', 'tier_indicator': 'budget', 'high_anchor_price': 42000, 'tags': ['laptop', 'budget', 'student']},
    {'name': 'ChromeBook Lite', 'price': 22999, 'category_id': 'electronics', 'brand': 'CloudBook', 'tier_indicator': 'budget', 'high_anchor_price': 28000, 'tags': ['laptop', 'chromebook', 'affordable']},
    
    # Electronics - Phones
    {'name': 'FlagShip Ultra 5G', 'price': 79999, 'category_id': 'electronics', 'brand': 'MobiPrime', 'tier_indicator': 'luxury', 'high_anchor_price': 89999, 'tags': ['phone', 'flagship', '5g']},
    {'name': 'Pro Max 256GB', 'price': 64999, 'category_id': 'electronics', 'brand': 'MobiPrime', 'tier_indicator': 'luxury', 'high_anchor_price': 74999, 'tags': ['phone', 'pro', 'camera']},
    {'name': 'MidRange Plus', 'price': 29999, 'category_id': 'electronics', 'brand': 'ValuePhone', 'tier_indicator': 'mid', 'high_anchor_price': 35999, 'tags': ['phone', 'value', 'popular']},
    {'name': 'Budget King 4G', 'price': 12999, 'category_id': 'electronics', 'brand': 'BasicMobile', 'tier_indicator': 'budget', 'high_anchor_price': 15999, 'tags': ['phone', 'budget', '4g']},
    
    # Fashion - Clothing
    {'name': 'Designer Silk Saree', 'price': 15999, 'category_id': 'fashion', 'brand': 'EthnicLux', 'tier_indicator': 'luxury', 'high_anchor_price': 22000, 'tags': ['saree', 'silk', 'wedding', 'festive']},
    {'name': 'Premium Cotton Kurta Set', 'price': 4999, 'category_id': 'fashion', 'brand': 'IndianWear', 'tier_indicator': 'mid', 'high_anchor_price': 6500, 'tags': ['kurta', 'festive', 'cotton']},
    {'name': 'Casual Denim Jeans', 'price': 1999, 'category_id': 'fashion', 'brand': 'UrbanStyle', 'tier_indicator': 'mid', 'high_anchor_price': 2799, 'tags': ['jeans', 'casual', 'denim']},
    {'name': 'Basic T-Shirt Pack', 'price': 699, 'category_id': 'fashion', 'brand': 'BasicWear', 'tier_indicator': 'budget', 'high_anchor_price': 999, 'tags': ['tshirt', 'basic', 'pack']},
    
    # Home & Living
    {'name': 'Smart Home Hub Pro', 'price': 12999, 'category_id': 'home', 'brand': 'SmartLiving', 'tier_indicator': 'luxury', 'high_anchor_price': 16999, 'tags': ['smart home', 'hub', 'automation']},
    {'name': 'Air Purifier Max', 'price': 8999, 'category_id': 'home', 'brand': 'CleanAir', 'tier_indicator': 'mid', 'high_anchor_price': 11999, 'tags': ['air purifier', 'health', 'home']},
    {'name': 'LED Table Lamp', 'price': 1299, 'category_id': 'home', 'brand': 'BrightHome', 'tier_indicator': 'budget', 'high_anchor_price': 1799, 'tags': ['lamp', 'led', 'desk']},
]

# Sample users for testing
SAMPLE_USERS = [
    {'user_id': 'elite_user_001', 'tier': 'elite', 'spend_range': (50000, 90000), 'purchase_count': 8},
    {'user_id': 'elite_user_002', 'tier': 'elite', 'spend_range': (40000, 80000), 'purchase_count': 6},
    {'user_id': 'aspirer_user_001', 'tier': 'aspirer', 'spend_range': (15000, 35000), 'purchase_count': 4},
    {'user_id': 'aspirer_user_002', 'tier': 'aspirer', 'spend_range': (10000, 25000), 'purchase_count': 3},
    {'user_id': 'saver_user_001', 'tier': 'saver', 'spend_range': (2000, 8000), 'purchase_count': 1},
    {'user_id': 'saver_user_002', 'tier': 'saver', 'spend_range': (1000, 5000), 'purchase_count': 2},
    {'user_id': 'new_user_001', 'tier': 'new', 'spend_range': (0, 0), 'purchase_count': 0},
]


def seed_database():
    """Seed the database with sample data."""
    mongo_uri = os.environ.get('MONGO_URI', 'mongodb://localhost:27017/humans-buy-things-here')
    
    print(f"🔌 Connecting to MongoDB...")
    client = MongoClient(mongo_uri)
    db = client.get_database()
    
    print(f"📦 Connected to database: {db.name}")
    
    # Clear existing data
    print("🧹 Clearing existing sample data...")
    db.products.delete_many({})
    db.orders.delete_many({'_seeded': True})
    
    # Insert products
    print(f"📝 Inserting {len(SAMPLE_PRODUCTS)} products...")
    result = db.products.insert_many(SAMPLE_PRODUCTS)
    product_ids = result.inserted_ids
    print(f"   ✅ Inserted {len(product_ids)} products")
    
    # Create sample orders for each user
    print(f"🛒 Creating sample orders for {len(SAMPLE_USERS)} users...")
    orders_created = 0
    
    for user in SAMPLE_USERS:
        if user['purchase_count'] == 0:
            continue
            
        for i in range(user['purchase_count']):
            # Pick random products within spend range
            affordable_products = [
                p for p in SAMPLE_PRODUCTS 
                if user['spend_range'][0] <= p['price'] <= user['spend_range'][1]
            ]
            
            if not affordable_products:
                affordable_products = SAMPLE_PRODUCTS[:3]  # Fallback
            
            product = random.choice(affordable_products)
            
            order = {
                'user_id': user['user_id'],
                'items': [{
                    'product_id': str(product_ids[SAMPLE_PRODUCTS.index(product)]),
                    'product_name': product['name'],
                    'price': product['price'],
                    'quantity': 1,
                    'category_id': product['category_id']
                }],
                'total': product['price'],
                'status': 'completed',
                'created_at': datetime.now() - timedelta(days=random.randint(1, 90)),
                '_seeded': True  # Mark as seeded data
            }
            
            db.orders.insert_one(order)
            orders_created += 1
    
    print(f"   ✅ Created {orders_created} orders")
    
    # Summary
    print("\n" + "="*50)
    print("✨ Seeding complete!")
    print(f"   Products: {db.products.count_documents({})}")
    print(f"   Orders: {db.orders.count_documents({'_seeded': True})}")
    print("="*50)
    
    # Print test user IDs
    print("\n📋 Test User IDs:")
    for user in SAMPLE_USERS:
        print(f"   - {user['user_id']} ({user['tier']})")
    
    client.close()


if __name__ == '__main__':
    seed_database()
