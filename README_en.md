## Quick Start

1. Start Chrome in debug mode: `/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222`
2. Log in to any school platform.
3. Create a new .env file with the following content:
    ```shell
    OPENAI_API_KEY="sk-<Your OpenAI API Key>"
    OPENAI_API_BASE= "<Your OpenAI API Base URL>"
    ```
4. Install dependencies: `pip install "fastapi[standard]"`
5. Start the FastAPI service: `fastapi dev main.py`
6. Open a new terminal and call the API to view all courses: `curl -X GET http://127.0.0.1:8000/courses` 查看所有课程
7. Open a new terminal and call the API to view course details: `curl -X GET http://127.0.0.1:8000/courses/9136` 查看课程详情
8. Open a new terminal and call the API to view the timeline details: `curl -X GET http://127.0.0.1:8000/timeline` 查看时间表详情
9. Open a new terminal and call the API to view the quiz for a specific course: `curl -X GET http://127.0.0.1:8000/courses/5225/quiz` 查看quiz