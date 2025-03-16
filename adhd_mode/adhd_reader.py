from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from PyQt5.QtWidgets import QApplication, QMainWindow, QPushButton, QLabel, QVBoxLayout, QWidget, QInputDialog, QMessageBox
from PyQt5.QtCore import QTimer, Qt
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
import sys

class ADHDReader(QMainWindow):
    def __init__(self):
        super().__init__()
        self.initUI()
        try:
            self.setup_browser()
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to initialize browser: {str(e)}")
            sys.exit(1)

    def initUI(self):
        self.setWindowTitle('ADHD Reader Mode')
        self.setGeometry(100, 100, 400, 300)

        # Create central widget and layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)

        # Create buttons
        self.url_button = QPushButton('Open URL', self)
        self.font_button = QPushButton('Change Font Style', self)
        self.focus_mode_button = QPushButton('Enable Focus Mode', self)
        
        # Add widgets to layout
        layout.addWidget(self.url_button)
        layout.addWidget(self.font_button)
        layout.addWidget(self.focus_mode_button)

        # Connect buttons to functions
        self.url_button.clicked.connect(self.open_url)
        self.font_button.clicked.connect(self.change_font)
        self.focus_mode_button.clicked.connect(self.toggle_focus_mode)

    def setup_browser(self):
        try:
            # Set up Chrome options
            chrome_options = Options()
            chrome_options.add_argument('--start-maximized')
            
            # Try to use an existing Chrome installation
            chrome_options.add_argument("--no-sandbox")
            chrome_options.add_argument("--disable-dev-shm-usage")
            
            # Try direct approach first
            try:
                self.driver = webdriver.Chrome(options=chrome_options)
            except Exception as e:
                print(f"First attempt failed: {e}")
                # Try with webdriver-manager as fallback
                driver_path = ChromeDriverManager().install()
                service = Service(driver_path)
                self.driver = webdriver.Chrome(service=service, options=chrome_options)
                
        except Exception as e:
            print(f"Error setting up browser: {e}")
            raise

    def open_url(self):
        url, ok = QInputDialog.getText(self, 'Open URL', 'Enter URL:')
        if ok and url:
            # Add http:// prefix if not present
            if not url.startswith(('http://', 'https://')):
                url = 'https://' + url
            try:
                self.driver.get(url)
            except Exception as e:
                QMessageBox.warning(self, "Error", f"Failed to open URL: {str(e)}")

    def change_font(self):
        try:
            WebDriverWait(self.driver, 10).until(
                EC.presence_of_element_located((By.TAG_NAME, "body"))
            )
        except Exception as e:
            QMessageBox.warning(self, "Error", f"Page not loaded: {str(e)}")
            return

        bionic_style_script = """
        // Injecting base styles
        const style = document.createElement('style');
        style.innerHTML = `
            body {
                background-color: #f0eee6 !important;
                color: #333333 !important;
                line-height: 2.0 !important; /* Increase line spacing */
                font-family: Georgia, serif !important;
            }
             /* Force a background color to all elements */
             html, body, div, article, section, main, .content, .container, .wrapper {
                 background-color: #f0eee6 !important;
             }
             
             /* Remove possible background images */
             body, div, article, section, main {
                 background-image: none !important;
             }
            /* Bionic Reading Bold Style - Only bold without changing other things */
            .bionic-bold {
                font-weight: 700 !important;
            }
        `;
        document.head.appendChild(style);

        // A simplified version of the Bionic Reader implementation - only the first few letters of the text are bolded, without changing the layout
        function applyBionicReading() {
            // Iterate over all text nodes and replace the content
            function walkTextNodes(node) {
                if (node.nodeType === Node.TEXT_NODE && node.nodeValue.trim().length > 0) {
                    // Skip nodes that have already been processed
                    if (node.parentNode.classList && node.parentNode.classList.contains('bionic-processed')) {
                        return;
                    }
                    
                    // Create a container to contain the processed text
                    const container = document.createElement('span');
                    container.classList.add('bionic-processed');
                    
                    // Process each word in the text
                    const text = node.nodeValue;
                    let result = '';
                    let inWord = false;
                    let wordStart = 0;
                    
                    for (let i = 0; i <= text.length; i++) {
                        const char = i < text.length ? text[i] : '';
                        const isWordChar = /[\\w\\u4e00-\\u9fa5]/.test(char); // Including Chinese characters
                        
                        if (isWordChar && !inWord) {
                            // Word Start
                            wordStart = i;
                            inWord = true;
                        } else if (!isWordChar && inWord) {
                            // Word End
                            const word = text.substring(wordStart, i);
                            if (word.length > 0) {
                                // Determine the length of the bold part (1-3 letters)
                                let boldLength = Math.ceil(word.length * 0.4); // 40% bold letters
                                if (boldLength > 3) boldLength = 3; // Up to 3 letters
                                if (boldLength < 1) boldLength = 1; // At least 1 letter
                                
                                const boldPart = word.substring(0, boldLength);
                                const normalPart = word.substring(boldLength);
                                
                                result += '<span class="bionic-bold">' + boldPart + '</span>' + normalPart;
                            }
                            result += char; // Add separators (spaces, punctuation, etc.)
                            inWord = false;
                        } else if (isWordChar && inWord) {
                            // Continue in word
                            continue;
                        } else {
                            // Characters that are not in words (spaces, punctuation, etc.）
                            result += char;
                        }
                    }
                    
                    // Replace the original node
                    container.innerHTML = result;
                    node.parentNode.replaceChild(container, node);
                } else if (node.nodeType === Node.ELEMENT_NODE) {
                    // Skip nodes with specific tags and already processed
                    if (['SCRIPT', 'STYLE', 'NOSCRIPT', 'IFRAME', 'OBJECT', 'EMBED', 'BUTTON', 'SELECT', 'TEXTAREA'].includes(node.tagName) ||
                        (node.classList && node.classList.contains('bionic-processed'))) {
                        return;
                    }
                    
                    // Handle child nodes (create copies to avoid live collection issues)
                    const childNodes = Array.from(node.childNodes);
                    childNodes.forEach(walkTextNodes);
                }
            }
            
            try {
                // Try to find the main content area
                const contentContainers = document.querySelectorAll('article, .article, main, .content, .post-content, .entry-content');
                
                if (contentContainers.length > 0) {
                    // If specific content containers are found, only those areas are processed
                    contentContainers.forEach(container => {
                        walkTextNodes(container);
                    });
                } else {
                    // If the specified container is not found, process the paragraphs and lists under body
                    const textElements = document.querySelectorAll('p, li, h1, h2, h3, h4, h5, h6');
                    textElements.forEach(el => {
                        walkTextNodes(el);
                    });
                }
                
                return "Bionic Reading mode applied successfully!";
            } catch (error) {
                console.error("Error applying bionic reading:", error);
                return "Error: " + error.message;
            }
        }
        
        return applyBionicReading();
        """

        try:
            result = self.driver.execute_script(bionic_style_script)
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Style application failed: {str(e)}")  

    def toggle_focus_mode(self):
        focus_mode_style = """
        // Simple focus mode - only up and down blur effect, no control buttons
        const style = document.createElement('style');
        style.innerHTML = `
            /* Add a mask layer */
            body::before, body::after {
                content: '';
                position: fixed;
                left: 0;
                right: 0;
                z-index: 9999;
                pointer-events: none;
            }
            
            /* Upper Mask */
            body::before {
                top: 0;
                height: calc(50vh - 100px);
                background: linear-gradient(to bottom, 
                    rgba(240, 238, 230, 0.95) 0%, 
                    rgba(240, 238, 230, 0.85) 80%, 
                    rgba(240, 238, 230, 0) 100%);
                backdrop-filter: blur(3px);
            }
            
            /* Lower Mask */
            body::after {
                bottom: 0;
                height: calc(50vh - 100px);
                background: linear-gradient(to bottom, 
                    rgba(240, 238, 230, 0.95) 0%, 
                    rgba(240, 238, 230, 0.85) 80%, 
                    rgba(240, 238, 230, 0) 100%);
                backdrop-filter: blur(8px);
            }
        `;
        
        document.head.appendChild(style);
        return "Focus mode enabled";
        """
        try:
            result = self.driver.execute_script(focus_mode_style)
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Focus mode switching failed: {str(e)}")

    def closeEvent(self, event):
        try:
            if hasattr(self, 'driver'):
                self.driver.quit()
        except Exception as e:
            print(f"Error closing browser: {e}")
        event.accept()

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = ADHDReader()
    ex.show()
    sys.exit(app.exec_()) 
