export function phoneInput(phoneBlock) {
    const countrySelect = document.createElement('select');
    countrySelect.id = 'country-select';
    const countryData = [
        {
            value: '7',
            name: 'Россия +7'
        },
        {
            value: '375',
            name: 'Беларусь +375'
        }
    ]
    countryData.forEach(item => {
        const option = document.createElement('option');
        option.value = item.value;
        option.textContent = item.name;
        countrySelect.appendChild(option);
    });

    const phoneIndex = document.createElement('span');
    phoneIndex.id = 'phone-index';
    phoneIndex.textContent = '+7';

    const phoneInput = document.createElement('input');
    phoneInput.type = 'tel';
    phoneInput.id = 'phone-input';
    phoneInput.placeholder = '(999) 999-99-99';

    function getPatternForCountry(countryCode) {
        const code = String(countryCode);
        if (code.length < 3) {
            return {
                pattern: /(\d{0,3})(\d{0,3})(\d{0,2})(\d{0,2})/,
                placeholder: `(999) 999-99-99`,
            }
        } else {
            return {
                pattern: /(\d{0,2})(\d{0,3})(\d{0,2})(\d{0,2})/,
                placeholder: `(99) 999-99-99`,
            }
        }
    }

    const phoneInputTemplate = (x) => `${x[1] ? '(' + x[1] : ''}${x[2] ? ') ' + x[2] : ''}${x[3] ? '-' + x[3] : ''}${x[4] ? '-' + x[4] : ''}`;

    phoneInput.addEventListener('input', function (e) {
        const patternData = getPatternForCountry(countrySelect.value);
        let numbers = e.target.value.replace(/\D/g, '');
        let x = numbers.match(patternData.pattern);
        e.target.value = phoneInputTemplate(x);
    });

    countrySelect.addEventListener('change', function () {
        phoneInput.value = '';
        phoneIndex.textContent = `+${countrySelect.value}`;
        const patternData = getPatternForCountry(countrySelect.value);
        phoneInput.placeholder = patternData.placeholder;
    });
    
    phoneBlock.appendChild(countrySelect);
    phoneBlock.appendChild(phoneIndex);
    phoneBlock.appendChild(phoneInput);
}








// function getPatternForCountry(countryCode) {
//     const code = String(countryCode);
//     const template = (x) => `${x[1] ? ' (' + x[1] : ''}${x[2] ? ') ' + x[2] : ''}${x[3] ? '-' + x[3] : ''}${x[4] ? '-' + x[4] : ''}`;

//     if (code.length === 1) {
//         return {
//             pattern: /(\d{0,3})(\d{0,3})(\d{0,2})(\d{0,2})/,
//             placeholder: `(999) 999-99-99`,
//             template: template
//         }
//     } else if (code.length === 2) {
//         return {
//             pattern: /(\d{0,3})(\d{0,3})(\d{0,2})(\d{0,2})/,
//             placeholder: `(999) 999-99-99`,
//             template: template
//         }
//     } else {
//         return {
//             pattern: /(\d{0,2})(\d{0,3})(\d{0,2})(\d{0,2})/,
//             placeholder: `(99) 999-99-99`,
//             template: template
//         }
//     }
// }

// const countryPlaceholders = {
//     '7': '(999) 999-99-99',
//     '375': '(99) 999-99-99',
//     '380': '(99) 999-99-99',
//     '77': '(999) 999-99-99',
//     '1': '(999) 999-9999',
//     '44': '9999 999 999',
//     '49': '99999 99999'
// };

// // Обработчик смены страны
// // countrySelect.addEventListener('change', function() {
// //   phoneInput.value = `+${this.value}`; // Очищаем поле при смене страны
// // });

// // Маска ввода
// phoneInput.addEventListener('input', function (e) {
//     const patternData = getPatternForCountry(countrySelect.value);

//     let numbers = e.target.value.replace(/\D/g, '');
//     let x = numbers.match(patternData.pattern);

//     e.target.value = patternData.template(x);
// });
// // document.getElementById('simple-phone').addEventListener('input', function(e) {
// //     let x = e.target.value.replace(/\D/g, '').match(/(\d{0,1})(\d{0,3})(\d{0,3})(\d{0,2})(\d{0,2})/);
// //     e.target.value = '+7' + (x[2] ? ' (' + x[2] : '') + (x[3] ? ') ' + x[3] : '') + (x[4] ? '-' + x[4] : '') + (x[5] ? '-' + x[5] : '');
// // });


// // Функция проверки полного ввода
// function isPhoneComplete() {
//     const countryCode = countrySelect.value;
//     const value = phoneInput.value.replace(/\D/g, '');

//     const minLengths = {
//         '7': 11, // 10 цифр без +7
//         '375': 12, // 9 цифр без +375
//         '380': 12, // 9 цифр без +380
//         '77': 11, // 10 цифр без +7
//         '1': 11, // 10 цифр без +1
//         '44': 12, // 10 цифр без +44
//         '49': 13  // 11 цифр без +49
//     };

//     return value.length >= minLengths[countryCode];
// }

// // Функция получения чистого номера
// function getCleanPhone() {
//     return phoneInput.value.replace(/\D/g, '');
// }

// // Функция получения номера с кодом страны
// function getFullPhone() {
//     return '+' + getCleanPhone();
// }

// </script >

//     <style>
//         .phone-input {
//             display: flex;
//         align-items: center;
//         margin-bottom: 10px;
// }

//         #simple-phone {
//             flex: 1;
// }

//         #country-code, #simple-phone {
//             border: 1px solid #ccc;
//         border-radius: 4px;
//         font-size: 14px;
// }

//         #simple-phone:valid {
//             border - color: green;
// }

//         #simple-phone:invalid {
//             border - color: red;
// }
//     </style>