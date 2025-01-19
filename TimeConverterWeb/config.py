class Config:
    DEBUG = True
    HOST = 'localhost'
    PORT = 5001

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False 