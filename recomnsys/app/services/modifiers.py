"""
Contextual Modifiers Service
Handles Intent Boost and Season Boost calculations.
"""
from datetime import date
from app.config import FestiveConfig, IntentConfig


class ModifierService:
    """Provides contextual multipliers for recommendations."""
    
    @classmethod
    def get_intent_boost(cls, search_query: str) -> float:
        """
        Calculate intent boost from search query keywords.
        
        Examples:
            "best gaming laptop" → 1.5 (premium intent)
            "budget phone" → 0.7 (value intent)
            "laptop for gift" → 1.4 (gift intent)
        """
        return IntentConfig.get_intent_boost(search_query)
    
    @classmethod
    def get_season_boost(cls, check_date: date = None) -> float:
        """
        Get season boost multiplier for current date.
        Returns the highest multiplier if multiple festivals are active.
        """
        return FestiveConfig.get_season_boost(check_date)
    
    @classmethod
    def get_active_festivals(cls, check_date: date = None) -> list:
        """Get list of currently active festivals with their multipliers."""
        return FestiveConfig.get_active_festivals(check_date)
    
    @classmethod
    def get_all_multipliers(cls, search_query: str = '', check_date: date = None) -> dict:
        """
        Get all contextual multipliers in one call.
        
        Returns:
            dict with intent_boost, season_boost, combined_boost, active_festivals
        """
        intent = cls.get_intent_boost(search_query)
        season = cls.get_season_boost(check_date)
        festivals = cls.get_active_festivals(check_date)
        
        return {
            'intent_boost': round(intent, 4),
            'season_boost': round(season, 4),
            'combined_boost': round(intent * season, 4),
            'active_festivals': festivals,
            'search_query': search_query
        }
    
    @classmethod
    def analyze_search_intent(cls, search_query: str) -> dict:
        """
        Analyze search query to identify intent signals.
        Useful for debugging and transparency.
        """
        if not search_query:
            return {
                'query': '',
                'detected_keywords': [],
                'intent_category': 'neutral',
                'boost': 1.0
            }
        
        query_lower = search_query.lower()
        detected = []
        
        for keyword, boost in IntentConfig.BOOST_KEYWORDS.items():
            if keyword in query_lower:
                detected.append({
                    'keyword': keyword,
                    'boost': boost,
                    'category': 'premium' if boost > 1.0 else 'budget'
                })
        
        final_boost = cls.get_intent_boost(search_query)
        
        # Determine overall intent category
        if final_boost > 1.2:
            category = 'premium'
        elif final_boost < 0.9:
            category = 'budget'
        else:
            category = 'neutral'
        
        return {
            'query': search_query,
            'detected_keywords': detected,
            'intent_category': category,
            'boost': final_boost
        }
