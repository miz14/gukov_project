import requests
from config import BOT_SERVICE, GOOGLE_POST_URL

class APIService:
    @staticmethod
    def send_data(data):
        data['service'] = BOT_SERVICE

        response = requests.post(GOOGLE_POST_URL, data)
        return response

