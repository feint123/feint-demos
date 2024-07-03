// my-component.js
class MyComponent extends HTMLElement {
    constructor() {
        super();
        const shadowRoot = this.attachShadow({ mode: 'open' });
        shadowRoot.innerHTML = `
        <style>
            .ios-radio {
                position: absolute;
                opacity: 0;
            }
    
            .ios-radio-label {
                display: inline-block;
                width: 40px;
                height: 24px;
                background-color: #ccc;
                border-radius: 40px;
                position: relative;
                cursor: pointer;
                transition: all 0.3s;
            }
    
            .ios-radio-label::after {
                content: '';
                display: block;
                width: 10px;
                height: 10px;
                background-color: #fff;
                border-radius: 50%;
                position: absolute;
                top: 7px;
                left: 7px;
                transition: all 0.3s;
            }
    
            .ios-radio:checked+.ios-radio-label::after {
                transform: translateX(18px);
            }
    
            .ios-radio:checked+.ios-radio-label {
                background-color: #4cd964;
                /* change to the color you want */
            }
        </style>
        <input type="checkbox" id="ios-radio" class="ios-radio" />
        <label for="ios-radio" class="ios-radio-label"></label>
        `;
        this.checkbox = shadowRoot.querySelector('.ios-radio');

    }

    get checked() {
        return this.checkbox.checked;
    }

    // Public method to set the checkbox state
    set checked(value) {
        console.log("checked")
        if (value) {
            this.checkbox.setAttribute('checked', '');
        } else {
            this.checkbox.removeAttribute('checked');
        }
    }

    // Public method to add an event listener to the checkbox
    addEventListener(type, listener, options) {
        this.checkbox.addEventListener(type, listener, options);
    }

    // Public method to remove an event listener from the checkbox
    removeEventListener(type, listener, options) {
        this.checkbox.removeEventListener(type, listener, options);
    }
}

customElements.define('i-switch', MyComponent);