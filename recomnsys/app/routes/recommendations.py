"""
Recommendation API Routes
Exposes REST endpoints for the recommendation engine.
"""
from flask import Blueprint, request, jsonify
from app.services.scoring import ScoringService
from app.services.stratification import UserStratificationService
from app.services.modifiers import ModifierService
from app.config import FestiveConfig, TierConfig

bp = Blueprint('recommendations', __name__)


@bp.route('/rank', methods=['GET'])
def get_recommendations():
    """
    GET /api/recom/rank
    
    Get ranked product recommendations for a user.
    
    Query Parameters:
        user_id (required): The user's ID
        category_id (optional): Filter by category
        search_query (optional): Search query for intent boost
        limit (optional): Number of results (default 10, max 50)
        explain (optional): Include scoring explanations (default false)
    
    Returns:
        JSON array of scored products with rankings
    """
    # Parse parameters
    user_id = request.args.get('user_id')
    category_id = request.args.get('category_id')
    search_query = request.args.get('search_query', '')
    limit = min(int(request.args.get('limit', 10)), 50)
    explain = request.args.get('explain', 'false').lower() == 'true'
    
    # Validate required params
    if not user_id:
        return jsonify({
            'error': 'Missing required parameter: user_id',
            'code': 'MISSING_USER_ID'
        }), 400
    
    try:
        # Get ranked products
        scored_products = ScoringService.rank_products(
            user_id=user_id,
            category_id=category_id,
            search_query=search_query,
            limit=limit
        )
        
        # Format response
        if explain:
            results = [
                {
                    **sp.to_dict(),
                    'explanation': ScoringService.explain_score(sp)
                }
                for sp in scored_products
            ]
        else:
            results = [sp.to_dict() for sp in scored_products]
        
        # Get user tier info
        tier, avg_spend = UserStratificationService.classify_user(user_id, category_id)
        strategy = UserStratificationService.get_tier_strategy(tier)
        
        return jsonify({
            'success': True,
            'user': {
                'id': user_id,
                'tier': tier.value,
                'avg_spend': round(avg_spend, 2),
                'strategy': strategy['name']
            },
            'context': ModifierService.get_all_multipliers(search_query),
            'recommendations': results,
            'count': len(results)
        })
        
    except Exception as e:
        return jsonify({
            'error': str(e),
            'code': 'SCORING_ERROR'
        }), 500


@bp.route('/config', methods=['GET'])
def get_config():
    """
    GET /api/recom/config
    
    Get current recommendation engine configuration.
    
    Returns:
        JSON object with festive statuses, multipliers, and thresholds
    """
    try:
        active_festivals = FestiveConfig.get_active_festivals()
        season_boost = FestiveConfig.get_season_boost()
        
        return jsonify({
            'success': True,
            'festivals': {
                'active': active_festivals,
                'all': [
                    {
                        'key': key,
                        'name': f['name'],
                        'period': f"{f['start_month']}/{f['start_day']} - {f['end_month']}/{f['end_day']}",
                        'multiplier': f['multiplier']
                    }
                    for key, f in FestiveConfig.FESTIVALS.items()
                ],
                'current_boost': season_boost
            },
            'tiers': {
                'thresholds': {
                    'elite_percentile': TierConfig.ELITE_PERCENTILE,
                    'saver_percentile': TierConfig.SAVER_PERCENTILE,
                    'elite_min_purchases': TierConfig.ELITE_MIN_PURCHASES,
                    'aspirer_min_purchases': TierConfig.ASPIRER_MIN_PURCHASES
                },
                'stretch_factors': TierConfig.STRETCH_FACTORS,
                'upsell_multiplier': TierConfig.UPSELL_TARGET_MULTIPLIER
            },
            'intent_keywords': {
                'premium': [k for k, v in __import__('app.config', fromlist=['IntentConfig']).IntentConfig.BOOST_KEYWORDS.items() if v > 1.2],
                'budget': [k for k, v in __import__('app.config', fromlist=['IntentConfig']).IntentConfig.BOOST_KEYWORDS.items() if v < 0.9]
            }
        })
        
    except Exception as e:
        return jsonify({
            'error': str(e),
            'code': 'CONFIG_ERROR'
        }), 500


@bp.route('/stratify', methods=['GET'])
def stratify_user():
    """
    GET /api/recom/stratify
    
    Get user stratification details (for debugging/analytics).
    
    Query Parameters:
        user_id (required): The user's ID
        category_id (optional): Category for category-specific spend
    
    Returns:
        JSON object with tier classification and strategy
    """
    user_id = request.args.get('user_id')
    category_id = request.args.get('category_id')
    
    if not user_id:
        return jsonify({
            'error': 'Missing required parameter: user_id',
            'code': 'MISSING_USER_ID'
        }), 400
    
    try:
        tier, avg_spend = UserStratificationService.classify_user(user_id, category_id)
        strategy = UserStratificationService.get_tier_strategy(tier)
        history = UserStratificationService.get_purchase_history(user_id)
        
        return jsonify({
            'success': True,
            'user_id': user_id,
            'tier': tier.value,
            'classification': {
                'total_spend': round(history.total_spend, 2),
                'average_spend': round(avg_spend, 2),
                'purchase_count': history.purchase_count,
                'category_specific': category_id is not None
            },
            'strategy': strategy,
            'stretch_factor': UserStratificationService.get_stretch_factor(tier)
        })
        
    except Exception as e:
        return jsonify({
            'error': str(e),
            'code': 'STRATIFICATION_ERROR'
        }), 500


@bp.route('/analyze-intent', methods=['GET'])
def analyze_intent():
    """
    GET /api/recom/analyze-intent
    
    Analyze a search query for intent signals (for debugging).
    
    Query Parameters:
        query (required): The search query to analyze
    
    Returns:
        JSON object with detected keywords and boost calculation
    """
    query = request.args.get('query', '')
    
    analysis = ModifierService.analyze_search_intent(query)
    
    return jsonify({
        'success': True,
        **analysis
    })


@bp.route('/health', methods=['GET'])
def health_check():
    """
    GET /api/recom/health
    
    Health check endpoint for monitoring.
    """
    from app import mongo
    
    try:
        # Test MongoDB connection
        mongo.db.command('ping')
        db_status = 'connected'
    except Exception as e:
        db_status = f'error: {str(e)}'
    
    return jsonify({
        'service': 'RecomnSys',
        'status': 'healthy' if db_status == 'connected' else 'degraded',
        'database': db_status,
        'active_festivals': len(FestiveConfig.get_active_festivals()),
        'season_boost': FestiveConfig.get_season_boost()
    })
