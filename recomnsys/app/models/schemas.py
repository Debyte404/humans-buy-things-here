"""
MongoDB Schema Definitions
Defines expected document structures for Products and Purchase History.
"""
from dataclasses import dataclass
from typing import Optional, List
from datetime import datetime
from enum import Enum


class Tier(Enum):
    """User behavioral tier classification."""
    ELITE = 'elite'       # Tier 1: High spenders, brand loyal
    ASPIRER = 'aspirer'   # Tier 2: Mid spenders, value seekers
    SAVER = 'saver'       # Tier 3: Price sensitive


@dataclass
class Product:
    """Product document schema."""
    _id: str
    name: str
    price: float
    category_id: str
    brand: Optional[str] = None
    tier_indicator: Optional[str] = None  # 'luxury', 'mid', 'budget'
    high_anchor_price: Optional[float] = None  # MRP or competitor price
    tags: Optional[List[str]] = None
    
    @classmethod
    def from_mongo(cls, doc: dict) -> 'Product':
        """Create Product from MongoDB document."""
        return cls(
            _id=str(doc.get('_id', '')),
            name=doc.get('name', ''),
            price=float(doc.get('price', 0)),
            category_id=str(doc.get('category_id', '')),
            brand=doc.get('brand'),
            tier_indicator=doc.get('tier_indicator'),
            high_anchor_price=doc.get('high_anchor_price'),
            tags=doc.get('tags', [])
        )


@dataclass
class PurchaseHistoryItem:
    """Single purchase record."""
    product_id: str
    product_name: str
    price: float
    quantity: int
    category_id: str
    purchased_at: datetime
    
    @classmethod
    def from_mongo(cls, doc: dict) -> 'PurchaseHistoryItem':
        """Create PurchaseHistoryItem from MongoDB document."""
        return cls(
            product_id=str(doc.get('product_id', '')),
            product_name=doc.get('product_name', ''),
            price=float(doc.get('price', 0)),
            quantity=int(doc.get('quantity', 1)),
            category_id=str(doc.get('category_id', '')),
            purchased_at=doc.get('purchased_at', datetime.now())
        )


@dataclass
class UserPurchaseHistory:
    """User's complete purchase history."""
    user_id: str
    purchases: List[PurchaseHistoryItem]
    
    @property
    def total_spend(self) -> float:
        """Calculate total historical spend."""
        return sum(p.price * p.quantity for p in self.purchases)
    
    @property
    def average_spend(self) -> float:
        """Calculate average spend per purchase."""
        if not self.purchases:
            return 0.0
        return self.total_spend / len(self.purchases)
    
    @property
    def purchase_count(self) -> int:
        """Get total number of purchases."""
        return len(self.purchases)
    
    def get_category_spend(self, category_id: str) -> float:
        """Get average spend in a specific category."""
        category_purchases = [p for p in self.purchases if p.category_id == category_id]
        if not category_purchases:
            return self.average_spend  # Fall back to overall average
        return sum(p.price * p.quantity for p in category_purchases) / len(category_purchases)


@dataclass
class ScoredProduct:
    """Product with recommendation score."""
    product: Product
    score: float
    tier: Tier
    anchor_gap: float
    match_quality: float
    stretch_factor: float
    intent_boost: float
    season_boost: float
    
    def to_dict(self) -> dict:
        """Convert to JSON-serializable dictionary."""
        return {
            'product_id': self.product._id,
            'name': self.product.name,
            'price': self.product.price,
            'brand': self.product.brand,
            'category_id': self.product.category_id,
            'score': round(self.score, 4),
            'scoring_breakdown': {
                'anchor_gap': round(self.anchor_gap, 4),
                'match_quality': round(self.match_quality, 4),
                'stretch_factor': round(self.stretch_factor, 4),
                'intent_boost': round(self.intent_boost, 4),
                'season_boost': round(self.season_boost, 4)
            },
            'user_tier': self.tier.value
        }
