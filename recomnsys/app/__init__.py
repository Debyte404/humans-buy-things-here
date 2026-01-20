"""
Flask Application Factory
Initializes Flask app with MongoDB and registers blueprints.
"""
from flask import Flask
from flask_pymongo import PyMongo

mongo = PyMongo()


def create_app():
    """Create and configure the Flask application."""
    app = Flask(__name__)
    
    # Load configuration
    from app.config import Config
    app.config.from_object(Config)
    
    # Initialize MongoDB
    mongo.init_app(app)
    
    # Register blueprints
    from app.routes.recommendations import bp as recommendations_bp
    app.register_blueprint(recommendations_bp, url_prefix='/api/recom')
    
    # Health check endpoint
    @app.route('/')
    def health():
        return {
            'service': 'RecomnSys',
            'status': 'healthy',
            'version': '1.0.0'
        }
    
    return app
