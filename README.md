# TimeConverter

A macOS utility for converting between timestamps and human-readable dates.

## Features

- Convert timestamps to dates and vice versa
- Support for multiple timestamp formats:
  - Nanoseconds (ns)
  - Microseconds (μs)
  - Milliseconds (ms)
  - Seconds (s)
- Flexible date input format (YYYY-MM-DD [HH[:MM[:SS]]])
- Global hotkey support (Command + Shift + Space)
- Status bar quick access
- Multiple timezone support
- Copy results with keyboard shortcuts

## Installation

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

## Usage

### Input Formats

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

### Keyboard Shortcuts

- Toggle window: `Command + Shift + Space`
- Copy results: `Command + C`
- Select all: `Command + A`
- Convert: `Enter`

## Development

### Requirements

- macOS 12.0 or later
- Swift 5.5 or later
- Xcode 13.0 or later (optional)

### Dependencies

- [HotKey](https://github.com/soffes/HotKey) - For global keyboard shortcut support

### Building

1. Build the project:
   ```bash
   swift build
   ```

2. Run in development mode:
   ```bash
   swift run TimeConverter
   ```