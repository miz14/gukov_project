from telebot import types
from form.states import FormStates


def get_finish_content():
    text = 'Заявка отправлена'

    markup = types.InlineKeyboardMarkup()
    btn = types.InlineKeyboardButton('Главное меню', callback_data='menu')
    markup.add(btn)
    return text, markup

def register_finish_handlers(bot):

    @bot.callback_query_handler(func=lambda call: call.data == 'form_finish')
    def callback(call):
        print(123)
        chat_id = call.message.chat.id
        user_id = call.from_user.id
        with bot.retrieve_data(user_id, chat_id) as data:
            data['all_form_data'] = None
            data['add_service_to_text'] = None

        text, markup = get_finish_content()
        bot.send_message(chat_id, text, reply_markup=markup, parse_mode='markdown')

        bot.answer_callback_query(call.id)