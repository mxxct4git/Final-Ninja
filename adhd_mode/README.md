# ADHD Reader Mode

A Python application that helps make web reading more ADHD-friendly by providing various accessibility features.

## Features

1. **Font Adjustment**: Change webpage fonts to sans-serif and adjust boldness for better readability
2. **Reading Mode**: Transform the page background to a soft color and optimize text display
3. **Focus Tool**: Blur the background and only show the selected area clearly
4. **Break Timer**: 20-minute timer with break reminders and screen dimming

## Installation

1. Make sure you have Python 3.7+ installed
2. Install the required dependencies:
```bash
pip install -r requirements.txt
```
3. Make sure you have Google Chrome installed

## Usage

1. Run the application:
```bash
python adhd_reader.py
```

2. Use the buttons in the interface to:
   - Open a URL
   - Change font style
   - Toggle reading mode
   - Toggle focus mode
   - Monitor break timer

3. The break timer will automatically:
   - Count down from 20 minutes
   - Notify you when it's break time
   - Dim the screen during breaks
   - Reset after 5 minutes

## Troubleshooting

### ChromeDriver Issues

If you encounter errors related to ChromeDriver:

1. **Compatibility Issues**: The application now tries to use your system's Chrome directly. If that fails, it will download a compatible ChromeDriver.

2. **Manual ChromeDriver Installation**: If automatic installation fails, you can:
   - Download ChromeDriver manually from https://chromedriver.chromium.org/downloads
   - Make sure to download the version that matches your Chrome browser
   - Place the chromedriver.exe in the same directory as the script
   - Edit the script to use the local path:
     ```python
     self.driver = webdriver.Chrome(service=Service("./chromedriver.exe"), options=chrome_options)
     ```

3. **Chrome Version**: Ensure your Chrome browser is up to date

### PyQt5 Issues

If you encounter PyQt5-related errors:

1. Try reinstalling PyQt5:
   ```bash
   pip uninstall PyQt5
   pip install PyQt5==5.15.9
   ```

2. On Windows, you might need to install additional dependencies:
   ```bash
   pip install pyqt5-tools
   ```

## Notes

- The application uses Selenium WebDriver to control Chrome
- The focus mode can be toggled on/off as needed
- Take regular breaks when prompted for better productivity 