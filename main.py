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


# get all courses
@app.get("/courses")
async def get_all_courses():
    return echo.get_all_courses()


# get specific course
@app.get("/courses/{course_id}")
async def get_course(course_id: int):
    return echo.get_course(course_id)

# get the quiz list of specific course
@app.get("/courses/{course_id}/quiz")
async def get_quiz(course_id: int):
    return echo.get_quiz(course_id)

# get timeline 
@app.get("/timeline")
async def get_timeline_content():
    return echo.get_timeline_content()
