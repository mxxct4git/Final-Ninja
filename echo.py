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

    # loop timeline_data
    for entry in timeline_data:
        for task in entry["assignments"]:
            status = task["status"]
            task_name = task["task"]

            # group by status
            if status not in status_dict:
                status_dict[status] = []
            status_dict[status].append(task_name)
 
    return json.dumps(status_dict, ensure_ascii=False, indent=4)

def get_total_assignments(timeline_data):
    assignment_count = {}
    total_count = 0

    # loop timeline_data
    for entry in timeline_data:
        date = entry["date"]
        count = len(entry["assignments"])  # Calculate the number of tasks on that date
        assignment_count[date] = count
        total_count += count  #

    # get amount of all tasks
    assignment_count["total_count"] = total_count
    print(f"Total Assignments: {total_count}")
    return total_count

# get all courses
def get_all_courses():
    target_courses = [f"FIT{course}" for course in target_course]
    return {"courses": target_courses}

# get timeline content 
def get_timeline_content():
    print("🚀 Starting timeline extraction...")
    print("=" * 50)
    # open WebDriver
    options = webdriver.ChromeOptions()
    options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")
    driver = webdriver.Chrome(options=options)

    # create new tab
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

    # highlight
    driver.execute_script(timeline_js_code)
    # time.sleep(10)

    # get page content
    print("🔍 Parsing timeline data...")
    page_content = driver.page_source

    # use BeautifulSoup to parse page
    soup = BeautifulSoup(page_content, 'html.parser')
    timeline_data = []
    
    # find all class="day_day__xedDk" <div>
    print("📊 Processing timeline entries...")
    days = soup.find_all('li', class_="day_dayWithAssessments__Go2a-")


    if not days:
        print("⚠️ No timeline data found")
        return []

    total_days = len(days[1:])
    for idx, day in enumerate(days[1:], 1):
        print(f"📅 Processing day {idx}/{total_days}", end='\r')

    # Iterate over all elements starting from index 1
    print("\n🎯 Calculating assignment statistics...")
    for day in days[1:]:
        # Get the date (h3 tag)
        date_tag = day.find('h3')
        date_text = date_tag.get_text(strip=True) if date_tag else "Unknown date"

        # Get all tasks (traverse ul > button)
        assignments = []
        for item in day.find_all('button', class_='day_item__9bhZH'):
            # Get time (span tag)
            time_tag = item.find('span', class_='day_dueTime__Q+9UA')
            time_text = time_tag.get_text(strip=True) if time_tag else "Unknown time"

            # Get the task title (h4 tag)
            title_tag = item.find('h4')
            title_text = title_tag.get_text(strip=True) if title_tag else "Unknown task"

            # Get submission status（span class="status_status__CwfUR"）
            status_tag = item.find('span', class_='status_status__CwfUR')
            status_text = status_tag.get_text(strip=True) if status_tag else "Unknown status"

            assignments.append({
                "time": time_text,
                "task": title_text,
                "status": status_text
            })

        # Add date and task information to timeline
        timeline_data.append({
            "date": date_text,
            "assignments": assignments
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
        print(f"\n{Fore.CYAN}  {entry['date']}{Style.RESET_ALL}")
        for task in entry['assignments']:
            status_icon = {
                "Submitted": "✅",
                "Not Submitted": "❌",
                "In progress": "⏳",
                "Unknown status": "❓"
            }.get(task['status'], "❓")
            
            print(f"    {status_icon} {task['time']} - {task['task']}")


    print("=" * 50)
    return json.dumps(timeline_report, ensure_ascii=False, indent=4)


# get specific course
def get_course(course_id):
    print(f"🎓 Fetching course information for FIT{course_id}...")
    print("=" * 50)
    # open WebDriver
    options = webdriver.ChromeOptions()
    print("🌐 Connecting to Chrome browser...")
    options.add_experimental_option("debuggerAddress", "127.0.0.1:9222") 
    driver = webdriver.Chrome(options=options)
    response = ""

    # save original window tabs
    original_window = driver.current_window_handle

    # create a new tab
    print("📑 Creating new tab...")
    driver.switch_to.new_window('tab')

    print("🔄 Loading Monash learning system...")
    driver.get('https://learning.monash.edu/my/')

    for i in range(3):
        print(f"⏳ Loading page... {i*33}%", end='\r')
        time.sleep(1)
    print("\n✨ Page loaded successfully!")

    # wait for page loading
    time.sleep(3)

    # add random border
    driver.execute_script(my_js_code)

    # time sleep to check effect
    time.sleep(3)

    # get page content
    print("🔍 Scanning for course links...")
    page_content = driver.page_source

    # use BeautifulSoup to parse page content
    soup = BeautifulSoup(page_content, 'html.parser')


    # find specific <div>
    course_links = soup.find_all('a', class_='aalink coursename mr-2 mb-1')

    filtered_links = {}

    # loop course_links
    for link in course_links:
        course_text = link.text.strip().replace("\n", " ")
        course_url = link.get('href')

        # filter target course
        for number in target_course:
            if number in course_text:
                filtered_links[course_url] = number

    print(f"\n{Fore.CYAN}📚 Available Courses:{Style.RESET_ALL}")
    print("=" * 50)
    print(f"{Fore.YELLOW}{'Course ID':<15}{'Course URL':<45}{Style.RESET_ALL}")
    print("=" * 50)
    
    # Format course links output
    for url, number in filtered_links.items():
        shortened_url = url[:42] + "..." if len(url) > 45 else url
        print(f"FIT{number:<11} {shortened_url}")
    print("=" * 50)

    # choose course
    chosen_url = None
    for url, number in filtered_links.items():
        if number == str(course_id):
            chosen_url = url
            break

    if chosen_url:
        driver.get(chosen_url)
        week1_url = chosen_url + '&section=7'
        week2_url = chosen_url + '&section=11'

        # open week1_url link
        driver.get(week1_url)
        driver.execute_script(specific_week_js_code)

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

    # close WebDriver
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
