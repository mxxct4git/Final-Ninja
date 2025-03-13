import time
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

if __name__ == '__main__':
    # 启动 WebDriver（确保已安装 chromedriver 并匹配 Chrome 版本）
    options = webdriver.ChromeOptions()
    options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")  # 连接到已打开的 Chrome 浏览器
    driver = webdriver.Chrome(options=options)

    # 保存原始标签页
    original_window = driver.current_window_handle

    # 创建并切换到新标签页
    driver.switch_to.new_window('tab')
    driver.get('https://learning.monash.edu/my/')

    # 获取页面内容
    page_content = driver.page_source

    # 使用 BeautifulSoup 解析页面
    soup = BeautifulSoup(page_content, 'html.parser')

    # 查找特定的 card-deck div
    course_links = soup.find_all('a', class_='aalink coursename mr-2 mb-1')

    # 查找包含特定数字的元素
    target_numbers = ['9136', '5057', '5225', '5136']

    # 使用字典存储去重后的链接和对应的 target number
    filtered_links = {}
    
    # 遍历并筛选链接
    for link in course_links:
        course_text = link.text.strip().replace("\n", " ")
        course_url = link.get('href')
        
        # 检查每个目标数字
        for number in target_numbers:
            if number in course_text:
                filtered_links[course_url] = number
    
    # 打印去重后的结果
    for url, number in filtered_links.items():
        print(f"课程编号: {number}\t课程链接: {url}")
