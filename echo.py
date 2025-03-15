import time
import json
import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from config import my_js_code, target_course, specific_week_js_code, timeline_js_code
from dotenv import load_dotenv
import os
from colorama import Fore, Style, init

load_dotenv()
init(autoreset=True)
load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENAI_API_BASE = os.getenv("OPENAI_API_BASE")


def send_to_ai_agent(user_prompt):
    print("🤖 Send to AI Agent...")
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json"
    }

    data = {
        "model": "gpt-4",
        "messages": [
            {"role": "system", "content": "You are a helpful AI assistant."},
            {"role": "user", "content": user_prompt}
        ]
    }

    response = requests.post(OPENAI_API_BASE, json=data, headers=headers)

    if response.status_code == 200:
        try:
            return response.json()["choices"][0]["message"]["content"]
        except (KeyError, IndexError) as e:
            print("Unexpected response structure:", response.json())
            return "Failed to parse AI response"
    else:
        print("Error:", response.status_code, response.text)
        return "API request failed"

def get_assignment_status(timeline_data):
    print("🔍 Check Assignment Status...")
    status_dict = {}

    # 遍历 timeline_data
    for entry in timeline_data:
        for task in entry["任务列表"]:
            status = task["状态"]  # 获取任务状态
            task_name = task["任务"]  # 获取任务名称

            # 按状态分组任务
            if status not in status_dict:
                status_dict[status] = []
            status_dict[status].append(task_name)
 
    return json.dumps(status_dict, ensure_ascii=False, indent=4)

def get_total_assignments(timeline_data):
    assignment_count = {}
    total_count = 0  # 统计所有任务的总数

    # 遍历 timeline_data
    for entry in timeline_data:
        date = entry["日期"]
        count = len(entry["任务列表"])  # 计算该日期下任务的数量
        assignment_count[date] = count
        total_count += count  # 累加任务总数

    # 添加总任务数
    assignment_count["total_count"] = total_count
    print(f"Total Assignments: {total_count}")
    return total_count

# 查询所有的课程
def get_all_courses():
    target_courses = [f"FIT{course}" for course in target_course]
    return {"courses": target_courses}

# 抓取Timeline内容 
def get_timeline_content():
    print("🚀 Starting timeline extraction...")
    print("=" * 50)
    # 启动 WebDriver（确保已安装 chromedriver 并匹配 Chrome 版本）
    options = webdriver.ChromeOptions()
    options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")  # 连接到已打开的 Chrome 浏览器
    driver = webdriver.Chrome(options=options)

    # 创建并切换到新标签页
    print("🌐 Connecting to Chrome browser...")
    print("📑 Creating new tab and loading student homepage...")
    driver.switch_to.new_window('tab')
    driver.get('https://home.student.monash/')
    time.sleep(8)
   
    for i in range(10):
        print(f"⏳ Loading page... {i*10}%", end='\r')
        time.sleep(1)
    print("\n✨ Page loaded successfully!")

    print("🎨 Applying timeline highlights...")

    # 高亮
    driver.execute_script(timeline_js_code)
    # time.sleep(10)

    # 获取页面内容
    print("🔍 Parsing timeline data...")
    page_content = driver.page_source

    # 使用 BeautifulSoup 解析页面
    soup = BeautifulSoup(page_content, 'html.parser')
    timeline_data = []
    
    # 找到所有 class="day_day__xedDk" 的 div
    print("📊 Processing timeline entries...")
    days = soup.find_all('li', class_="day_dayWithAssessments__Go2a-")


    if not days:
        print("⚠️ 未找到任何 timeline 数据")
        return []

    total_days = len(days[1:])
    for idx, day in enumerate(days[1:], 1):
        print(f"📅 Processing day {idx}/{total_days}", end='\r')

    # 遍历从索引 1 开始的所有元素
    print("\n🎯 Calculating assignment statistics...")
    for day in days[1:]:
        # 获取日期（h3标签）
        date_tag = day.find('h3')
        date_text = date_tag.get_text(strip=True) if date_tag else "未知日期"

        # 获取所有任务（遍历 ul > button）
        assignments = []
        for item in day.find_all('button', class_='day_item__9bhZH'):
            # 获取时间（span标签）
            time_tag = item.find('span', class_='day_dueTime__Q+9UA')
            time_text = time_tag.get_text(strip=True) if time_tag else "未知时间"

            # 获取任务标题（h4标签）
            title_tag = item.find('h4')
            title_text = title_tag.get_text(strip=True) if title_tag else "未知任务"

            # 获取提交状态（span class="status_status__CwfUR"）
            status_tag = item.find('span', class_='status_status__CwfUR')
            status_text = status_tag.get_text(strip=True) if status_tag else "未知状态"

            assignments.append({
                "时间": time_text,
                "任务": title_text,
                "状态": status_text
            })

        # 将日期与任务信息添加到 timeline
        timeline_data.append({
            "日期": date_text,
            "任务列表": assignments
        })
    
    assignment_status = get_assignment_status(timeline_data)

    total_count = get_total_assignments(timeline_data)

    user_prompt = "Generate me a 48h-study plan please. "

    print("🤖 Generating AI study plan...")
    ai_summary = send_to_ai_agent(str(timeline_data))

    print("\n📈 Preparing timeline report...")
    timeline_report = {
        "total_count": total_count,
        "assignment_status": assignment_status,
        "ai_summary": ai_summary    
    }

    driver.quit()

    print("\n✅ Timeline extraction completed!")

    print("=" * 50)
    print(f"📝 Total assignments found: {total_count}")
    print("🔄 Status breakdown:")
    for status, tasks in json.loads(assignment_status).items():
        print(f"  • {status}: {len(tasks)} tasks")

    print("=" * 50)

    # Print timeline
    print(f"\n{Fore.BLUE}📅 Timeline Details:{Style.RESET_ALL}")
    for entry in timeline_data:
        print(f"\n{Fore.CYAN}  {entry['日期']}{Style.RESET_ALL}")
        for task in entry['任务列表']:
            status_icon = {
                "已提交": "✅",
                "未提交": "❌",
                "进行中": "⏳",
                "未知状态": "❓"
            }.get(task['状态'], "❓")
            
            print(f"    {status_icon} {task['时间']} - {task['任务']}")


    print("=" * 50)
    return json.dumps(timeline_report, ensure_ascii=False, indent=4)


# 查询指定课程
def get_course(course_id):
    print(f"🎓 Fetching course information for FIT{course_id}...")
    print("=" * 50)
    # 启动 WebDriver（确保已安装 chromedriver 并匹配 Chrome 版本）
    options = webdriver.ChromeOptions()
    print("🌐 Connecting to Chrome browser...")
    options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")  # 连接到已打开的 Chrome 浏览器
    driver = webdriver.Chrome(options=options)
    response = ""

    # 保存原始标签页
    original_window = driver.current_window_handle

    # 创建并切换到新标签页
    print("📑 Creating new tab...")
    driver.switch_to.new_window('tab')

    print("🔄 Loading Monash learning system...")
    driver.get('https://learning.monash.edu/my/')

    for i in range(3):
        print(f"⏳ Loading page... {i*33}%", end='\r')
        time.sleep(1)
    print("\n✨ Page loaded successfully!")

    # 等待页面加载
    time.sleep(3)

    # 添加随机边框
    driver.execute_script(my_js_code)

    # 暂停看效果
    time.sleep(3)

    # 获取页面内容
    print("🔍 Scanning for course links...")
    page_content = driver.page_source

    # 使用 BeautifulSoup 解析页面
    soup = BeautifulSoup(page_content, 'html.parser')


    # 查找特定的 card-deck div
    course_links = soup.find_all('a', class_='aalink coursename mr-2 mb-1')

    # 使用字典存储去重后的链接和对应的 target number
    filtered_links = {}

    # 遍历并筛选链接
    for link in course_links:
        course_text = link.text.strip().replace("\n", " ")
        course_url = link.get('href')

        # 检查每个目标数字
        for number in target_course:
            if number in course_text:
                filtered_links[course_url] = number

    # 打印去重后的结果
    print(f"\n{Fore.CYAN}📚 Available Courses:{Style.RESET_ALL}")
    print("=" * 50)
    print(f"{Fore.YELLOW}{'Course ID':<15}{'Course URL':<45}{Style.RESET_ALL}")
    print("=" * 50)
    
    # Format course links output
    for url, number in filtered_links.items():
        shortened_url = url[:42] + "..." if len(url) > 45 else url
        print(f"FIT{number:<11} {shortened_url}")
    print("=" * 50)

    # 选择课程
    chosen_url = None
    for url, number in filtered_links.items():
        if number == str(course_id):
            chosen_url = url
            break

    if chosen_url:
        driver.get(chosen_url)
        week1_url = chosen_url + '&section=7'  # 第一周链接
        week2_url = chosen_url + '&section=11'  # 第二周链接

        # 打开第一周链接
        driver.get(week1_url)
        driver.execute_script(specific_week_js_code)

        # 查找并抓取 overview的文本内容
        try:
            overview_div = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "collapseOverviewSection"))
            )

            user_prompt = "Generate me a course explanation please according to the following overview I give you. You need to be concise. Answer briefly within 250 words."  + overview_div.text
            response = send_to_ai_agent(user_prompt)
            # Format and print AI response
            print(f"\n{Fore.CYAN}🤖 AI Course Summary:{Style.RESET_ALL}")
            print("═" * 50)
            print(f"{Fore.GREEN}{response}{Style.RESET_ALL}")
            print("═" * 50)
            
            
        except Exception as e:
            print("Exception:", e)
            response = "Failed to generate the overview content" 

    else:
        print(f"Course {course_id} not found")
        response = "Course not found"

    # 关闭 WebDriver
    print("✅ Course information retrieval completed!")
    print("=" * 50)
    driver.quit()

    return {course_id: response}

def get_quiz(course_id):
    ai_overview_summary = str(get_course(course_id))
    user_prompt = "Generate me 10 multiple-choice quiz based on the course overview summary I give you. " + ai_overview_summary
    ai_quiz = send_to_ai_agent(user_prompt)
    print(ai_quiz)
    return {course_id: ai_quiz}