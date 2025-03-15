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
        // 注入基础样式
        const style = document.createElement('style');
        style.innerHTML = `
            body {
                background-color: #f0eee6 !important;
                color: #333333 !important;
                line-height: 2.0 !important; /* 增大行间距 */
                font-family: Georgia, serif !important;
            }
             /* 强制应用背景色到所有元素 */
             html, body, div, article, section, main, .content, .container, .wrapper {
                 background-color: #f0eee6 !important;
             }
             
             /* 移除可能的背景图片 */
             body, div, article, section, main {
                 background-image: none !important;
             }
            /* 仿生阅读加粗样式 - 只加粗不改变其他 */
            .bionic-bold {
                font-weight: 700 !important;
            }
        `;
        document.head.appendChild(style);

        // 简化版本的仿生阅读实现 - 只加粗文本的前几个字母，不改变布局
        function applyBionicReading() {
            // 遍历所有文本节点并替换内容
            function walkTextNodes(node) {
                if (node.nodeType === Node.TEXT_NODE && node.nodeValue.trim().length > 0) {
                    // 跳过已经处理过的节点
                    if (node.parentNode.classList && node.parentNode.classList.contains('bionic-processed')) {
                        return;
                    }
                    
                    // 创建一个包含处理后文本的容器
                    const container = document.createElement('span');
                    container.classList.add('bionic-processed');
                    
                    // 处理文本中的每个单词
                    const text = node.nodeValue;
                    let result = '';
                    let inWord = false;
                    let wordStart = 0;
                    
                    for (let i = 0; i <= text.length; i++) {
                        const char = i < text.length ? text[i] : '';
                        const isWordChar = /[\\w\\u4e00-\\u9fa5]/.test(char); // 包括中文字符
                        
                        if (isWordChar && !inWord) {
                            // 单词开始
                            wordStart = i;
                            inWord = true;
                        } else if (!isWordChar && inWord) {
                            // 单词结束
                            const word = text.substring(wordStart, i);
                            if (word.length > 0) {
                                // 确定加粗部分的长度 (1-3个字母)
                                let boldLength = Math.ceil(word.length * 0.4); // 40% 的字母加粗
                                if (boldLength > 3) boldLength = 3; // 最多3个字母
                                if (boldLength < 1) boldLength = 1; // 至少1个字母
                                
                                const boldPart = word.substring(0, boldLength);
                                const normalPart = word.substring(boldLength);
                                
                                result += '<span class="bionic-bold">' + boldPart + '</span>' + normalPart;
                            }
                            result += char; // 添加分隔符（空格、标点等）
                            inWord = false;
                        } else if (isWordChar && inWord) {
                            // 继续在单词中
                            continue;
                        } else {
                            // 不在单词中的字符（空格、标点等）
                            result += char;
                        }
                    }
                    
                    // 替换原始节点
                    container.innerHTML = result;
                    node.parentNode.replaceChild(container, node);
                } else if (node.nodeType === Node.ELEMENT_NODE) {
                    // 跳过特定标签和已处理的节点
                    if (['SCRIPT', 'STYLE', 'NOSCRIPT', 'IFRAME', 'OBJECT', 'EMBED', 'BUTTON', 'SELECT', 'TEXTAREA'].includes(node.tagName) ||
                        (node.classList && node.classList.contains('bionic-processed'))) {
                        return;
                    }
                    
                    // 处理子节点 (创建副本以避免实时集合问题)
                    const childNodes = Array.from(node.childNodes);
                    childNodes.forEach(walkTextNodes);
                }
            }
            
            try {
                // 尝试找到主要内容区域
                const contentContainers = document.querySelectorAll('article, .article, main, .content, .post-content, .entry-content');
                
                if (contentContainers.length > 0) {
                    // 如果找到特定内容容器，只处理这些区域
                    contentContainers.forEach(container => {
                        walkTextNodes(container);
                    });
                } else {
                    // 如果没有找到特定容器，处理body下的段落和列表
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
            QMessageBox.critical(self, "Error", f"样式应用失败: {str(e)}")  

    def toggle_focus_mode(self):
        focus_mode_style = """
        // 简单的聚焦模式 - 只有上下模糊效果，无控制按钮
        const style = document.createElement('style');
        style.innerHTML = `
            /* 添加遮罩层 */
            body::before, body::after {
                content: '';
                position: fixed;
                left: 0;
                right: 0;
                z-index: 9999;
                pointer-events: none;
            }
            
            /* 上部遮罩 */
            body::before {
                top: 0;
                height: calc(50vh - 100px);
                background: linear-gradient(to bottom, 
                    rgba(240, 238, 230, 0.95) 0%, 
                    rgba(240, 238, 230, 0.85) 80%, 
                    rgba(240, 238, 230, 0) 100%);
                backdrop-filter: blur(3px);
            }
            
            /* 下部遮罩 */
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
        return "聚焦模式已启用";
        """
        try:
            result = self.driver.execute_script(focus_mode_style)
        except Exception as e:
            QMessageBox.critical(self, "Error", f"聚焦模式切换失败: {str(e)}")

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