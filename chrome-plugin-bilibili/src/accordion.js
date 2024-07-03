
class CustomAccordion extends HTMLElement {
    constructor() {
        super(); // 必须首先调用super()方法

        // 创建shadow DOM以封装样式和结构
        this.attachShadow({ mode: 'open' });
        this.shadowRoot.innerHTML = `
        <style>
        .hidden {
            display: none;
        }
        .rotate-180 {
        --tw-rotate: 180deg;
        transform: translate(var(--tw-translate-x), var(--tw-translate-y)) rotate(var(--tw-rotate)) skewX(var(--tw-skew-x)) skewY(var(--tw-skew-y)) scaleX(var(--tw-scale-x)) scaleY(var(--tw-scale-y));
        }
        </style>
        <div>
      <div class="accordion-header" part="header">
        <slot name="header">点击展开</slot>
        <svg part="icon" class="" fill="currentColor"
            viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd"
              d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
              clip-rule="evenodd"></path>
      </div>
      <div class="accordion-content hidden" part="content">
        <slot name="content"></slot>
      </div>
      </div>
    `;

        // 初始化状态和事件监听器
        this._header = this.shadowRoot.querySelector('.accordion-header');
        this._content = this.shadowRoot.querySelector('.accordion-content');
        this._header.addEventListener('click', this.toggleContent.bind(this));
        this._isOpen = false;
    }

    toggleContent() {
        this._content.classList.toggle('hidden');
        // 可以添加动画效果或图标旋转等逻辑
        // 切换箭头图标的方向（如果需要）
        const icon = this.shadowRoot.querySelector('svg');
        icon.classList.toggle('rotate-180');
    }
}

// 定义自定义元素
customElements.define('f-accordion', CustomAccordion);