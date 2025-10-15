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
    phoneInput.maxLength = 14;
    phoneInput.placeholder = '(999) 999-99-99';
    phoneInput.required = true;
    phoneInput.autocomplete = 'tel-national';

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
export function setPhoneRequired(required) {
    const phoneInput = document.getElementById('phone-input');
    phoneInput.required = required;
}

export function setShowPhone(show) {
    if (show) {
        document.getElementById('phone-block').classList.remove('hidden');
    } else {
        document.getElementById('phone-block').classList.add('hidden');
    }
    
}
export function getPhoneValue() {
    const index = document.getElementById('phone-index').textContent;
    const phone = document.getElementById('phone-input').value.replace(/\D/g, "");
    return index + phone;
}