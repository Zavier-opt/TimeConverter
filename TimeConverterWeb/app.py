from flask import Flask, request, jsonify, render_template
from datetime import datetime, time
import pytz
from functools import wraps
import os
from werkzeug.security import check_password_hash, generate_password_hash

app = Flask(__name__)
app.secret_key = os.urandom(24)  # 为 session 添加密钥

# 基本的请求速率限制
class RateLimit:
    def __init__(self):
        self.requests = {}
        
    def is_allowed(self, ip, limit=30, window=60):
        now = datetime.now().timestamp()
        if ip not in self.requests:
            self.requests[ip] = [(now, 1)]
            return True
            
        # 清理旧的请求记录
        self.requests[ip] = [(t, c) for t, c in self.requests[ip] if t > now - window]
        
        # 计算当前窗口内的请求总数
        total = sum(c for _, c in self.requests[ip])
        if total >= limit:
            return False
            
        self.requests[ip].append((now, 1))
        return True

rate_limiter = RateLimit()

# 请求限制装饰器
def rate_limit(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        ip = request.remote_addr
        if not rate_limiter.is_allowed(ip):
            return jsonify({
                "success": False,
                "error": "Too many requests. Please try again later."
            }), 429
        return f(*args, **kwargs)
    return decorated_function

# 输入验证
def validate_input(input_text):
    # 限制输入长度
    if len(input_text) > 100:
        return False
    # 可以添加更多验证规则
    return True

def convert_timestamp(timestamp_str):
    try:
        timestamp = float(timestamp_str)
        if timestamp > 1_000_000_000_000_000:  # Nanoseconds
            timestamp = timestamp / 1_000_000_000
        elif timestamp > 1_000_000_000_000:  # Microseconds
            timestamp = timestamp / 1_000_000
        elif timestamp > 1_000_000_000:  # Milliseconds
            timestamp = timestamp / 1000
            
        date = datetime.fromtimestamp(timestamp)
        
        return [{
            "date": date.strftime("%Y-%m-%d %H:%M:%S"),
            "timestamp_ns": int(timestamp * 1_000_000_000),
            "timestamp_us": int(timestamp * 1_000_000),
            "timestamp_ms": int(timestamp * 1000),
            "timestamp_s": int(timestamp)
        }]
    except ValueError:
        return None

def parse_datetime(datetime_str, timezone):
    try:
        formats = [
            "%Y-%m-%d %H:%M:%S",
            "%Y-%m-%d %H:%M",
            "%Y-%m-%d %H",
            "%Y-%m-%d"
        ]
        
        tz = pytz.timezone(timezone)
        
        for fmt in formats:
            try:
                parsed_date = datetime.strptime(datetime_str, fmt)
                
                # If only date is provided (no time), return both 8:30 and 15:00
                if fmt == "%Y-%m-%d":
                    results = []
                    # Morning time (8:30)
                    morning_date = datetime.combine(parsed_date.date(), time(8, 30))
                    morning_date = tz.localize(morning_date)
                    morning_timestamp = morning_date.timestamp()
                    
                    # Afternoon time (15:00)
                    afternoon_date = datetime.combine(parsed_date.date(), time(15, 0))
                    afternoon_date = tz.localize(afternoon_date)
                    afternoon_timestamp = afternoon_date.timestamp()
                    
                    results.append({
                        "date": morning_date.strftime("%Y-%m-%d %H:%M:%S"),
                        "timestamp_ns": int(morning_timestamp * 1_000_000_000),
                        "timestamp_us": int(morning_timestamp * 1_000_000),
                        "timestamp_ms": int(morning_timestamp * 1000),
                        "timestamp_s": int(morning_timestamp)
                    })
                    
                    results.append({
                        "date": afternoon_date.strftime("%Y-%m-%d %H:%M:%S"),
                        "timestamp_ns": int(afternoon_timestamp * 1_000_000_000),
                        "timestamp_us": int(afternoon_timestamp * 1_000_000),
                        "timestamp_ms": int(afternoon_timestamp * 1000),
                        "timestamp_s": int(afternoon_timestamp)
                    })
                    
                    return results
                else:
                    date = tz.localize(parsed_date)
                    timestamp = date.timestamp()
                    return [{
                        "date": date.strftime("%Y-%m-%d %H:%M:%S"),
                        "timestamp_ns": int(timestamp * 1_000_000_000),
                        "timestamp_us": int(timestamp * 1_000_000),
                        "timestamp_ms": int(timestamp * 1000),
                        "timestamp_s": int(timestamp)
                    }]
            except ValueError:
                continue
        return None
    except Exception:
        return None

@app.route('/')
@rate_limit
def index():
    timezones = pytz.all_timezones
    default_timezone = 'America/Chicago'
    return render_template('index.html', timezones=timezones, default_timezone=default_timezone)

@app.route('/convert', methods=['POST'])
@rate_limit
def convert():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"success": False, "error": "Invalid request"}), 400
            
        input_text = data.get('input', '').strip()
        timezone = data.get('timezone', 'America/Chicago')
        
        # 输入验证
        if not validate_input(input_text):
            return jsonify({
                "success": False,
                "error": "Invalid input format or length"
            }), 400
            
        # 验证时区
        if timezone not in pytz.all_timezones:
            return jsonify({
                "success": False,
                "error": "Invalid timezone"
            }), 400
        
        # 转换逻辑保持不变
        result = convert_timestamp(input_text)
        if result:
            return jsonify({"success": True, "results": result})
            
        result = parse_datetime(input_text, timezone)
        if result:
            return jsonify({"success": True, "results": result})
            
        return jsonify({
            "success": False,
            "error": "Invalid input format. Please enter a timestamp or date in YYYY-MM-DD [HH[:MM[:SS]]] format"
        })
    except Exception as e:
        app.logger.error(f"Error processing request: {str(e)}")
        return jsonify({
            "success": False,
            "error": "An internal error occurred"
        }), 500

# 添加安全相关的 HTTP 头
@app.after_request
def add_security_headers(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    return response

if __name__ == '__main__':
    app.run(
        debug=True,  # 开发模式
        host='0.0.0.0',
        port=5001
    ) 