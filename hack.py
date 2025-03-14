# import time
# import requests
# from bs4 import BeautifulSoup
# from selenium import webdriver
# from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
# from selenium.webdriver.common.by import By
# from selenium.webdriver.support.ui import WebDriverWait
# from selenium.webdriver.support import expected_conditions as EC
# from config import OPENAI_API_KEY, OPENAI_API_URL
#
#
# def send_to_ai_agent(text):
#     headers = {
#         "Authorization": f"Bearer {OPENAI_API_KEY}",
#         "Content-Type": "application/json"
#     }
#
#     data = {
#         "model": "gpt-4",
#         "messages": [
#             {"role": "system", "content": "You are a helpful AI assistant."},
#             {"role": "user", "content": f"Here is the Week 1 Overview: {text}"}
#         ]
#     }
#
#     response = requests.post(OPENAI_API_URL, json=data, headers=headers)
#
#     if response.status_code == 200:
#         print("AI Response:", response.json()["choices"][0]["message"]["content"])
#     else:
#         print("Error:", response.text)
#
#
# if __name__ == '__main__':
#     # 启动 WebDriver（确保已安装 chromedriver 并匹配 Chrome 版本）
#     options = webdriver.ChromeOptions()
#     options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")  # 连接到已打开的 Chrome 浏览器
#     driver = webdriver.Chrome(options=options)
#
#     # 保存原始标签页
#     original_window = driver.current_window_handle
#
#     # 创建并切换到新标签页
#     driver.switch_to.new_window('tab')
#     driver.get('https://learning.monash.edu/my/')
#
#     # 等待页面加载
#     time.sleep(3)
#
#     js_code = """
#         function shouldAddBorder(element) {
#             // 仅对 class="mt-3"、"d-flex"、"w-100 text-truncate" 的 div 添加边框
#             if (element.tagName.toLowerCase() === "div") {
#                 if ((element.classList.length === 1 && (element.classList.contains("mt-3") || element.classList.contains("d-flex"))) ||
#                     (element.classList.length === 2 && element.classList.contains("w-100") && element.classList.contains("text-truncate")) ) {
#                     return true; // 如果符合条件，返回添加边框的标识
#                 }
#             }
#
#             // 仅对 class="mb-0" 的 small 标签添加边框
#             if (element.tagName.toLowerCase() === "small" && element.classList.length === 1 && element.classList.contains("mb-0")) {
#                 return true; // 如果符合条件，返回添加边框的标识
#             }
#
#             // 仅对 data-action="view-event" 的 a 标签添加边框
#             if (element.tagName.toLowerCase() === "a" && element.getAttribute("data-action") === "view-event") {
#                 return true; // 如果符合条件，返回添加边框的标识
#             }
#
#             return false; // 不符合条件
#         }
#
#         var elements = document.querySelectorAll("div, small, a"); // 获取所有 div, small, a 标签
#         elements.forEach(function(element) {
#             if (shouldAddBorder(element)) {
#                 var color = "#" + Math.floor(Math.random()*16777215).toString(16); // 生成随机颜色
#                 element.style.border = "2px solid " + color;
#             }
#         });
#         """
#     driver.execute_script(js_code)
#
#     # 暂停看效果
#     time.sleep(300)
#
#     # 获取页面内容
#     page_content = driver.page_source
#
#     # 使用 BeautifulSoup 解析页面
#     soup = BeautifulSoup(page_content, 'html.parser')
#
#     # 查找特定的 card-deck div
#     course_links = soup.find_all('a', class_='aalink coursename mr-2 mb-1')
#
#     # 查找包含特定数字的元素
#     target_numbers = ['9136', '5057', '5225', '5136','5046','5126']
#
#     # 使用字典存储去重后的链接和对应的 target number
#     filtered_links = {}
#
#     # 遍历并筛选链接
#     for link in course_links:
#         course_text = link.text.strip().replace("\n", " ")
#         course_url = link.get('href')
#
#         # 检查每个目标数字
#         for number in target_numbers:
#             if number in course_text:
#                 filtered_links[course_url] = number
#
#     # 打印去重后的结果
#     for url, number in filtered_links.items():
#         print(f"课程编号: {number}\t课程链接: {url}")
#
#     # 选择课程
#     user_chosen_course = '5225'
#     chosen_url = None
#     for url, number in filtered_links.items():
#         if number == user_chosen_course:
#             chosen_url = url
#             break
#
#     if chosen_url:
#         driver.get(chosen_url)
#         week1_url = chosen_url + '&section=7'  # 第一周链接
#         week2_url = chosen_url + '&section=11'  # 第二周链接
#
#         # 打开第一周链接
#         driver.get(week1_url)
#
#         # 查找并抓取 overview的文本内容
#         try:
#             overview_div = WebDriverWait(driver, 10).until(
#                 EC.presence_of_element_located((By.ID, "collapseOverviewSection"))
#             )
#             print("第一周内容:\n", overview_div.text)
#             send_to_ai_agent(overview_div.text)
#         except Exception as e:
#             print("未找到课程介绍内容:", e)
#
#     else:
#         print(f"Course {user_chosen_course} not found")
