## Quick Start

1. 以调试模式启动Chrome `/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222`
2. 先登录到任一学校平台
3. 新建一个 .env 文件，内容如下：
    ```shell
    OPENAI_API_KEY="sk-<Your OpenAI API Key>"
    OPENAI_API_BASE= "<Your OpenAI API Base URL>"
    ```
4. 安装依赖 `pip install "fastapi[standard]"`
5. 启动fastapi服务 `fastapi dev main.py`
6. 新建一个terminal调用接口 `curl -X GET http://127.0.0.1:8000/courses` 查看所有课程
7. 新建一个terminal调用接口 `curl -X GET http://127.0.0.1:8000/courses/9136` 查看课程详情
8. 新建一个terminal调用接口 `curl -X GET http://127.0.0.1:8000/timeline` 查看时间表详情
9. 新建一个terminal调用接口 `curl -X GET http://127.0.0.1:8000/courses/5225/quiz` 查看quiz