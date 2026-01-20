"""
Project Upsell - Flask Recommendation Engine
Entry point for the recommendation microservice.
"""
import os
from dotenv import load_dotenv

load_dotenv()

from app import create_app

app = create_app()

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5001))
    debug = os.environ.get('FLASK_DEBUG', '0') == '1'
    
    print(f"🚀 RecomnSys starting on port {port}")
    print(f"📊 Debug mode: {'ON' if debug else 'OFF'}")
    
    app.run(host='0.0.0.0', port=port, debug=debug)
