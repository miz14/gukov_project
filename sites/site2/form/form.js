import { phoneInput } from './phone-input.js';
import { emailInput } from './email-input.js';

const form = document.getElementById('contact-form');

const nameInput = document.createElement('input');
nameInput.type = 'text';
nameInput.id = 'form-name';
nameInput.placeholder = 'Ваше имя';
form.appendChild(nameInput);


const radioBlock = document.createElement('div');
radioBlock.id = 'radio-block';
form.appendChild(radioBlock);

const radioData = [
    {
        value: 'phone',
        label: 'Телефон'
    },
    {
        value: 'email',
        label: 'Email'
    }
]
radioData.forEach((item, idx) => {
    const radioItem = document.createElement('div');
    radioItem.className = 'radio-item';
    radioBlock.appendChild(radioItem);

    const radio = document.createElement('input');
    radio.type = 'radio';
    radio.id = item.value + '-radio';
    radio.name = 'phone_or_email';
    radio.value = item.value;
    if (idx === 0) {
        radio.checked = true;
    }
    radio.addEventListener('change', () => {
        if (radio.value === 'phone') {
            phoneBlock.classList.remove('hidden');
            emailBlock.classList.add('hidden');
            emailBlock.children[0].value = '';
        } else {
            emailBlock.classList.remove('hidden');
            phoneBlock.classList.add('hidden');
            phoneBlock.children[2].value = '';
        }
    })

    const label = document.createElement('label');
    label.htmlFor = item.value + '-radio';
    label.textContent = item.label;

    radioItem.appendChild(radio);
    radioItem.appendChild(label);
})

const phoneBlock = document.createElement('div');
phoneBlock.id = 'phone-block';

phoneInput(phoneBlock);
form.appendChild(phoneBlock);

const emailBlock = document.createElement('div');
emailBlock.id = 'email-block';
emailBlock.className = 'hidden';

emailInput(emailBlock);
form.appendChild(emailBlock);

const textArea = document.createElement('textarea');
textArea.id = 'text-area';
textArea.placeholder = 'Ваше сообщение';
form.appendChild(textArea);

const button = document.createElement('button');
button.id = 'form-button';
button.textContent = 'Отправить заявку';
form.appendChild(button);