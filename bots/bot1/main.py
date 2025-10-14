import telebot
from telebot import types
from telebot.handler_backends import State, StatesGroup
from telebot.storage import StateMemoryStorage
from telebot import custom_filters
import requests
import os

# token = os.getenv('TELEGRAM_BOT_TOKEN')
state_storage = StateMemoryStorage()

class UserStates(StatesGroup):
    name = State()
    phone_or_email = State()
    phone = State()
    email = State()
    message = State()
    checking = State()
    complete = State()

class Bot1:
    def __init__(self):
        self.bot = telebot.TeleBot(token, state_storage=state_storage, use_class_middlewares=True)
        self.bot.add_custom_filter(custom_filters.StateFilter(self.bot))
        self.register_handlers()
        self.url = 

    def send_data(self, data):
        data['service'] = 'Юридические услуги в сфере пенсионного права'
        data['sent_from'] = '@bot1'
        print(data)
        requests.post(url=self.url, data=data)

    def start(self):
        self.bot.polling()

    def get_menu(self):
        text = '*Меню*\n\nКакое-то вводное описание'

        markup = types.InlineKeyboardMarkup(row_width=1)
        btn1 = types.InlineKeyboardButton('Услуги', callback_data='services')
        btn2 = types.InlineKeyboardButton('Оставить заявку', callback_data='form')
        markup.add(btn1, btn2)

        return text, markup
    
    
    def get_services(self):
        pass

    def get_form_name(self):
        text = 'Шаг 1. Введите ваше имя'
        markup = self.get_form_cancel_btn()
        return text, markup
    
    def get_form_phone_or_email(self):
        text = 'Шаг 2. Что вы хотите оставить для обратной связи?'

        cancel_btn = self.get_form_cancel_btn(only_button=True)

        markup = types.InlineKeyboardMarkup(row_width=2)

        btn1 = types.InlineKeyboardButton('Номер телефона', callback_data='form_phone')
        btn2 = types.InlineKeyboardButton('Email', callback_data='form_email')

        markup.add(btn1, btn2)
        markup.add(cancel_btn)
        return text, markup

    def get_form_phone(self):
        text = 'Шаг 3. Введите ваш номер телефона'
        markup = self.get_form_cancel_btn()
        return text, markup
    
    def get_form_email(self):
        text = 'Шаг 3. Введите ваш email'
        markup = self.get_form_cancel_btn()
        return text, markup
    
    def get_form_message(self):
        text = 'Шаг 4. Введите ваше сообщение'
        markup = self.get_form_cancel_btn()
        return text, markup

    def get_form_cancel_btn(self, only_button=False):
        btn = types.InlineKeyboardButton('Отменить', callback_data='cancel_form')
        if only_button:
            return btn
        markup = types.InlineKeyboardMarkup()
        markup.add(btn)
        return markup
    
    def get_form_checking(self, all_form_data):
        text = f"""
        *Проверьте данные заявки:*
        *Имя:* {all_form_data.get('name')}
        {'*Телефон:* ' + all_form_data.get('phone') if all_form_data.get('phone') else '*Почта:* ' + all_form_data.get('email')}
        *Сообщение:* {all_form_data.get('message')}
        """
        markup = types.InlineKeyboardMarkup()
        btn1 = types.InlineKeyboardButton('Отправить', callback_data='form_complete')
        btn2 = self.get_form_cancel_btn(only_button=True)
        markup.add(btn1, btn2)
        return text, markup
    
    def get_form_complete(self):
        text = 'Заявка отправлена'
        markup = types.InlineKeyboardMarkup()
        btn = types.InlineKeyboardButton('Главное меню', callback_data='menu')
        return text, markup


    def register_handlers(self):
        @self.bot.message_handler(commands=['start'])
        def start(message):
            chat_id = message.chat.id
            user_id = message.from_user.id

            text, markup = self.get_menu()
            self.bot.send_message(chat_id, text, reply_markup=markup, parse_mode='markdown')
            self.bot.delete_state(user_id, chat_id)

        @self.bot.message_handler(state=UserStates.name)
        def form_name(message):
            chat_id = message.chat.id
            user_id = message.from_user.id
            print('name')

            with self.bot.retrieve_data(user_id, chat_id) as data:
                form_message_id = data.get('form_message_id')
                data['all_form_data'] = {'name': message.text}

            self.bot.delete_message(chat_id, message.message_id)

            self.bot.set_state(user_id, UserStates.phone_or_email, chat_id)
            next_text, next_markup = self.get_form_phone_or_email()
            self.bot.edit_message_text(chat_id=chat_id, message_id=form_message_id, text=next_text, reply_markup=next_markup)

        # @self.bot.message_handler(state=UserStates.phone_or_email)
        # def form_phone_or_email(message):
        #     chat_id = message.chat.id
        #     user_id = message.from_user.id
        #     self.bot.set_state(user_id, UserStates.message, chat_id)
        #     next_text, next_markup = self.get_form_phone_or_email()
        #     self.bot.edit_message_text(chat_id=chat_id, message_id=message.message_id, text=next_text, reply_markup=next_markup)

        @self.bot.message_handler(state=UserStates.phone)
        def form_phone(message):
            chat_id = message.chat.id
            user_id = message.from_user.id

            with self.bot.retrieve_data(user_id, chat_id) as data:
                form_message_id = data.get('form_message_id')
                data['all_form_data']['phone'] = message.text

            self.bot.delete_message(chat_id, message.message_id)

            self.bot.set_state(user_id, UserStates.message, chat_id)
            next_text, next_markup = self.get_form_message()
            self.bot.edit_message_text(chat_id=chat_id, message_id=form_message_id, text=next_text, reply_markup=next_markup)
        @self.bot.message_handler(state=UserStates.email)
        def form_email(message):
            chat_id = message.chat.id
            user_id = message.from_user.id

            with self.bot.retrieve_data(user_id, chat_id) as data:
                form_message_id = data.get('form_message_id')
                data['all_form_data']['email'] = message.text

            self.bot.delete_message(chat_id, message.message_id)

            self.bot.set_state(user_id, UserStates.message, chat_id)
            next_text, next_markup = self.get_form_message()
            self.bot.edit_message_text(chat_id=chat_id, message_id=form_message_id, text=next_text, reply_markup=next_markup)
        
        @self.bot.message_handler(state=UserStates.message)
        def form_message(message):
            chat_id = message.chat.id
            user_id = message.from_user.id

            with self.bot.retrieve_data(user_id, chat_id) as data:
                form_message_id = data.get('form_message_id')
                data['all_form_data']['message'] = message.text
                all_form_data = data['all_form_data']

            self.bot.delete_message(chat_id, message.message_id)
            self.bot.set_state(user_id, UserStates.checking, chat_id)

            next_text, next_markup = self.get_form_checking(all_form_data)
            self.bot.edit_message_text(chat_id=chat_id, message_id=form_message_id, text=next_text, reply_markup=next_markup)                

        @self.bot.callback_query_handler(func=lambda call: True)
        def callback(call):
            chat_id = call.message.chat.id
            user_id = call.from_user.id
            message_id = call.message.message_id

            if call.data == 'menu':
                self.bot.delete_state(user_id, chat_id)
                text, markup = self.get_menu()
                self.bot.send_message(chat_id, text, reply_markup=markup, parse_mode='markdown')
            
            elif call.data == 'form':
                self.bot.set_state(user_id, UserStates.name, chat_id)
                
                # with self.bot.retrieve_data(user_id, chat_id) as data:
                #     data['menu_message_id'] = message_id
 
                text, markup = self.get_form_name()
                form_message = self.bot.send_message(chat_id, text, reply_markup=markup, parse_mode='markdown')

                with self.bot.retrieve_data(user_id, chat_id) as data:
                    data['form_message_id'] = form_message.message_id
            
            elif call.data in ['form_email', 'form_phone']:
                with self.bot.retrieve_data(user_id, chat_id) as data:
                    form_message_id = data.get('form_message_id')

                if call.data == 'form_email':
                    self.bot.set_state(user_id, UserStates.email, chat_id)
                    text, markup = self.get_form_email()
                else:
                    self.bot.set_state(user_id, UserStates.phone, chat_id)
                    text, markup = self.get_form_phone()
                
                self.bot.edit_message_text(chat_id=chat_id, message_id=form_message_id, text=text, reply_markup=markup)
            
            elif call.data == 'form_complete':
                self.bot.set_state(user_id, UserStates.complete, chat_id)

                with self.bot.retrieve_data(user_id, chat_id) as data:
                    form_message_id = data.get('form_message_id')
                    self.send_data(data['all_form_data'])

                text, markup = self.get_form_complete()
                self.bot.send_message(chat_id=chat_id, text=text, reply_markup=markup)

            elif call.data == 'cancel_form':
                with self.bot.retrieve_data(user_id, chat_id) as data:
                    form_message_id = data.get('form_message_id')

                self.bot.delete_message(chat_id, form_message_id)
                
                self.bot.delete_state(user_id, chat_id)

        




bot = Bot1()
bot.start()
