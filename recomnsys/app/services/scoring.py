"""
Scoring Algorithm Service
Implements the core recommendation scoring formula.
"""
from typing import List, Optional
from app import mongo
from app.models.schemas import Product, Tier, ScoredProduct
from app.services.stratification import UserStratificationService
from app.services.modifiers import ModifierService
from app.config import TierConfig


class ScoringService:
    """
    Implements the recommendation scoring algorithm:
    
    Score = AnchorGap × (MatchQuality × StretchFactor) × IntentBoost × SeasonBoost
    """
    
    @classmethod
    def calculate_anchor_gap(cls, product: Product) -> float:
        """
        Calculate Anchor Gap: Sense of "deals".
        
        Formula: (Price_HighTier - Price_Target) / Price_HighTier
        
        Higher gap = better perceived value.
        Falls back to 0.2 if no high anchor price is set.
        """
        high_price = product.high_anchor_price or (product.price * 1.25)  # Assume 25% markup if not set
        
        if high_price <= 0:
            return 0.2
        
        gap = (high_price - product.price) / high_price
        return max(0, min(gap, 1.0))  # Clamp between 0 and 1
    
    @classmethod
    def calculate_match_quality(cls, product: Product, avg_spend: float) -> float:
        """
        Calculate Match Quality: Targeting the upsell limit.
        
        Formula: 1 - |Price - (AvgSpend × 1.3)| / (AvgSpend × 1.3)
        
        Products closest to 1.3x average spend get highest score.
        """
        if avg_spend <= 0:
            # New user - use neutral matching
            return 0.5
        
        target = avg_spend * TierConfig.UPSELL_TARGET_MULTIPLIER
        
        if target <= 0:
            return 0.5
        
        deviation = abs(product.price - target) / target
        quality = max(0, 1 - deviation)
        
        return quality
    
    @classmethod
    def calculate_product_score(
        cls,
        product: Product,
        tier: Tier,
        avg_spend: float,
        search_query: str = '',
        apply_tier_strategy: bool = True
    ) -> ScoredProduct:
        """
        Calculate complete recommendation score for a product.
        
        Args:
            product: The product to score
            tier: User's behavioral tier
            avg_spend: User's average spend (category-specific preferred)
            search_query: Optional search query for intent boost
            apply_tier_strategy: Whether to apply tier-specific adjustments
            
        Returns:
            ScoredProduct with full scoring breakdown
        """
        # Calculate components
        anchor_gap = cls.calculate_anchor_gap(product)
        match_quality = cls.calculate_match_quality(product, avg_spend)
        stretch_factor = UserStratificationService.get_stretch_factor(tier)
        intent_boost = ModifierService.get_intent_boost(search_query)
        season_boost = ModifierService.get_season_boost()
        
        # Apply tier-specific strategy adjustments
        if apply_tier_strategy:
            anchor_gap, match_quality = cls._apply_tier_adjustments(
                tier, product, anchor_gap, match_quality
            )
        
        # Core scoring formula
        # Score = AnchorGap × (MatchQuality × StretchFactor) × IntentBoost × SeasonBoost
        score = anchor_gap * (match_quality * stretch_factor) * intent_boost * season_boost
        
        return ScoredProduct(
            product=product,
            score=score,
            tier=tier,
            anchor_gap=anchor_gap,
            match_quality=match_quality,
            stretch_factor=stretch_factor,
            intent_boost=intent_boost,
            season_boost=season_boost
        )
    
    @classmethod
    def _apply_tier_adjustments(
        cls,
        tier: Tier,
        product: Product,
        anchor_gap: float,
        match_quality: float
    ) -> tuple:
        """
        Apply tier-specific strategy adjustments.
        
        Elite: Penalize cheap products, boost luxury
        Aspirer: Neutral adjustments
        Saver: Boost high anchor gaps (perceived savings)
        """
        tier_indicator = product.tier_indicator or 'mid'
        
        if tier == Tier.ELITE:
            # Resistance Logic: Avoid cheap signals
            if tier_indicator == 'budget':
                match_quality *= 0.5  # Heavily penalize budget items
            elif tier_indicator == 'luxury':
                match_quality *= 1.3  # Boost luxury items
                
        elif tier == Tier.SAVER:
            # Anchoring: Emphasize perceived savings
            if anchor_gap > 0.3:
                anchor_gap *= 1.2  # Boost high-discount items
            
        # Aspirer tier gets default behavior (stretch factor handles it)
        
        return (anchor_gap, match_quality)
    
    @classmethod
    def get_products_by_category(cls, category_id: str, limit: int = 100) -> List[Product]:
        """Fetch products from MongoDB by category."""
        cursor = mongo.db.products.find({'category_id': category_id}).limit(limit)
        return [Product.from_mongo(doc) for doc in cursor]
    
    @classmethod
    def get_all_products(cls, limit: int = 100) -> List[Product]:
        """Fetch all products (for cross-category recommendations)."""
        cursor = mongo.db.products.find().limit(limit)
        return [Product.from_mongo(doc) for doc in cursor]
    
    @classmethod
    def rank_products(
        cls,
        user_id: str,
        category_id: Optional[str] = None,
        search_query: str = '',
        limit: int = 10
    ) -> List[ScoredProduct]:
        """
        Main ranking function: Get top recommended products for a user.
        
        Args:
            user_id: The user's ID
            category_id: Optional category filter
            search_query: Optional search query for intent boost
            limit: Number of products to return (default 10)
            
        Returns:
            List of ScoredProduct sorted by score descending
        """
        # Step 1: Stratify user
        tier, avg_spend = UserStratificationService.classify_user(user_id, category_id)
        
        # Step 2: Get candidate products
        if category_id:
            products = cls.get_products_by_category(category_id)
        else:
            products = cls.get_all_products()
        
        if not products:
            return []
        
        # Step 3: Score all products
        scored_products = [
            cls.calculate_product_score(product, tier, avg_spend, search_query)
            for product in products
        ]
        
        # Step 4: Sort by score and return top N
        scored_products.sort(key=lambda x: x.score, reverse=True)
        
        return scored_products[:limit]
    
    @classmethod
    def explain_score(cls, scored_product: ScoredProduct) -> dict:
        """
        Generate human-readable explanation of a product's score.
        Useful for debugging and transparency.
        """
        sp = scored_product
        explanations = []
        
        # Anchor Gap explanation
        if sp.anchor_gap > 0.3:
            explanations.append(f"Great deal: {int(sp.anchor_gap * 100)}% below reference price")
        elif sp.anchor_gap > 0.1:
            explanations.append(f"Good value: {int(sp.anchor_gap * 100)}% below reference price")
        
        # Match Quality explanation
        if sp.match_quality > 0.8:
            explanations.append("Excellent match for your spending profile")
        elif sp.match_quality > 0.5:
            explanations.append("Good match for your spending profile")
        else:
            explanations.append("Outside your typical spending range")
        
        # Tier strategy explanation
        strategy = UserStratificationService.get_tier_strategy(sp.tier)
        explanations.append(f"Strategy: {strategy['name']}")
        
        # Seasonal boost
        if sp.season_boost > 1.0:
            festivals = ModifierService.get_active_festivals()
            if festivals:
                names = ', '.join(f['name'] for f in festivals)
                explanations.append(f"Festive boost ({names}): +{int((sp.season_boost - 1) * 100)}%")
        
        # Intent boost
        if sp.intent_boost != 1.0:
            direction = "boost" if sp.intent_boost > 1 else "reduction"
            pct = abs(int((sp.intent_boost - 1) * 100))
            explanations.append(f"Search intent {direction}: {pct}%")
        
        return {
            'product_id': sp.product._id,
            'product_name': sp.product.name,
            'final_score': round(sp.score, 4),
            'tier': sp.tier.value,
            'explanations': explanations
        }
