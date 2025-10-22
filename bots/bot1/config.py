import os
from telebot.handler_backends import State, StatesGroup

class FormStates(StatesGroup):
    form_name = State()
    form_phone_or_email = State()
    form_phone = State()
    form_email = State()
    form_message = State()
    form_checking = State()
    form_complete = State()

# BOT_TOKEN = os.getenv('BOT1_TOKEN')
BOT_TOKEN = '8484377292:AAEJ_UxVlTpdEAX9Wn4HDe1tvJzC7mEEkYo'
BOT_SERVICE = 'Юридические услуги в сфере пенсионного права'
