# TimeConverter

A utility for converting between timestamps and human-readable dates, available as both a macOS app and a web application.

## Features

- Convert timestamps to dates and vice versa
- Support for multiple timestamp formats:
  - Nanoseconds (ns)
  - Microseconds (μs)
  - Milliseconds (ms)
  - Seconds (s)
- Flexible date input format (YYYY-MM-DD [HH[:MM[:SS]]])
- Multiple timezone support
- Copy results with keyboard shortcuts

## macOS App Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/TimeConverter.git
   cd TimeConverter
   ```

2. Build the project:
   ```bash
   swift build
   ```

3. Run the application:
   ```bash
   swift run TimeConverter
   ```

## Web Version

### Local Development

1. Navigate to the web application directory:
   ```bash
   cd TimeConverterWeb
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the application:
   ```bash
   python app.py
   ```

The web app will be available at:
- Local access: `http://localhost:5001`
- Network access: `http://your-ip:5001`

### Remote Access (Using Ngrok)

1. Install Ngrok:
   ```bash
   brew install ngrok  # macOS
   ```

2. Start the application with Ngrok:
   ```bash
   ./start.sh
   ```

The web app will be available at:
- `https://fast-raven-national.ngrok-free.app`

### Web Features
- Browser-based interface
- Same conversion capabilities as the macOS app
- Accessible from any device with a web browser
- Secure HTTPS access through Ngrok
- Rate limiting and input validation

## Usage

### macOS App

1. Timestamps:
   - Seconds: `1709913000`
   - Milliseconds: `1709913000000`
   - Microseconds: `1709913000000000`
   - Nanoseconds: `1709913000000000000`

2. Date formats:
   - Full datetime: `2024-03-15 14:30:45`
   - Date with time: `2024-03-15 14:30`
   - Date with hour: `2024-03-15 14`
   - Date only: `2024-03-15` (will show times for both 8:30 and 15:00)

### Web Interface

1. Access the web application through your browser
2. Enter timestamp or date in the input field
3. Select timezone from the dropdown
4. Click "Convert" or press Enter
5. Copy results using the copy button or keyboard shortcuts

### Keyboard Shortcuts

macOS App:
- Toggle window: `Command + Shift + Space`
- Copy results: `Command + C`
- Select all: `Command + A`
- Convert: `Enter`

Web Version:
- Convert: `Enter`
- Copy results: `Command + C` (macOS) or `Ctrl + C` (Windows/Linux)

## Development

### Requirements

macOS App:
- macOS 12.0 or later
- Swift 5.5 or later
- Xcode 13.0 or later (optional)

Web App:
- Python 3.x
- Flask
- pytz
- Ngrok (for remote access)

### Dependencies

macOS App:
- [HotKey](https://github.com/soffes/HotKey) - For global keyboard shortcut support

Web App:
- Flask - Web framework
- pytz - Timezone support
- gunicorn - Production server (optional)

### Building

macOS App:
1. Build the project:
   ```bash
   swift build
   ```

2. Run in development mode:
   ```bash
   swift run TimeConverter
   ```

Web App:
1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run in development mode:
   ```bash
   python app.py
   ```

## License

[Your chosen license]