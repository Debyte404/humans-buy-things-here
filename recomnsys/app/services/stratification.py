"""
User Stratification Service
Classifies users into behavioral tiers based on purchase history.
"""
from typing import Tuple, Optional
from app import mongo
from app.models.schemas import Tier, UserPurchaseHistory, PurchaseHistoryItem
from app.config import TierConfig


class UserStratificationService:
    """
    Classifies users into behavioral tiers:
    - Tier 1 (Elite): High spenders, brand loyal → Resistance Logic
    - Tier 2 (Aspirer): Mid spenders, value seekers → Stretch Strategy
    - Tier 3 (Saver): Price sensitive → Anchoring Strategy
    """
    
    # Cache for percentile thresholds (computed from all users)
    _threshold_cache = {
        'p80': None,
        'p20': None,
        'last_computed': None
    }
    
    @classmethod
    def get_purchase_history(cls, user_id: str) -> UserPurchaseHistory:
        """Fetch user's purchase history from MongoDB."""
        # Query orders collection for user's purchases
        orders = mongo.db.orders.find({'user_id': user_id})
        
        purchases = []
        for order in orders:
            for item in order.get('items', []):
                purchases.append(PurchaseHistoryItem(
                    product_id=str(item.get('product_id', '')),
                    product_name=item.get('product_name', ''),
                    price=float(item.get('price', 0)),
                    quantity=int(item.get('quantity', 1)),
                    category_id=str(item.get('category_id', '')),
                    purchased_at=order.get('created_at')
                ))
        
        return UserPurchaseHistory(user_id=user_id, purchases=purchases)
    
    @classmethod
    def compute_percentile_thresholds(cls) -> Tuple[float, float]:
        """
        Compute P80 and P20 spend thresholds from all users.
        Uses MongoDB aggregation for efficiency.
        """
        pipeline = [
            # Group by user and calculate total spend
            {
                '$group': {
                    '_id': '$user_id',
                    'total_spend': {'$sum': {'$multiply': ['$items.price', '$items.quantity']}}
                }
            },
            # Sort by spend
            {'$sort': {'total_spend': 1}},
            # Get all spends into an array
            {
                '$group': {
                    '_id': None,
                    'spends': {'$push': '$total_spend'},
                    'count': {'$sum': 1}
                }
            }
        ]
        
        result = list(mongo.db.orders.aggregate(pipeline))
        
        if not result or not result[0].get('spends'):
            # Default thresholds if no data
            return (5000.0, 1000.0)
        
        spends = sorted(result[0]['spends'])
        count = len(spends)
        
        p80_idx = int(count * 0.80)
        p20_idx = int(count * 0.20)
        
        p80 = spends[min(p80_idx, count - 1)]
        p20 = spends[max(p20_idx, 0)]
        
        return (p80, p20)
    
    @classmethod
    def get_thresholds(cls) -> Tuple[float, float]:
        """Get cached or compute percentile thresholds."""
        from datetime import datetime, timedelta
        
        # Refresh cache every hour
        if (cls._threshold_cache['last_computed'] is None or 
            datetime.now() - cls._threshold_cache['last_computed'] > timedelta(hours=1)):
            
            p80, p20 = cls.compute_percentile_thresholds()
            cls._threshold_cache['p80'] = p80
            cls._threshold_cache['p20'] = p20
            cls._threshold_cache['last_computed'] = datetime.now()
        
        return (cls._threshold_cache['p80'], cls._threshold_cache['p20'])
    
    @classmethod
    def classify_user(cls, user_id: str, category_id: Optional[str] = None) -> Tuple[Tier, float]:
        """
        Classify user into a behavioral tier.
        
        Args:
            user_id: The user's ID
            category_id: Optional category to calculate category-specific average
            
        Returns:
            Tuple of (Tier, average_spend)
        """
        history = cls.get_purchase_history(user_id)
        
        # Handle new users with no history
        if history.purchase_count == 0:
            return (Tier.ASPIRER, 0.0)  # Default to middle tier
        
        # Calculate average spend (category-specific if provided)
        if category_id:
            avg_spend = history.get_category_spend(category_id)
        else:
            avg_spend = history.average_spend
        
        total_spend = history.total_spend
        purchase_count = history.purchase_count
        
        # Get thresholds
        p80_threshold, p20_threshold = cls.get_thresholds()
        
        # Classification logic
        if total_spend >= p80_threshold and purchase_count >= TierConfig.ELITE_MIN_PURCHASES:
            return (Tier.ELITE, avg_spend)
        elif total_spend >= p20_threshold and purchase_count >= TierConfig.ASPIRER_MIN_PURCHASES:
            return (Tier.ASPIRER, avg_spend)
        else:
            return (Tier.SAVER, avg_spend)
    
    @classmethod
    def get_stretch_factor(cls, tier: Tier) -> float:
        """Get the stretch factor for a given tier."""
        return TierConfig.STRETCH_FACTORS.get(tier.value, 1.0)
    
    @classmethod
    def get_tier_strategy(cls, tier: Tier) -> dict:
        """Get the strategy description for a tier."""
        strategies = {
            Tier.ELITE: {
                'name': 'Resistance Logic',
                'description': 'Avoid cheap signals; push luxury and exclusivity',
                'tactics': ['Hide discounts', 'Emphasize exclusivity', 'Show premium brands']
            },
            Tier.ASPIRER: {
                'name': 'The Stretch',
                'description': 'Push 20-30% above historical average',
                'tactics': ['Show "most popular" badges', 'Highlight value proposition', 'Cross-sell accessories']
            },
            Tier.SAVER: {
                'name': 'Anchoring',
                'description': 'Highlight perceived savings against high-price decoys',
                'tactics': ['Show MRP vs selling price', 'Display "X% off" prominently', 'Show budget comparisons']
            }
        }
        return strategies.get(tier, strategies[Tier.ASPIRER])
