import requests
from config import OPENAI_API_KEY, OPENAI_API_URL


def send_to_ai_agent(text):
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json"
    }

    data = {
        "model": "gpt-4",
        "messages": [
            {"role": "system", "content": "You are a helpful AI assistant."},
            {"role": "user", "content": f"Here is the Week 1 Overview: {text}"}
        ]
    }

    response = requests.post(OPENAI_API_URL, json=data, headers=headers)

    if response.status_code == 200:
        print("AI Response:", response.json()["choices"][0]["message"]["content"])
    else:
        print("Error:", response.text)
