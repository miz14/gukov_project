export function emailInput(emailBlock) {
    const emailInput = document.createElement('input');
    emailInput.type = 'email';
    emailInput.id = 'email-input';
    emailInput.placeholder = 'Email';
    emailBlock.appendChild(emailInput);

    emailInput.addEventListener('input', () => {
        const email = emailInput.value;
        const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        const isValid = emailRegex.test(email);
        emailInput.style.borderColor = isValid ? 'green' : 'red';
    });
}