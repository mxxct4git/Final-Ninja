## Quick Start

1. 以调试模式启动Chrome `/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222`
2. 先登录到任一学校平台
3. 安装依赖 `pip install "fastapi[standard]"`
4. 启动fastapi服务 `fastapi dev main.py`
5. 新建一个terminal调用接口 `curl -X GET http://127.0.0.1:8000/courses` 查看所有课程
6. 新建一个terminal调用接口 `curl -X GET http://127.0.0.1:8000/courses/5225` 查看课程详情
7. 新建一个terminal调用接口 `curl -X GET http://127.0.0.1:8000/timeline` 查看时间表详情