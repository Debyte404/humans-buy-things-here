# RecomnSys - Project Upsell

Flask-based recommendation engine for maximizing Average Order Value (AOV) through behavioral pricing and psychological triggers.

## Features

- **User Stratification**: Classifies users into Elite, Aspirer, and Saver tiers
- **Smart Scoring**: Calculates recommendation scores using Anchor Gaps and Stretch Factors
- **Contextual Modifiers**: Intent boost from search queries, season boost for festivals
- **REST API**: Clean endpoints for frontend/backend integration

## Quick Start

### 1. Install Dependencies

```bash
cd recomnsys
pip install -r requirements.txt
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your MongoDB Atlas URI
```

### 3. Seed Sample Data (Optional)

```bash
python -m app.seed_data
```

### 4. Run the Server

```bash
python run.py
```

Server starts at `http://localhost:5001`

## API Endpoints

### `GET /api/recom/rank`

Get ranked product recommendations for a user.

**Parameters:**
- `user_id` (required): User ID
- `category_id` (optional): Filter by category
- `search_query` (optional): For intent boost
- `limit` (optional): Number of results (default 10)
- `explain` (optional): Include scoring explanations

**Example:**
```bash
curl "http://localhost:5001/api/recom/rank?user_id=elite_user_001&category_id=electronics&search_query=premium%20laptop"
```

### `GET /api/recom/config`

Get current recommendation engine configuration (festivals, multipliers, thresholds).

### `GET /api/recom/stratify`

Get user tier classification details.

### `GET /api/recom/health`

Health check endpoint.

## Scoring Algorithm

```
Score = AnchorGap × (MatchQuality × StretchFactor) × IntentBoost × SeasonBoost
```

| Component | Formula | Purpose |
|-----------|---------|---------|
| Anchor Gap | (HighPrice - Price) / HighPrice | Perceived value |
| Match Quality | 1 - \|Price - AvgSpend×1.3\| / (AvgSpend×1.3) | Upsell targeting |
| Stretch Factor | Tier-based (1.0, 1.25, 0.9) | Behavioral adjustment |
| Intent Boost | Keyword-based (0.7 - 1.6) | Search intent |
| Season Boost | Date-based (1.0 - 1.5) | Festival campaigns |

## User Tiers

| Tier | Profile | Strategy |
|------|---------|----------|
| Elite | Top 20% spenders | Resistance Logic - push luxury |
| Aspirer | Middle 60% | Stretch - 25% above average |
| Saver | Bottom 20% | Anchoring - emphasize savings |

## Project Structure

```
recomnsys/
├── app/
│   ├── __init__.py          # Flask app factory
│   ├── config.py             # Configuration classes
│   ├── models/
│   │   └── schemas.py        # Data schemas
│   ├── services/
│   │   ├── stratification.py # User tier classification
│   │   ├── scoring.py        # Recommendation scoring
│   │   └── modifiers.py      # Intent & season boosts
│   ├── routes/
│   │   └── recommendations.py # API endpoints
│   └── seed_data.py          # Sample data seeder
├── requirements.txt
├── run.py
└── .env.example
```

## Integration

The Flask service runs on port 5001 alongside the Express backend (port 5000). 

From Express/Flutter:
```javascript
const response = await fetch(
  `http://localhost:5001/api/recom/rank?user_id=${userId}&category_id=${categoryId}`
);
const recommendations = await response.json();
```
