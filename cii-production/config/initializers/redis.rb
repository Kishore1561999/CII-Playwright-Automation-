REDIS_URL = 'redis://127.0.0.1:6379/0'
$redis = Redis.new(url: REDIS_URL, driver: 'ruby')