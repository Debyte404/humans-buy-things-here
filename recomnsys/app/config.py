"""
Configuration Management
Contains all configuration settings including festive periods and multipliers.
"""
import os
from datetime import date


class Config:
    """Flask configuration class."""
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key')
    MONGO_URI = os.environ.get('MONGO_URI', 'mongodb://localhost:27017/humans-buy-things-here')
    

class TierConfig:
    """User tier classification thresholds."""
    # Percentile thresholds for tier classification
    ELITE_PERCENTILE = 80  # Top 20% spenders
    SAVER_PERCENTILE = 20  # Bottom 20% spenders
    
    # Minimum purchase counts
    ELITE_MIN_PURCHASES = 5
    ASPIRER_MIN_PURCHASES = 2
    
    # Stretch factors per tier
    STRETCH_FACTORS = {
        'elite': 1.0,     # No stretch - push luxury
        'aspirer': 1.25,  # Push 25% above average
        'saver': 0.9      # Slight discount bias
    }
    
    # Upsell target multiplier (1.3x average spend)
    UPSELL_TARGET_MULTIPLIER = 1.3


class FestiveConfig:
    """Indian festivity configurations with date ranges and multipliers."""
    
    FESTIVALS = {
        'diwali': {
            'name': 'Diwali',
            'start_month': 10, 'start_day': 15,
            'end_month': 11, 'end_day': 15,
            'multiplier': 1.5
        },
        'holi': {
            'name': 'Holi',
            'start_month': 3, 'start_day': 1,
            'end_month': 3, 'end_day': 15,
            'multiplier': 1.3
        },
        'durga_puja': {
            'name': 'Durga Puja',
            'start_month': 10, 'start_day': 1,
            'end_month': 10, 'end_day': 15,
            'multiplier': 1.3
        },
        'year_end': {
            'name': 'Year End Sale',
            'start_month': 12, 'start_day': 20,
            'end_month': 1, 'end_day': 5,
            'multiplier': 1.4
        },
        'republic_day': {
            'name': 'Republic Day',
            'start_month': 1, 'start_day': 20,
            'end_month': 1, 'end_day': 28,
            'multiplier': 1.2
        }
    }
    
    @classmethod
    def get_active_festivals(cls, check_date: date = None) -> list:
        """Get list of currently active festivals."""
        if check_date is None:
            check_date = date.today()
        
        active = []
        for key, festival in cls.FESTIVALS.items():
            if cls._is_date_in_range(check_date, festival):
                active.append({
                    'key': key,
                    'name': festival['name'],
                    'multiplier': festival['multiplier']
                })
        return active
    
    @classmethod
    def get_season_boost(cls, check_date: date = None) -> float:
        """Get the maximum season boost multiplier for current date."""
        active = cls.get_active_festivals(check_date)
        if not active:
            return 1.0
        return max(f['multiplier'] for f in active)
    
    @classmethod
    def _is_date_in_range(cls, check_date: date, festival: dict) -> bool:
        """Check if a date falls within a festival's date range."""
        year = check_date.year
        
        start = date(year, festival['start_month'], festival['start_day'])
        
        # Handle year-spanning festivals (e.g., Year End)
        if festival['end_month'] < festival['start_month']:
            end = date(year + 1, festival['end_month'], festival['end_day'])
        else:
            end = date(year, festival['end_month'], festival['end_day'])
        
        # Also check previous year's spanning festival
        if festival['end_month'] < festival['start_month']:
            prev_start = date(year - 1, festival['start_month'], festival['start_day'])
            prev_end = date(year, festival['end_month'], festival['end_day'])
            if prev_start <= check_date <= prev_end:
                return True
        
        return start <= check_date <= end


class IntentConfig:
    """Search intent keyword configurations."""
    
    BOOST_KEYWORDS = {
        # Premium intent (+50%)
        'pro': 1.5,
        'premium': 1.5,
        'best': 1.5,
        'luxury': 1.6,
        'top': 1.4,
        'exclusive': 1.5,
        
        # Gift intent (+40%)
        'gift': 1.4,
        'occasion': 1.4,
        'wedding': 1.5,
        'anniversary': 1.4,
        'birthday': 1.3,
        
        # Value intent (-30%)
        'budget': 0.7,
        'cheap': 0.7,
        'deal': 0.8,
        'discount': 0.75,
        'affordable': 0.8,
        'value': 0.85,
        
        # Neutral/slight boost
        'new': 1.1,
        'latest': 1.15,
        'trending': 1.2
    }
    
    @classmethod
    def get_intent_boost(cls, search_query: str) -> float:
        """Calculate intent boost from search query."""
        if not search_query:
            return 1.0
        
        query_lower = search_query.lower()
        max_boost = 1.0
        
        for keyword, boost in cls.BOOST_KEYWORDS.items():
            if keyword in query_lower:
                # Use max boost if premium keyword, min if budget keyword
                if boost > 1.0:
                    max_boost = max(max_boost, boost)
                else:
                    max_boost = min(max_boost, boost)
        
        return max_boost
