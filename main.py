from fastapi import FastAPI
import echo

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/hello/{name}")
async def say_hello(name: str):
    return {"message": f"Hello {name}"}


@app.get("/start")
async def start():
    return {"message": "Hello World"}


# 查询所有的课程列表
@app.get("/courses")
async def get_all_courses():
    return echo.get_all_courses()


# 查询指定课程
@app.get("/courses/{course_id}")
async def get_course(course_id: int):
    return echo.get_course(course_id)


# 查询时间表 
@app.get("/timeline")
async def get_timeline_content():
    return echo.get_timeline_content()
