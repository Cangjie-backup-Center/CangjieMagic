package magic.ohos

import magic.dsl.*
import magic.prelude.*

@jsonable
public class OptionInfo {
    @field["Title"]
    let title: String
    @field["A list of options, all of which are fixed presets, with no 'other' or custom choices."]
    let arr: Array<String>
}

@template
func template_radio_list(info: OptionInfo) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>自定义选择列表</title>
        <link href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css" rel="stylesheet">
        <style>
            :root {
            --primary: hsl(220, 100%, 54%);
            --secondary: hsl(156, 68%, 52%);
            --neutral: hsl(210, 17%, 95%);
            --neutral-dark: hsl(220, 13%, 18%);
            --gray-200: hsl(210, 16%, 93%);
            --gray-300: hsl(210, 14%, 89%);
            --gray-500: hsl(215, 10%, 44%);
            --gray-700: hsl(215, 16%, 27%);
            --red-500: hsl(0, 79%, 63%);
            }

            body {
            font-family: 'Inter', system-ui, sans-serif;
            background-color: hsl(210, 17%, 98%);
            min-height: 100vh;
            margin: 0;
            padding: 0;
            }

            .container {
            max-width: 384px;
            margin: 0 auto;
            padding: 2rem 1rem;
            }

            .card {
            background-color: white;
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
            }

            .card:hover {
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            }

            h3 {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--neutral-dark);
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            }

            h3 i {
            color: var(--primary);
            margin-right: 0.5rem;
            }

            .option-group {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
            }

            .option-card {
            display: flex;
            align-items: center;
            padding: 1rem;
            border-radius: 0.5rem;
            border: 1px solid var(--gray-200);
            cursor: pointer;
            transition: all 0.3s ease;
            }

            .option-card:hover {
            border-color: hsla(220, 100%, 54%, 0.5);
            background-color: hsla(220, 100%, 54%, 0.05);
            }

            .option-card input[type="radio"] {
            width: 1.25rem;
            height: 1.25rem;
            color: var(--primary);
            border: 1px solid var(--gray-300);
            border-radius: 50%;
            appearance: none;
            -webkit-appearance: none;
            outline: none;
            cursor: pointer;
            position: relative;
            }

            .option-card input[type="radio"]:checked {
            border-color: var(--primary);
            }

            .option-card input[type="radio"]:checked::before {
            content: '';
            width: 0.75rem;
            height: 0.75rem;
            background-color: var(--primary);
            border-radius: 50%;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            }

            .option-card span {
            margin-left: 0.75rem;
            }

            .custom-inputs {
            background-color: white;
            padding: 1.25rem;
            border-radius: 0.5rem;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            border: 1px solid var(--gray-200);
            display: none;
            }

            .input-group {
            margin-bottom: 1rem;
            }

            .input-label {
            display: block;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--gray-700);
            margin-bottom: 0.25rem;
            }

            .custom-input {
            width: 100%;
            padding: 0.5rem 0.75rem;
            border: 1px solid var(--gray-300);
            border-radius: 0.375rem;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            outline: none;
            transition: all 0.15s ease-in-out;
            }

            .custom-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 2px hsla(220, 100%, 54%, 0.2);
            }

            .btn-primary {
            background-color: var(--primary);
            color: white;
            font-weight: 500;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease-in-out;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            }

            .btn-primary:hover {
            background-color: hsl(220, 100%, 45%);
            transform: scale(1.02);
            }

            .btn-primary:focus {
            outline: none;
            box-shadow: 0 0 0 2px hsla(220, 100%, 54%, 0.5);
            }

            .btn-primary i {
            margin-right: 0.5rem;
            }

            .result-card {
            background-color: white;
            padding: 1.25rem;
            border-radius: 0.5rem;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            border: 1px solid var(--gray-200);
            margin-top: 1.5rem;
            }

            h4 {
            font-size: 1.125rem;
            font-weight: 500;
            color: var(--neutral-dark);
            margin-bottom: 0.75rem;
            }

            .result-content {
            display: flex;
            align-items: center;
            padding: 1rem;
            background-color: var(--neutral);
            border-radius: 0.5rem;
            }

            .result-icon {
            width: 2.5rem;
            height: 2.5rem;
            border-radius: 50%;
            background-color: hsla(220, 100%, 54%, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            }

            .result-icon i {
            color: var(--primary);
            }

            .result-text {
            flex: 1;
            }

            .result-label {
            font-size: 0.875rem;
            color: var(--gray-500);
            margin-bottom: 0.125rem;
            }

            .result-value {
            font-weight: 500;
            color: var(--neutral-dark);
            }

            .toast {
            position: fixed;
            bottom: 1rem;
            right: 1rem;
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            transform: translateY(0);
            opacity: 1;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            z-index: 100;
            }

            .toast.success {
            background-color: var(--secondary);
            color: white;
            }

            .toast.error {
            background-color: var(--red-500);
            color: white;
            }

            .toast i {
            margin-right: 0.5rem;
            }

            .toast.hidden {
            opacity: 0;
            transform: translateY(1rem);
            }
        </style>
    </head>
    <body>
    <div class="container">
        <div class="card">
            <h3><i class="fa fa-list-ul"></i> {% info.title %}</h3>

            <div class="option-group">
                {% for item in info.arr %}
                    <label class="option-card">
                        <input type="radio" name="fruit" value="{% item %}" class="peer" checked>
                        <span>{% item %}</span>
                    </label>
                {% /for %}

                <label class="option-card">
                    <input type="radio" name="fruit" value="custom" class="peer">
                    <span>其他(自定义)</span>
                </label>
            </div>

            <div id="customOption" class="custom-inputs">
                <div class="input-group">
                    <label for="customFruit" class="input-label">请输入您选择:</label>
                    <input type="text" id="customFruit" class="custom-input">
                </div>
            </div>

            <button id="applySelection" class="btn-primary mt-4">
                <i class="fa fa-check"></i> 确认选择
            </button>
        </div>
    </div>

    <script>
        // 获取DOM元素
        const customRadio = document.querySelector('input[name="fruit"][value="custom"]');
        const customOption = document.getElementById('customOption');
        const applyButton = document.getElementById('applySelection');
        const customInput = document.getElementById('customFruit');

        // 初始隐藏自定义选项
        customOption.style.display = 'none';

        // 切换自定义选项的显示/隐藏
        customRadio.addEventListener('change', function() {
        if (this.checked) {
            customOption.style.display = 'block';
        } else {
            customOption.style.display = 'none';
        }
        });

        // 应用选择
        applyButton.addEventListener('click', function() {
        const selectedRadio = document.querySelector('input[name="fruit"]:checked');

        if (!selectedRadio) {
            showToast('请选择一个选项', 'error');
            return;
        }

        if (selectedRadio.value === 'custom') {
            if (customInput.value.trim() === '') {
            showToast('请输入', 'error');
            return;
            } else {
            agentCallbackObject.sendMessage(customInput.value);
            return;
            }
        }

        agentCallbackObject.sendMessage(selectedRadio.value);
        });

        // 显示提示消息
        function showToast(message, type = 'success') {
        // 移除已有的toast
        const existingToast = document.querySelector('.toast');
        if (existingToast) {
            document.body.removeChild(existingToast);
        }

        const toast = document.createElement('div');
        toast.className = `toast \${type}`;
        toast.innerHTML = `<i class="fa \${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'}"></i> \${message}`;
        document.body.appendChild(toast);

        // 先触发重排，以便动画生效
        toast.offsetWidth;

        // 3秒后隐藏toast
        setTimeout(() => {
            toast.classList.add('hidden');
            setTimeout(() => {
            document.body.removeChild(toast);
            }, 300);
        }, 2000);
        }
    </script>
    </body>
    </html>
    '''
 }

@template
func template_drop_list(info: OptionInfo) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>可自定义输入的下拉框</title>
        <link href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css" rel="stylesheet">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Inter', sans-serif;
            }

            body {
                background-color: hsl(210, 17%, 98%);
                color: hsl(215, 28%, 17%);
            }

            .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 2rem;
            }

            .card {
                background-color: white;
                border-radius: 1rem;
                box-shadow: 0 4px 6px -1px hsla(215, 28%, 17%, 0.1), 0 2px 4px -1px hsla(215, 28%, 17%, 0.06);
                margin-bottom: 2rem;
                padding: 2rem;
            }

            .custom-select-container {
                margin-bottom: 2rem;
                position: relative; /* 添加相对定位 */
            }

            label {
                display: block;
                font-size: 0.875rem;
                font-weight: 500;
                color: hsl(220, 14%, 41%);
                margin-bottom: 0.5rem;
            }

            .custom-select {
                width: 100%;
                border: 1px solid hsl(216, 16%, 95%);
                border-radius: 0.5rem;
                padding: 0.75rem 1rem;
                display: flex;
                align-items: center;
                justify-content: space-between;
                cursor: pointer;
                transition: all 0.2s ease;
            }

            .custom-select:focus-within {
                border-color: hsl(217, 91%, 60%);
                box-shadow: 0 0 0 2px hsla(217, 91%, 60%, 0.2);
            }

            input[type="text"] {
                flex-grow: 1;
                background: transparent;
                border: none;
                outline: none;
                color: hsl(215, 28%, 17%);
            }

            .select-icon {
                font-size: 1.25rem;
                color: hsl(220, 14%, 41%);
                transition: transform 0.2s ease;
            }

            .custom-options {
                position: absolute;
                top: calc(100% + 0.25rem); /* 减小与输入框的间距 */
                left: 0;
                right: 0;
                background-color: white;
                border: 1px solid hsl(216, 16%, 95%);
                border-radius: 0.5rem;
                box-shadow: 0 4px 6px -1px hsla(215, 28%, 17%, 0.1);
                margin-top: 0;
                max-height: 200px;
                overflow-y: auto;
                display: none;
                animation: fadeIn 0.2s ease-in-out;
                z-index: 10; /* 添加z-index确保在其他元素上方 */
            }

            .custom-options.open {
                display: block;
            }

            .search-section {
                padding: 0.75rem;
                border-bottom: 1px solid hsl(216, 16%, 95%);
            }

            .custom-search-input {
                width: 100%;
                padding: 0.5rem 0.75rem;
                border: 1px solid hsl(216, 16%, 95%);
                border-radius: 0.375rem;
                font-size: 0.875rem;
                color: hsl(215, 28%, 17%);
            }

            .custom-search-input:focus {
                border-color: hsl(217, 91%, 60%);
                outline: none;
                box-shadow: 0 0 0 2px hsla(217, 91%, 60%, 0.2);
            }

            .option {
                padding: 0.75rem 1rem;
                cursor: pointer;
                transition: background-color 0.2s ease;
            }

            .option:hover,
            .option.active {
                background-color: hsla(217, 91%, 60%, 0.1);
            }

            .option.custom-option {
                color: hsl(160, 84%, 39%);
                font-weight: 500;
                border-top: 1px solid hsl(216, 16%, 95%);
            }

            /* 新增：提交按钮样式 */
            .submit-button {
                background-color: hsl(217, 91%, 60%);
                color: white;
                border: none;
                border-radius: 0.5rem;
                padding: 0.75rem 1.5rem;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.2s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                width: 100%;
            }

            .submit-button:hover {
                background-color: hsl(217, 91%, 55%);
                box-shadow: 0 4px 6px -1px hsla(217, 91%, 60%, 0.2);
            }

            .submit-button:active {
                transform: translateY(1px);
            }

            .submit-button:disabled {
                background-color: hsl(217, 91%, 80%);
                cursor: not-allowed;
            }

            /* 新增：提交结果样式 */
            .result-section {
                margin-top: 1.5rem;
                padding: 1.5rem;
                border-radius: 0.5rem;
                font-size: 0.875rem;
            }

            .result-section.success {
                background-color: hsla(160, 84%, 39%, 0.1);
                color: hsl(160, 84%, 39%);
                border: 1px solid hsl(160, 84%, 39%, 0.2);
            }

            .result-section.error {
                background-color: hsla(0, 100%, 67%, 0.1);
                color: hsl(0, 100%, 67%);
                border: 1px solid hsl(0, 100%, 67%, 0.2);
            }

            .result-value {
                font-weight: 500;
            }

            /* 动画 */
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(-5px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* 响应式调整 */
            @media (max-width: 640px) {
                .container {
                    padding: 1rem;
                }

                .custom-select {
                    padding: 0.5rem 1rem;
                }
            }
        </style>
    </head>
    <body>
    <div class="container">
        <div class="card">
            <h2 class="text-xl font-bold mb-4">{% info.title %}</h2>

            <div class="custom-select-container relative">
                <div class="custom-select" id="select-trigger">
                    <input type="text" id="custom-select" placeholder="请选择或输入..." autocomplete="off">
                    <span class="select-icon">
                            <i class="fa fa-chevron-down"></i>
                        </span>
                </div>

                <div class="custom-options" id="options-container">
                    <div class="search-section">
                        <input type="text" class="custom-search-input" id="search-input" placeholder="搜索选项...">
                    </div>
                    <ul class="option-list">
                        {% for item in info.arr %}
                            <li class="option" data-value="{% item %}">{% item %}</li>
                        {% /for %}
                        <li class="option custom-option" data-value="other">
                            <i class="fa fa-plus-circle mr-1"></i> 输入自定义内容
                        </li>
                    </ul>
                </div>
            </div>

            <!-- 新增：提交按钮 -->
            <button id="submit-btn" class="submit-button">
                <i class="fa fa-check mr-2"></i> 确认提交
            </button>

            <!-- 新增：提交结果显示区域 -->
            <div id="result-section" class="result-section hidden">
                <p id="result-message"></p>
            </div>
        </div>
    </div>

    <script>
        const selectTrigger = document.getElementById('select-trigger');
        const optionsContainer = document.getElementById('options-container');
        const inputField = document.getElementById('custom-select');
        const searchInput = document.getElementById('search-input');
        const submitBtn = document.getElementById('submit-btn');
        const resultSection = document.getElementById('result-section');
        const resultMessage = document.getElementById('result-message');
        const selectIcon = selectTrigger.querySelector('.fa-chevron-down');
        const options = document.querySelectorAll('.option');

        let isOpen = false;

        // 切换下拉框状态
        selectTrigger.addEventListener('click', () => {
            isOpen = !isOpen;
            optionsContainer.classList.toggle('open');
            selectIcon.style.transform = isOpen ? 'rotate(180deg)' : 'rotate(0)';

            if (isOpen) {
                searchInput.focus();
                filterOptions('');
            }
        });

        // 点击选项处理
        options.forEach(option => {
            option.addEventListener('click', () => {
                const value = option.dataset.value;

                if (value === 'other') {
                    inputField.value = '';
                    inputField.placeholder = '请输入...';
                } else {
                    inputField.value = value;
                }

                isOpen = false;
                optionsContainer.classList.remove('open');
                selectIcon.style.transform = 'rotate(0)';
            });
        });

        // 搜索过滤选项
        searchInput.addEventListener('input', (e) => {
            const keyword = e.target.value.toLowerCase();
            filterOptions(keyword);
        });

        // 键盘导航
        inputField.addEventListener('keydown', (e) => {
            if (!isOpen) return;

            const visibleOptions = Array.from(options).filter(option => !option.hidden);
            const activeOption = document.querySelector('.option.active');
            let index = activeOption ? visibleOptions.indexOf(activeOption) : -1;

            switch(e.key) {
                case 'ArrowDown':
                    e.preventDefault();
                    setActiveOption(index + 1, visibleOptions);
                    break;
                case 'ArrowUp':
                    e.preventDefault();
                    setActiveOption(index - 1, visibleOptions);
                    break;
                case 'Enter':
                    e.preventDefault();
                    if (activeOption) activeOption.click();
                    break;
            }
        });

        // 过滤选项
        function filterOptions(keyword) {
            options.forEach(option => {
                const text = option.textContent.toLowerCase();
                option.hidden = !text.includes(keyword);
            });

            const visibleOptions = Array.from(options).filter(option => !option.hidden);
            setActiveOption(0, visibleOptions);
        }

        // 设置活动选项
        function setActiveOption(index, optionsArray) {
            if (optionsArray.length === 0) return;

            index = (index + optionsArray.length) % optionsArray.length;

            options.forEach(option => option.classList.remove('active'));
            optionsArray[index].classList.add('active');
            optionsArray[index].scrollIntoView({ behavior: 'smooth' });
        }

        // 新增：提交按钮点击事件
        submitBtn.addEventListener('click', () => {
            const selectedValue = inputField.value.trim();

            if (!selectedValue) {
                showResult('请选择或输入...', 'error');
                return;
            }

            agentCallbackObject.sendMessage(selectedValue);
        });

        // 新增：显示提交结果
        function showResult(message, type) {
            resultMessage.textContent = message;
            resultSection.classList.remove('hidden', 'success', 'error');
            resultSection.classList.add(type);

            // 添加动画效果
            resultSection.style.opacity = '0';
            resultSection.style.transform = 'translateY(-10px)';

            setTimeout(() => {
                resultSection.style.opacity = '1';
                resultSection.style.transform = 'translateY(0)';
            }, 10);

            // 3秒后自动隐藏结果
            setTimeout(() => {
                resultSection.style.opacity = '0';
                resultSection.style.transform = 'translateY(-10px)';

                setTimeout(() => {
                    resultSection.classList.add('hidden');
                }, 300);
            }, 3000);
        }
    </script>

    </body>
    </html>
    '''
 }

@tool[
    description: "Radio lists, displays information about options that can only be selected in a single mode",
    parameters: {
        items: "A list containing strings to be displayed"
    },
    terminal: true
]
public func displayListItems(info: OptionInfo): String {
    if (info.arr.size <= 5) {
        return template_radio_list(info)
    } else {
      return template_drop_list(info)
    }
}

@template
func template_multi_list(info: OptionInfo) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>自定义多选按钮列表</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
                background-color: hsl(210, 36%, 96%);
                color: hsl(209, 61%, 16%);
            }

            .container {
                background: white;
                padding: 2rem;
                border-radius: 0.5rem;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            }

            .form-group {
                margin-bottom: 1rem;
            }

            label {
                display: block;
                margin-bottom: 0.5rem;
                font-weight: 600;
            }

            .checkbox-group {
                display: flex;
                flex-direction: column;
                gap: 0.5rem;
                margin-bottom: 1rem;
            }

            .checkbox-item {
                display: flex;
                align-items: center;
                padding: 0.5rem;
                border-radius: 0.25rem;
                transition: background-color 0.2s;
            }

            .checkbox-item:hover {
                background-color: hsl(210, 36%, 96%);
            }

            .checkbox-item input[type="checkbox"] {
                margin-right: 0.5rem;
                accent-color: hsl(205, 78%, 60%);
            }

            .input-group {
                display: flex;
                gap: 0.5rem;
                margin-bottom: 1rem;
            }

            input[type="text"] {
                flex: 1;
                padding: 0.5rem;
                border: 1px solid hsl(210, 22%, 49%);
                border-radius: 0.25rem;
                font-size: 1rem;
            }

            button {
                padding: 0.5rem 1rem;
                border: none;
                border-radius: 0.25rem;
                background-color: hsl(205, 78%, 60%);
                color: white;
                font-size: 1rem;
                cursor: pointer;
                transition: background-color 0.3s;
            }

            button:hover {
                background-color: hsl(205, 63%, 48%);
            }

            .btn-container {
                display: flex;
                justify-content: flex-end;
            }

            .modal {
                display: none;
                position: fixed;
                z-index: 1;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                overflow: auto;
                background-color: rgba(0,0,0,0.4);
            }

            .modal-content {
                background-color: white;
                margin: 15% auto;
                padding: 20px;
                border: 1px solid hsl(210, 22%, 49%);
                border-radius: 0.5rem;
                width: 80%;
                max-width: 500px;
            }

            .close {
                color: hsl(210, 22%, 49%);
                float: right;
                font-size: 1.5rem;
                font-weight: bold;
            }

            .close:hover,
            .close:focus {
                color: hsl(209, 61%, 16%);
                text-decoration: none;
                cursor: pointer;
            }

            .result-list {
                margin-top: 1rem;
            }

            .result-item {
                margin-bottom: 0.5rem;
                padding: 0.3rem 0.5rem;
                background-color: hsl(210, 36%, 96%);
                border-radius: 0.25rem;
            }
        </style>
    </head>
    <body>
    <div class="container">
        <div class="form-group">
            <label>{% info.title %}</label>
            <div id="checkboxGroup" class="checkbox-group">
                {% for item in info.arr %}
                <label class="checkbox-item">
                    <input type="checkbox" name="hobby"> {% item %}
                </label>
                {% /for %}
            </div>
        </div>

        <div class="input-group">
            <input type="text" id="newOption" placeholder="请输入...">
            <button id="addOptionBtn">添加选项</button>
        </div>

        <div class="btn-container">
            <button id="confirmBtn">确认选择</button>
        </div>
    </div>

    <!-- 结果弹窗 -->
    <div id="resultModal" class="modal">
        <div class="modal-content">
            <span class="close">&times;</span>
            <h3>你选择的选项</h3>
            <div id="resultList" class="result-list"></div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const checkboxGroup = document.getElementById('checkboxGroup');
            const newOptionInput = document.getElementById('newOption');
            const addOptionBtn = document.getElementById('addOptionBtn');
            const confirmBtn = document.getElementById('confirmBtn');
            const modal = document.getElementById('resultModal');
            const closeBtn = document.querySelector('.close');
            const resultList = document.getElementById('resultList');

            // 添加新选项
            addOptionBtn.addEventListener('click', function() {
                const optionText = newOptionInput.value.trim();
                if (optionText) {
                    // 生成唯一值
                    const optionValue = optionText.toLowerCase();

                    // 检查选项是否已存在
                    const exists = Array.from(checkboxGroup.querySelectorAll('input[type="checkbox"]'))
                        .some(checkbox => checkbox.value === optionValue);

                    if (!exists) {
                        const checkboxItem = document.createElement('label');
                        checkboxItem.className = 'checkbox-item';

                        const checkbox = document.createElement('input');
                        checkbox.type = 'checkbox';
                        checkbox.name = 'hobby';
                        checkbox.value = optionValue;

                        const textNode = document.createTextNode(' ' + optionText);

                        checkboxItem.appendChild(checkbox);
                        checkboxItem.appendChild(textNode);
                        checkboxGroup.appendChild(checkboxItem);

                        newOptionInput.value = '';
                    } else {
                        alert('该选项已存在!');
                    }
                } else {
                    alert('请输入选项名称!');
                }
            });

            // 确认按钮点击事件
            confirmBtn.addEventListener('click', function() {
                const selectedOptions = Array.from(checkboxGroup.querySelectorAll('input[type="checkbox"]:checked'))
                    .map(checkbox => {
                        // 获取对应的文本标签内容
                        return checkbox.nextSibling.textContent.trim();
                    });

                if (selectedOptions.length > 0) {
                    // 清空结果列表
                    resultList.innerHTML = '';

                    // 添加选中的选项到结果列表
                    let answer = ''
                    selectedOptions.forEach(option => {
                        const item = document.createElement('div');
                        item.className = 'result-item';
                        item.textContent = option;
                        answer += option + ' '
                        resultList.appendChild(item);
                    });

                    // 显示弹窗
                    modal.style.display = 'block';
                    agentCallbackObject.sendMessage(answer);
                } else {
                    alert('请至少选择一个选项!');
                }
            });

            // 关闭弹窗
            closeBtn.addEventListener('click', function() {
                modal.style.display = 'none';
            });

            // 点击弹窗外部关闭
            window.addEventListener('click', function(event) {
                if (event.target === modal) {
                    modal.style.display = 'none';
                }
            });
        });
    </script>
    </body>
    </html>
    '''
 }

@tool[
    description: 'Multi-select lists, Use only when the user is required to select more than one option.',
    parameters: {
        items: "A list containing strings to be displayed, if the list contains conflicting information such as 'yes', 'no', etc., it does not apply"
    },
    terminal: true
]
public func multiListUI(info: OptionInfo): String {
    template_multi_list(info)
}

@template
func template_clock() {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
            * {
                box-sizing: border-box;
                font-family: 'Helvetica Neue', Arial, sans-serif;
                -webkit-user-select: none;
                user-select: none;
            }

            body {
                margin: 0;
                padding: 20px;
                background-color: hsl(0, 0%, 96%)
                display: flex;
                flex-direction: column;
                align-items: center;
                min-height: 100vh;
            }

            .container {
                width: 100%;
                max-width: 400px;
                background-color: white;
                border-radius: 15px;
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
                padding: 20px;
            }

            h1 {
                text-align: center;
                color: hsl(0, 0%, 20%)
                margin-bottom: 30px;
            }

            .time-display {
                font-size: 48px;
                text-align: center;
                margin: 20px 0;
                font-weight: bold;
                color: hsl(0, 0%, 20%)
            }

            .picker-wrapper {
                display: flex;
                justify-content: center;
                gap: 20px;
                margin: 30px 0;
            }

            .picker-column {
                width: 80px;
                height: 200px;
                position: relative;
                overflow: hidden;
            }

            .picker-mask {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: linear-gradient(to bottom,
                    rgba(255,255,255,0.9) 0%,
                    rgba(255,255,255,0.7) 30%,
                    rgba(255,255,255,0) 50%,
                    rgba(255,255,255,0) 50%,
                    rgba(255,255,255,0.7) 70%,
                    rgba(255,255,255,0.9) 100%);
                pointer-events: none;
            }

            .picker-highlight {
                position: absolute;
                top: 60%;
                left: 0;
                width: 100%;
                height: 50px;
                transform: translateY(-50%);
                border-top: 1px solid hsl(217, 89%, 61%);
                border-bottom: 1px solid hsl(217, 89%, 61%);
                pointer-events: none;
            }

            .picker-list {
                list-style: none;
                padding: 0;
                margin: 0;
                position: absolute;
                top: 50%;
                left: 0;
                width: 100%;
                transform: translateY(-50%);
            }

            .picker-item {
                height: 50px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 22px;
                color: gray;
                transition: all 0.2s ease-out;
            }

            .picker-item.selected {
                color: hsl(0, 0%, 20%);
                font-size: 26px;
                font-weight: bold;
            }

            .confirm-btn {
                display: block;
                width: 100%;
                padding: 15px;
                background-color: hsl(217, 89%, 61%);
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 16px;
                font-weight: bold;
                margin-top: 30px;
                cursor: pointer;
            }
        </style>
    </head>
    <body>
    <div class="container">
        <h1>设置时间</h1>
        <div class="time-display" id="timeDisplay">08:00</div>

        <div class="picker-wrapper">
            <div class="picker-column" id="hourColumn">
                <div class="picker-mask"></div>
                <div class="picker-highlight"></div>
                <ul class="picker-list" id="hourList"></ul>
            </div>

            <div class="picker-column" id="minuteColumn">
                <div class="picker-mask"></div>
                <div class="picker-highlight"></div>
                <ul class="picker-list" id="minuteList"></ul>
            </div>
        </div>

        <button class="confirm-btn" id="confirmBtn">确认</button>
    </div>

    <script>
        document.addEventListener(\'DOMContentLoaded\', function() {
            // 初始化变量
            let selectedHour = 8;
            let selectedMinute = 0;
            let hourItems = [];
            let minuteItems = [];
            var flag = true;



            // 生成小时选项 (0-23)
            const hourList = document.getElementById(\'hourList\');
            for (let i = 0; i < 24; i++) {
                const hour = document.createElement(\'li\');
                hour.className = \'picker-item\';
                hour.textContent = i.toString().padStart(2, \'0\');
                hour.dataset.value = i;
                hourList.appendChild(hour);
                hourItems.push(hour);
            }

            // 生成分钟选项 (0-59)
            const minuteList = document.getElementById(\'minuteList\');
            for (let i = 0; i < 60; i++) {
                const minute = document.createElement(\'li\');
                minute.className = \'picker-item\';
                minute.textContent = i.toString().padStart(2, \'0\');
                minute.dataset.value = i;
                minuteList.appendChild(minute);
                minuteItems.push(minute);
            }

            // 更新显示的时间和选中状态
            function updateTimeDisplay() {
                document.getElementById('timeDisplay').textContent =
                    `\${selectedHour.toString().padStart(2, \'0\')}:\${selectedMinute.toString().padStart(2, \'0\')}`;

                updateSelectedItems();
            }

            // 更新选中项的状态
            function updateSelectedItems() {
                hourItems.forEach(item => {
                    item.classList.remove(\'selected\');
                    if (parseInt(item.dataset.value) === selectedHour) {
                        item.classList.add(\'selected\');
                    }
                });

                minuteItems.forEach(item => {
                    item.classList.remove(\'selected\');
                    if (parseInt(item.dataset.value) === selectedMinute) {
                        item.classList.add(\'selected\');
                    }
                });
            }

            // 初始化选择器
            function setupPicker(column, list, isHour) {
                const itemHeight = 50;
                let startY = 0;
                let startPosition = 0;
                let currentPosition = 0;
                let isDragging = false;
                let velocity = 0;
                let lastY = 0;
                let lastTime = 0;
                let animationId = null;

                // 计算位置对应的值
                function getValueFromPosition(pos) {
                    const maxItems = isHour ? 24 : 60;
                    return Math.min(maxItems - 1, Math.max(0, Math.round(-pos / itemHeight)));
                }

                // 限制位置范围
                function constrainPosition(pos) {
                    const min = isHour ? -23 * itemHeight : -59 * itemHeight;
                    return Math.min(0, Math.max(min, pos));
                }

                // 更新位置和显示
                function updatePosition(pos) {
                    currentPosition = constrainPosition(pos);
                    list.style.transform = `translateY(\${currentPosition}px)`;

                    const value = getValueFromPosition(currentPosition);
                    if (isHour) {
                        selectedHour = value;
                    } else {
                        selectedMinute = value;
                    }
                    updateTimeDisplay();
                }

                // 惯性滚动效果
                function momentumScroll() {
                    if (Math.abs(velocity) > 1) {
                        currentPosition += velocity;
                        velocity *= 0.95; // 减速因子
                        updatePosition(currentPosition);
                        animationId = requestAnimationFrame(momentumScroll);
                    } else {
                        snapToNearest();
                    }
                }

                // 对齐到最近的选项
                function snapToNearest() {
                    cancelAnimationFrame(animationId);
                    const targetPos = -getValueFromPosition(currentPosition) * itemHeight;

                    // 平滑过渡
                    list.style.transition = \'transform 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94)\';
                    currentPosition = targetPos;
                    list.style.transform = `translateY(\${targetPos}px)`;

                    setTimeout(() => {
                        list.style.transition = \'\';
                    }, 300);
                }

                // 鼠标/触摸事件
                column.addEventListener(\'mousedown\', (e) => {
                    e.preventDefault();
                    isDragging = true;
                    startY = e.clientY;
                    startPosition = currentPosition;
                    velocity = 0;
                    lastY = e.clientY;
                    lastTime = Date.now();
                });

                document.addEventListener(\'mousemove\', (e) => {
                    if (!isDragging) return;

                    const now = Date.now();
                    const deltaY = e.clientY - startY;
                    const deltaTime = now - lastTime;

                    if (deltaTime > 0) {
                        velocity = (e.clientY - lastY) / deltaTime * 16;
                        lastY = e.clientY;
                        lastTime = now;
                    }

                    updatePosition(startPosition + deltaY);
                });

                document.addEventListener(\'mouseup\', () => {
                    if (!isDragging) return;
                    isDragging = false;

                    if (Math.abs(velocity) > 5) {
                        momentumScroll();
                    } else {
                        snapToNearest();
                    }
                });

                // 触摸事件
                column.addEventListener(\'touchstart\', (e) => {
                    isDragging = true;
                    startY = e.touches[0].clientY;
                    startPosition = currentPosition;
                    velocity = 0;
                    lastY = e.touches[0].clientY;
                    lastTime = Date.now();
                    e.preventDefault();
                }, { passive: false });

                document.addEventListener(\'touchmove\', (e) => {
                    if (!isDragging) return;

                    const now = Date.now();
                    const deltaY = e.touches[0].clientY - startY;
                    const deltaTime = now - lastTime;

                    if (deltaTime > 0) {
                        velocity = (e.touches[0].clientY - lastY) / deltaTime * 16;
                        lastY = e.touches[0].clientY;
                        lastTime = now;
                    }

                    updatePosition(startPosition + deltaY);
                    e.preventDefault();
                }, { passive: false });

                document.addEventListener(\'touchend\', () => {
                    if (!isDragging) return;
                    isDragging = false;

                    if (Math.abs(velocity) > 5) {
                        momentumScroll();
                    } else {
                        snapToNearest();
                    }
                });

                // 滚轮事件
                column.addEventListener(\'wheel\', (e) => {
                    e.preventDefault();
                    updatePosition(currentPosition + e.deltaY * 0.5);
                    snapToNearest();
                }, { passive: false });

                // 设置初始位置
                updatePosition(isHour ? -selectedHour * itemHeight : -selectedMinute * itemHeight);
            }

            // 初始化picker
            setupPicker(document.getElementById(\'hourColumn\'), hourList, true);
            setupPicker(document.getElementById(\'minuteColumn\'), minuteList, false);

            // 确认按钮事件
            document.getElementById('confirmBtn').addEventListener('click', function() {
                if (flag) {
                    agentCallbackObject.sendMessage("时间选择: " + `\${selectedHour.toString().padStart(2, \'0\')}:\${selectedMinute.toString().padStart(2, \'0\')}`);
                    flag = false
                }
            });
        });
    </script>
    </body>
    </html>
    '''
 }

@tool[
    description: "This function is used to help the user set the time(including hours and minutes), and is useful for selecting a point in time",
    terminal: true,
]
public func clockUI(): String {
    template_clock()
}

@template
func template_detailed_time() {
    '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            :root {
                --primary-color: hsl(229, 85%, 60%);
                --secondary-color: hsl(244, 59%, 50%);
                --light-color: hsl(210, 17%, 98%);
                --dark-color: hsl(210, 11%, 15%);
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            html, body {
                margin: 0;
                padding: 0;
                height: auto;
                min-height: 0;
            }

            body {
                background-color: hsl(216, 33%, 97%);
                color: hsl(210, 11%, 15%);
                display: flex;
                justify-content: center;
                align-items: center;
            }

            .container {
                background-color: white;
                border-radius: 10px;
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
                width: 100%;
                max-width: 650px;
                overflow: hidden;
            }

            .header {
                background: linear-gradient(135deg, hsl(229, 85%, 60%), hsl(244, 59%, 50%));
                color: white;
                padding: 15px;
                text-align: center;
            }

            .header h1 {
                font-size: 1.2rem;
                font-weight: 600;
                margin-bottom: 3px;
            }

            .header p {
                font-size: 0.8rem;
                opacity: 0.9;
            }

            .booking-container {
                padding: 20px;
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 15px;
            }

            @media (max-width: 650px) {
                .booking-container {
                    grid-template-columns: 1fr;
                }
            }

            .left-column {
                display: flex;
                flex-direction: column;
                gap: 15px;
            }

            .right-column {
                display: flex;
                flex-direction: column;
            }

            .section {
                background-color: hsl(210, 17%, 98%);
                border-radius: 6px;
                padding: 15px;
            }

            .section-title {
                font-size: 0.9rem;
                font-weight: 600;
                margin-bottom: 10px;
                color: hsl(229, 85%, 60%);
                display: flex;
                align-items: center;
                gap: 5px;
            }

            .section-title i {
                font-size: 1rem;
            }

            .calendar {
                width: 100%;
                border-collapse: collapse;
                font-size: 0.8rem;
            }

            .calendar th {
                padding: 5px 0;
                color: hsl(229, 85%, 60%);
                font-weight: 500;
            }

            .calendar td {
                text-align: center;
                padding: 4px 0;
                cursor: pointer;
                width: 14.28%;
                position: relative;
            }

            .calendar td.day:after {
                content: '';
                display: block;
                padding-bottom: 100%;
            }

            .calendar .day span {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                width: 24px;
                height: 24px;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 50%;
            }

            .calendar .day.selected span {
                background-color: hsl(229, 85%, 60%);
                color: white;
                font-weight: 600;
            }

            .calendar .day.today span {
                font-weight: bold;
                color: hsl(229, 85%, 60%);
            }

            .calendar .day.disabled {
                color: hsl(0, 0%, 80%);
                cursor: not-allowed;
            }

            .time-slots {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 8px;
                margin-bottom: 10px;
            }

            .time-slot {
                background-color: white;
                border: 1px solid hsl(0, 0%, 87%);
                border-radius: 4px;
                padding: 5px;
                text-align: center;
                cursor: pointer;
                font-size: 0.75rem;
            }

            .time-slot.selected {
                background-color: hsl(229, 85%, 60%);
                color: white;
                border-color: hsl(229, 85%, 60%);
            }

            .duration-options {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 8px;
            }

            .duration-option {
                display: flex;
                align-items: center;
                padding: 6px 10px;
                background-color: white;
                border: 1px solid hsl(0, 0%, 87%);
                border-radius: 4px;
                cursor: pointer;
                font-size: 0.8rem;
            }

            .duration-option.selected {
                background-color: rgba(67, 97, 238, 0.1);
                border-color: hsl(229, 85%, 60%);
            }

            .duration-option input {
                margin-right: 6px;
                transform: scale(0.9);
            }

            .footer {
                padding: 15px;
                display: flex;
                justify-content: center;
            }

            .btn {
                padding: 8px 20px;
                border-radius: 20px;
                border: none;
                font-size: 0.85rem;
                background-color: hsl(229, 85%, 60%);
                color: white;
                cursor: pointer;
            }

            .btn:disabled {
                background-color: hsl(0, 0%, 80%);
                cursor: not-allowed;
            }

            .month-navigation {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 10px;
                font-size: 0.9rem;
            }

            .nav-btn {
                background: none;
                border: none;
                font-size: 1rem;
                cursor: pointer;
                color: hsl(229, 85%, 60%);
                padding: 2px 8px;
            }

            .time-info {
                margin-top: 10px;
                font-size: 0.8rem;
                color: hsl(0, 0%, 40%);
            }

            .time-info strong {
                color: hsl(229, 85%, 60%);
                font-size: 0.85rem;
            }
        </style>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    </head>
    <body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-calendar-alt"></i> 时间设置 </h1>
            <p>请选择日期、时间和时长</p>
        </div>

        <div class="booking-container">
            <div class="left-column">
                <div class="section calendar-section">
                <div class="month-navigation">
                    <button class="nav-btn" id="prev-month"><i class="fas fa-chevron-left"></i></button>
                    <div class="month-title" id="current-month"></div>
                    <button class="nav-btn" id="next-month"><i class="fas fa-chevron-right"></i></button>
                </div>

                <table class="calendar" id="calendar">
                    <thead>
                    <tr>
                        <th>日</th>
                        <th>一</th>
                        <th>二</th>
                        <th>三</th>
                        <th>四</th>
                        <th>五</th>
                        <th>六</th>
                    </tr>
                    </thead>
                    <tbody id="calendar-body"></tbody>
                </table>
            </div>

            <div class="section duration-section">
            <div class="section-title">
                <i class="fas fa-hourglass-half"></i> 选择时长
            </div>
            <div class="duration-options">
                <label class="duration-option selected">
                <input type="radio" name="duration" value="30" checked> 30分钟
                </label>
                <label class="duration-option">
                    <input type="radio" name="duration" value="60"> 60分钟
                </label>
                <label class="duration-option">
                    <input type="radio" name="duration" value="90"> 90分钟
                </label>
                <label class="duration-option">
                    <input type="radio" name="duration" value="120"> 120分钟
                </label>
            </div>
        </div>
    </div>

    <div class="right-column">
        <div class="section time-section">
        <div class="section-title">
            <i class="far fa-clock"></i> 选择时间
        </div>
        <div class="time-slots" id="time-slots"></div>
        <div class="time-info" id="time-info">
            请先选择日期
        </div>
    </div>
    </div>
    </div>

    <div class="footer">
        <button class="btn" id="confirm-btn" disabled>
            <i class="fas fa-check-circle"></i> 确认预定
        </button>
    </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            let currentDate = new Date();
            let selectedDate = null;
            let selectedTime = null;

            // 初始化日历
            function initCalendar() {
                updateCalendar(currentDate);
                generateTimeSlots();
                setupDurationOptions();
            }

            // 更新日历显示
            function updateCalendar(date) {
                const year = date.getFullYear();
                const month = date.getMonth();
                document.getElementById('current-month').textContent = `\${year}年\${month + 1}月`;

                const firstDay = new Date(year, month, 1);
                const lastDay = new Date(year, month + 1, 0);
                const daysInMonth = lastDay.getDate();
                const firstDayOfWeek = firstDay.getDay();

                const calendarBody = document.getElementById('calendar-body');
                calendarBody.innerHTML = '';

                let dateNum = 1;
                let row = document.createElement('tr');

                // 创建日历的第一行（可能需要填充上个月的天数）
                if (firstDayOfWeek > 0) {
                    const prevMonthLastDay = new Date(year, month, 0).getDate();
                    for (let i = 0; i < firstDayOfWeek; i++) {
                        const cell = createDayCell(prevMonthLastDay - (firstDayOfWeek - 1 - i), true);
                        row.appendChild(cell);
                    }
                }

                // 填充当前月的第一天
                for (let i = firstDayOfWeek; i < 7; i++) {
                    const cell = createDayCell(dateNum, false, year, month);
                    row.appendChild(cell);
                    dateNum++;
                }
                calendarBody.appendChild(row);

                // 继续填充剩余的天数
                while (dateNum <= daysInMonth) {
                    row = document.createElement('tr');
                    for (let i = 0; i < 7 && dateNum <= daysInMonth; i++) {
                        const cell = createDayCell(dateNum, false, year, month);
                        row.appendChild(cell);
                        dateNum++;
                    }

                    // 如果到最后一周且天数不足7天，补充下个月的天数
                    if (dateNum > daysInMonth) {
                        for (let i = row.children.length; i < 7; i++) {
                            const cell = createDayCell(dateNum - daysInMonth + (i - row.children.length), true);
                            row.appendChild(cell);
                        }
                    }

                    calendarBody.appendChild(row);
                }
            }

            // 创建日期单元格
            function createDayCell(day, isDisabled, year, month) {
                const cell = document.createElement('td');
                const daySpan = document.createElement('span');
                daySpan.textContent = day;

                if (isDisabled) {
                    cell.classList.add('disabled');
                } else {
                    cell.classList.add('day');

                    // 检查是否是今天
                    const today = new Date();
                    if (year === today.getFullYear() &&
                        month === today.getMonth() &&
                        day === today.getDate()) {
                        cell.classList.add('today');
                    }

                    // 检查是否是选中的日期
                    if (selectedDate &&
                        year === selectedDate.getFullYear() &&
                        month === selectedDate.getMonth() &&
                        day === selectedDate.getDate()) {
                        cell.classList.add('selected');
                    }

                    // 添加点击事件
                    cell.addEventListener('click', function() {
                        selectDate(new Date(year, month, day));
                    });
                }

                cell.appendChild(daySpan);
                return cell;
            }

            // 选择日期
            function selectDate(date) {
                selectedDate = date;
                // 清除之前选中的时间
                if (selectedTime) {
                    selectedTime = null;
                    document.querySelectorAll('.time-slot.selecte').forEach(slot => {
                        slot.classList.remove('selected');
                    });
                }
                updateCalendar(currentDate);
                updateTimeInfo();
                checkBookingValid();
            }

            // 生成时间选项
            function generateTimeSlots() {
                const timeSlotsContainer = document.getElementById('time-slots');
                timeSlotsContainer.innerHTML = '';

                // 生成从9点到17点的时间选项
                for (let hour = 9; hour <= 17; hour++) {
                    for (let minute = 0; minute < 60; minute += 30) {
                        const timeSlot = document.createElement('div');
                        timeSlot.classList.add('time-slot');

                        const displayHour = hour.toString().padStart(2, '0');
                        const displayMinute = minute.toString().padStart(2, '0');
                        timeSlot.textContent = `\${displayHour}:\${displayMinute}`;
                        timeSlot.dataset.time = `\${displayHour}:\${displayMinute}`;

                        timeSlot.addEventListener('click', function() {
                            selectTime(this.dataset.time);
                        });

                        timeSlotsContainer.appendChild(timeSlot);
                    }
                }
            }

            // 选择时间
            function selectTime(time) {
                selectedTime = time;

                // 更新UI显示
                document.querySelectorAll('.time-slot').forEach(slot => {
                    slot.classList.remove('selected');
                    if (slot.dataset.time === time) {
                        slot.classList.add('selected');
                    }
                });

                updateTimeInfo();
                checkBookingValid();
            }

            // 更新时间信息显示
            function updateTimeInfo() {
                const timeInfo = document.getElementById('time-info');

                if (selectedDate && selectedTime) {
                    const dateStr = `\${selectedDate.getFullYear()}年\${selectedDate.getMonth() + 1}月\${selectedDate.getDate()}日`;
                    timeInfo.innerHTML = `您选择了: <strong>\${dateStr} \${selectedTime}</strong>`;
                } else if (selectedDate) {
                    const dateStr = `\${selectedDate.getFullYear()}年\${selectedDate.getMonth() + 1}月\${selectedDate.getDate()}日`;
                    timeInfo.innerHTML = `您选择了: <strong>\${dateStr}</strong>, 请选择具体时间`;
                } else {
                    timeInfo.textContent = '请先选择日期';
                }
            }

            // 设置时长选项
            function setupDurationOptions() {
                document.querySelectorAll('.duration-option').forEach(option => {
                    option.addEventListener('click', function() {
                        document.querySelectorAll('.duration-option').forEach(opt => {
                            opt.classList.remove('selected');
                        });
                        this.classList.add('selected');
                        this.querySelector('input').checked = true;
                    });
                });
            }

            // 检查预订是否有效
            function checkBookingValid() {
                document.getElementById('confirm-btn').disabled = !(selectedDate && selectedTime);
            }

            // 月份导航事件
            document.getElementById('prev-month').addEventListener('click', function() {
                currentDate.setMonth(currentDate.getMonth() - 1);
                updateCalendar(currentDate);
            });

            document.getElementById('next-month').addEventListener('click', function() {
                currentDate.setMonth(currentDate.getMonth() + 1);
                updateCalendar(currentDate);
            });
            var flag = true
            // 确认预订按钮事件
            document.getElementById('confirm-btn').addEventListener('click', function() {
                if (selectedDate && selectedTime && flag) {
                    const duration = document.querySelector('input[name="duration"]:checked').value;
                    const dateStr = `\${selectedDate.getFullYear()}年\${selectedDate.getMonth() + 1}月\${selectedDate.getDate()}日`;
                    agentCallbackObject.sendMessage("时间选择: " + `\n日期: \${dateStr}\n时间: \${selectedTime}\n时长: \${duration}分钟`);
                    flag = false
                }
            });

            // 初始化日历
            initCalendar();
        });
    </script>
    </body>
    </html>
    '''
 }

@tool[
    description: "This function is used to set a specific date, time, and duration, and is suitable for scenarios that require a select period of time",
    terminal: true
]
public func detailedTimeUI(): String {
    template_detailed_time()
}

@template
func template_start_end_date_selection() {
    '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css" rel="stylesheet">
        <style>
            /* 基础样式 */
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
                background-color: hsl(216, 33%, 97%);
                margin: 0;
                padding: 0;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 0 16px;
            }

            /* 按钮样式 */
            button {
                cursor: pointer;
                background: none;
                border: none;
                font-family: inherit;
                transition: all 0.2s ease;
            }

            .btn-primary {
                background-color: hsl(212, 80%, 42%);
                color: white;
                padding: 10px 16px;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 500;
                margin-top: 10px;
            }

            .btn-primary:hover {
                background-color: hsl(212, 80%, 37%);
                transform: translateY(-1px);
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            }

            .btn-secondary {
                color: hsl(0, 0%, 40%);
                padding: 8px 12px;
                border-radius: 4px;
                font-size: 14px;
            }

            .btn-secondary:hover {
                background-color: hsl(0, 0%, 93%);
                color: hsl(0, 0%, 30%);
            }

            /* 卡片样式 */
            .card {
                background-color: white;
                border-radius: 16px;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
                padding: 24px;
                margin-bottom: 32px;
            }

            /* 输入框样式 */
            .input-group {
                margin-bottom: 16px;
            }

            .input-group label {
                display: block;
                font-size: 14px;
                font-weight: 500;
                color: hsl(0, 0%, 33%);
                margin-bottom: 6px;
            }

            .input-group input {
                padding: 10px 14px;
                border: 1px solid hsl(0, 0%, 80%);
                border-radius: 8px;
                font-size: 16px;
                color: hsl(0, 0%, 15%);
                background-color: white;
                outline: none;
                transition: border-color 0.2s ease, box-shadow 0.2s ease;
            }

            .input-group input:focus {
                border-color: hsl(212, 80%, 42%);
                box-shadow: 0 0 0 3px hsla(212, 80%, 42%, 0.2);
            }

            .input-group input::placeholder {
                color: hsl(0, 0%, 60%);
            }

            /* 日历样式 */
            .calendar {
                border: 1px solid hsl(0, 0%, 87%);
                border-radius: 8px;
                overflow: hidden;
                margin-top: 24px;
                background-color: white;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            }

            .calendar-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 16px;
                border-bottom: 1px solid hsl(0, 0%, 93%);
            }

            .calendar-header h3 {
                margin: 0;
                font-size: 18px;
                font-weight: 500;
                color: hsl(0, 0%, 15%);
            }

            .calendar-grid {
                display: grid;
                grid-template-columns: repeat(7, 1fr);
                gap: 2px;
                padding: 12px;
            }

            .calendar-day-names {
                margin-bottom: 8px;
            }

            .calendar-day-names div {
                text-align: center;
                font-size: 12px;
                font-weight: 500;
                color: hsl(0, 0%, 40%);
                padding: 6px 0;
            }

            .calendar-days .day {
                aspect-ratio: 1;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 14px;
                color: hsl(0, 0%, 15%);
                border-radius: 50%;
                transition: all 0.2s ease;
                cursor: pointer;
            }

            .calendar-days .day.other-month {
                color: hsl(0, 0%, 60%);
                opacity: 0.5;
                cursor: default;
            }

            .calendar-days .day.today {
                font-weight: 600;
                box-shadow: inset 0 0 0 1px hsl(212, 80%, 42%);
            }

            .calendar-days .day.start-date,
            .calendar-days .day.end-date {
                background-color: hsl(212, 80%, 42%);
                color: white;
                font-weight: 600;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }

            .calendar-days .day.in-range {
                background-color: hsl(212, 80%, 90%);
                border-radius: 0;
            }

            .calendar-days .day:not(.other-month):hover:not(.start-date):not(.end-date):not(.in-range) {
                background-color: hsl(0, 0%, 93%);
            }

            .calendar-footer {
                display: flex;
                justify-content: space-between;
                padding: 12px 16px;
                border-top: 1px solid hsl(0, 0%, 93%);
            }

            /* 日期范围信息 */
            .date-range-info {
                padding: 12px;
                background-color: hsl(203, 77%, 95%);
                border: 1px solid hsl(203, 77%, 90%);
                border-radius: 8px;
                margin-top: 16px;
                color: hsl(203, 77%, 25%);
                font-size: 14px;
            }

            /* 动画效果 */
            .fade-in {
                animation: fadeIn 0.3s ease forwards;
            }

            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(10px); }
                to { opacity: 1; transform: translateY(0); }
            }

            /* 响应式布局 */
            @media (min-width: 768px) {
                .date-inputs {
                    display: flex;
                    gap: 16px;
                }

                .date-inputs .input-group {
                    flex: 1;
                }
            }
        </style>
    </head>
    <body class="bg-neutral-100 min-h-screen flex flex-col">
    <main class="flex-grow container py-8">
    <div class="max-w-3xl mx-auto card">
    <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">选择日期范围</h2>

        <div class="date-inputs">
            <div class="input-group">
                <label for="startDate">起始日期</label>
                <div class="relative">
                    <input type="text" id="startDate" class="w-full" placeholder="点击选择起始日期" readonly>
                </div>
            </div>

            <div class="input-group">
                <label for="endDate">终止日期</label>
                <div class="relative">
                    <input type="text" id="endDate" class="w-full" placeholder="点击选择终止日期" readonly>
                </div>
            </div>
        </div>

        <div id="dateRangeInfo" class="date-range-info hidden">
        <p><span id="selectedRange"></span></p>
    </div>
    </div>

    <div id="calendarContainer" class="hidden calendar fade-in">
    <div class="calendar-header">
        <button id="prevMonth" class="btn-secondary">
            <i class="fa fa-chevron-left"></i>
        </button>
        <h3 id="currentMonth"></h3>
        <button id="nextMonth" class="btn-secondary">
            <i class="fa fa-chevron-right"></i>
        </button>
    </div>

    <div class="calendar-grid calendar-day-names">
    <div>日</div>
    <div>一</div>
    <div>二</div>
    <div>三</div>
    <div>四</div>
    <div>五</div>
    <div>六</div>
    </div>

    <div id="calendarDays" class="calendar-grid calendar-days"></div>

    <div class="calendar-footer">
        <button id="clearDates" class="btn-secondary">
            <i class="fa fa-refresh mr-1"></i> 重置
        </button>
        <button id="closeCalendar" class="btn-secondary">
            <i class="fa fa-times mr-1"></i> 关闭
        </button>
    </div>
    </div>

    <div class="mt-8 flex justify-end">
    <button id="applyDates" class="btn-primary" disabled>
        <i class="fa fa-check mr-2"></i>应用选择
    </button>
    </div>
    </div>
    </main>

    <script>
        // 当前选中的日期
        let selectedStartDate = null;
        let selectedEndDate = null;
        let currentViewDate = new Date();
        let isSelectingStartDate = true; // 用户是否正在选择起始日期

        // DOM 元素
        const startDateInput = document.getElementById('startDate');
        const endDateInput = document.getElementById('endDate');
        const calendarContainer = document.getElementById('calendarContainer');
        const currentMonthElement = document.getElementById('currentMonth');
        const calendarDaysElement = document.getElementById('calendarDays');
        const prevMonthButton = document.getElementById('prevMonth');
        const nextMonthButton = document.getElementById('nextMonth');
        const closeCalendarButton = document.getElementById('closeCalendar');
        const clearDatesButton = document.getElementById('clearDates');
        const applyDatesButton = document.getElementById('applyDates');
        const dateRangeInfo = document.getElementById('dateRangeInfo');
        const selectedRangeElement = document.getElementById('selectedRange');

        // 初始化事件监听
        startDateInput.addEventListener('click', () => showCalendar(true));
        endDateInput.addEventListener('click', () => showCalendar(false));
        prevMonthButton.addEventListener('click', showPreviousMonth);
        nextMonthButton.addEventListener('click', showNextMonth);
        closeCalendarButton.addEventListener('click', hideCalendar);
        clearDatesButton.addEventListener('click', clearSelectedDates);
        applyDatesButton.addEventListener('click', applySelectedDates);

        // 显示日历
        function showCalendar(forStartDate) {
            isSelectingStartDate = forStartDate;
            calendarContainer.classList.remove('hidden');

            // 如果是选择起始日期但已有起始日期，则跳转到该月
            if (isSelectingStartDate && selectedStartDate) {
                currentViewDate = new Date(selectedStartDate);
            }
            // 如果是选择终止日期但已有终止日期，则跳转到该月
            else if (!isSelectingStartDate && selectedEndDate) {
                currentViewDate = new Date(selectedEndDate);
            }

            renderCalendar();
        }
        showCalendar(true)

        // 隐藏日历
        function hideCalendar() {
            calendarContainer.classList.add('hidden');
        }

        // 渲染日历
        function renderCalendar() {
            const year = currentViewDate.getFullYear();
            const month = currentViewDate.getMonth();

            // 更新当前月份显示
            currentMonthElement.textContent = `\${year}年 \${month + 1}月`;

            // 清空日历
            calendarDaysElement.innerHTML = '';

            // 获取当月第一天和最后一天
            const firstDay = new Date(year, month, 1);
            const lastDay = new Date(year, month + 1, 0);

            // 获取当月第一天是星期几 (0-6)
            const firstDayOfWeek = firstDay.getDay();

            // 获取上个月的最后几天
            const prevMonthLastDay = new Date(year, month, 0).getDate();

            // 生成日历格子
            // 添加上个月的最后几天
            for (let i = firstDayOfWeek; i > 0; i--) {
                const day = prevMonthLastDay - i + 1;
                const date = new Date(year, month - 1, day);
                addCalendarDay(date, true);
            }

            // 添加当月的天数
            for (let i = 1; i <= lastDay.getDate(); i++) {
                const date = new Date(year, month, i);
                addCalendarDay(date, false);
            }

            // 添加下个月的开始几天，使日历总共有42个格子 (6行7列)
            const nextMonthDays = 42 - (firstDayOfWeek + lastDay.getDate());
            for (let i = 1; i <= nextMonthDays; i++) {
                const date = new Date(year, month + 1, i);
                addCalendarDay(date, true);
            }

            // 更新应用按钮状态
            updateApplyButton();
        }

        // 添加日历中的一天
        function addCalendarDay(date, isOtherMonth) {
            const dayElement = document.createElement('div');
            dayElement.className = 'day';

            const dayNumber = date.getDate();
            const isToday = isSameDay(date, new Date());
            const isStartDate = selectedStartDate && isSameDay(date, selectedStartDate);
            const isEndDate = selectedEndDate && isSameDay(date, selectedEndDate);
            const isInRange = selectedStartDate && selectedEndDate &&
                            date > selectedStartDate && date < selectedEndDate;

            // 其他月份的日期
            if (isOtherMonth) {
                dayElement.textContent = dayNumber;
                dayElement.classList.add('other-month');
            }
            // 当月日期
            else {
                dayElement.textContent = dayNumber;

                // 如果有起始日期和终止日期，且当前日期在范围内
                if (isInRange) {
                    dayElement.classList.add('in-range');
                }

                // 如果是起始日期
                if (isStartDate) {
                    dayElement.classList.add('start-date');
                }

                // 如果是终止日期
                if (isEndDate) {
                    dayElement.classList.add('end-date');
                }

                // 如果是今天
                if (isToday && !isStartDate && !isEndDate) {
                    dayElement.classList.add('today');
                }

                // 如果是可选日期
                if (!isOtherMonth) {
                    dayElement.addEventListener('click', () => selectDate(date));
                }
            }

            // 禁用早于今天的日期选择（可选）
            if (!isOtherMonth && date < new Date().setHours(0, 0, 0, 0)) {
                dayElement.classList.add('disabled');
                dayElement.style.pointerEvents = 'none';
                dayElement.style.opacity = '0.4';
            }

            calendarDaysElement.appendChild(dayElement);
        }

        // 选择日期
        function selectDate(date) {
            if (isSelectingStartDate) {
                // 选择起始日期
                selectedStartDate = date;

                // 如果已有终止日期，且终止日期早于新选择的起始日期，则清除终止日期
                if (selectedEndDate && selectedEndDate < selectedStartDate) {
                    selectedEndDate = null;
                    endDateInput.value = '';
                }

                // 更新输入框
                startDateInput.value = formatDate(date);

                // 切换到选择终止日期模式
                isSelectingStartDate = false;

                // 如果没有选择终止日期，则聚焦到终止日期输入框
                if (!selectedEndDate) {
                    setTimeout(() => {
                        endDateInput.click();
                    }, 10);
                }
            } else {
                // 选择终止日期（必须晚于或等于起始日期）
                if (selectedStartDate && date >= selectedStartDate) {
                    selectedEndDate = date;
                    endDateInput.value = formatDate(date);

                    // 显示选择的日期范围
                    showDateRangeInfo();

                    // 隐藏日历
                    hideCalendar();
                }
            }

            // 重新渲染日历以反映选择
            renderCalendar();
        }

        // 显示上一个月
        function showPreviousMonth() {
            currentViewDate.setMonth(currentViewDate.getMonth() - 1);
            renderCalendar();
        }

        // 显示下一个月
        function showNextMonth() {
            currentViewDate.setMonth(currentViewDate.getMonth() + 1);
            renderCalendar();
        }

        // 清除已选日期
        function clearSelectedDates() {
            selectedStartDate = null;
            selectedEndDate = null;
            startDateInput.value = '';
            endDateInput.value = '';
            dateRangeInfo.classList.add('hidden');
            renderCalendar();
        }

        // 应用选择的日期
        var flag = true
        function applySelectedDates() {
            if (selectedStartDate && selectedEndDate && flag) {
                agentCallbackObject.sendMessage("您选择的日期范围是:" + `\${formatDate(selectedStartDate)} 至 \${formatDate(selectedEndDate)}`)
                flag = false
            }
        }

        // 显示日期范围信息
        function showDateRangeInfo() {
            if (selectedStartDate && selectedEndDate) {
                const start = formatDate(selectedStartDate);
                const end = formatDate(selectedEndDate);
                selectedRangeElement.textContent = `已选择日期范围: \${start} 至 \${end}`;
                dateRangeInfo.classList.remove('hidden');
            }
        }

        // 更新应用按钮状态
        function updateApplyButton() {
            if (selectedStartDate && selectedEndDate) {
                applyDatesButton.disabled = false;
                applyDatesButton.classList.remove('opacity-50');
            } else {
                applyDatesButton.disabled = true;
                applyDatesButton.classList.add('opacity-50');
            }
        }

        // 辅助函数：检查两个日期是否是同一天
        function isSameDay(date1, date2) {
            return date1.getDate() === date2.getDate() &&
                date1.getMonth() === date2.getMonth() &&
                date1.getFullYear() === date2.getFullYear();
        }

        // 辅助函数：格式化日期为 YYYY-MM-DD
        function formatDate(date) {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `\${year}-\${month}-\${day}`;
        }
    </script>
    </body>
    </html>
    '''
}

@tool[
    description: "This function is used to select the start and end dates to define a time range. For example, it can be used when booking a hotel and buying a round-trip ticket.",
    terminal: true
]
public func startEndDateUI(): String {
    template_start_end_date_selection()
}

@template
func template_single_date_selection(title: String) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>单程车票日期选择</title>
        <style>
            /* 全局样式 */
            body {
            font-family: 'Arial', sans-serif;
            background-color: hsl(210, 20%, 90%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            }

            /* 主容器 */
            .ticket-container {
            background-color: hsl(0, 0%, 100%);
            border-radius: 12px;
            box-shadow: 0 4px 20px hsla(0, 0%, 0%, 0.1);
            padding: 24px;
            width: 90%;
            max-width: 400px;
            }

            /* 标题样式 */
            h3 {
            color: hsl(217, 89%, 61%);
            text-align: center;
            margin-bottom: 24px;
            font-size: 24px;
            }

            /* 表单样式 */
            .form-group {
            margin-bottom: 16px;
            }

            label {
            display: block;
            color: hsl(210, 20%, 30%);
            margin-bottom: 8px;
            font-size: 14px;
            }

            input[type="date"] {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid hsl(210, 20%, 70%);
            border-radius: 6px;
            font-size: 16px;
            color: hsl(210, 20%, 30%);
            box-sizing: border-box;
            }

            input[type="date"]:focus {
            outline: none;
            border-color: hsl(217, 89%, 61%);
            box-shadow: 0 0 0 2px hsla(217, 89%, 61%, 0.2);
            }

            /* 按钮样式 */
            button {
            width: 100%;
            background-color: hsl(217, 89%, 61%);
            color: hsl(0, 0%, 100%);
            border: none;
            border-radius: 6px;
            padding: 12px 0;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.2s;
            }

            button:hover {
            background-color: hsl(217, 89%, 50%);
            }

            button:active {
            background-color: hsl(217, 89%, 40%);
            }

            /* 弹窗样式 */
            .modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: hsla(0, 0%, 0%, 0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s, visibility 0.3s;
            }

            .modal.active {
            opacity: 1;
            visibility: visible;
            }

            .modal-content {
            background-color: hsl(0, 0%, 100%);
            border-radius: 12px;
            padding: 24px;
            width: 90%;
            max-width: 300px;
            transform: scale(0.8);
            transition: transform 0.3s;
            }

            .modal.active .modal-content {
            transform: scale(1);
            }

            .modal-title {
            color: hsl(217, 89%, 61%);
            font-size: 20px;
            margin-bottom: 16px;
            text-align: center;
            }

            .modal-message {
            color: hsl(210, 20%, 30%);
            font-size: 16px;
            margin-bottom: 24px;
            text-align: center;
            }

            .modal-close {
            background-color: hsl(210, 20%, 90%);
            color: hsl(210, 20%, 30%);
            padding: 10px 20px;
            border-radius: 6px;
            cursor: pointer;
            text-align: center;
            transition: background-color 0.2s;
            }

            .modal-close:hover {
            background-color: hsl(210, 20%, 80%);
            }
        </style>
    </head>
    <body>
    <div class="ticket-container">
        <h3>{% title %}</h3>
        <form id="ticket-form">
            <div class="form-group">
                <label for="departure-date">日期选择：</label>
                <input type="date" id="departure-date" required>
            </div>
            <button type="button" id="confirm-btn">确认选择</button>
        </form>
    </div>

    <!-- 弹窗 -->
    <div class="modal" id="date-modal">
        <div class="modal-content">
            <div class="modal-title">您选择的日期</div>
            <div class="modal-message" id="selected-date-text"></div>
            <div class="modal-close" id="close-modal">确定</div>
        </div>
    </div>

    <script>
        // 获取DOM元素
        const confirmBtn = document.getElementById('confirm-btn');
        const departureDate = document.getElementById('departure-date');
        const modal = document.getElementById('date-modal');
        const selectedDateText = document.getElementById('selected-date-text');
        const closeModal = document.getElementById('close-modal');

        // 设置默认日期为今天
        const today = new Date().toISOString().split('T')[0];
        departureDate.value = today;

        // 确认按钮点击事件
        confirmBtn.addEventListener('click', () => {
        const dateValue = departureDate.value;
        if (dateValue) {
            // 格式化日期显示
            const formattedDate = formatDate(dateValue);
            selectedDateText.textContent = formattedDate;

            // 显示弹窗
            modal.classList.add('active');
        }
        });

        // 确认
        var flag = true
        closeModal.addEventListener('click', () => {
        agentCallbackObject.sendMessage("您选择的日期:" + `\${selectedDateText.textContent}`)
        flag = false
        });

        // 点击弹窗外部关闭
        modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.classList.remove('active');
        }
        });

        // 日期格式化函数
        function formatDate(dateString) {
        const date = new Date(dateString);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `\${year}年\${month}月\${day}日`;
        }
    </script>
    </body>
    </html>
    '''
}

@tool[
    description: "This function is used to select a single date. For example, it can be used when purchasing a one-way ticket",
    parameters: {
        title: "A title that describes the specific selection date event"
    },
    terminal: true
]
public func singleDateUI(title: String): String {
    template_single_date_selection(title)
}

//-----------------------------------------Information display--------------------------------------------------------
@jsonable
public class ItemData {
    @field["The title of the information"]
    let name: String
    @field["The main content of the information"]
    let content: String
}

@jsonable
public class TextInfo {
    @field["The theme to be presented"]
    let title: String
    @field["The data information to be displayed"]
    let data: Array<ItemData>
}

@template
func template_text_list(info: TextInfo) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-family: "Microsoft YaHei", sans-serif;
                background-color: hsl(210, 17%, 98%);
                margin: 0;
                padding: 20px;
            }

            .weather-container {
                max-width: 600px;
                margin: 0 auto;
            }

            .title {
                text-align: center;
                margin: 30px 0 20px;
                color: hsl(210, 29%, 20%);
                font-size: 20px;
                font-weight: bold;
            }

            .weather-card {
                background-color: white;
                border-radius: 10px;
                box-shadow: 0 4px 8px hsla(0, 0%, 0%, 0.05);
                padding: 20px;
                margin-bottom: 15px;
                transition: transform 0.2s ease;
                border-left: 4px solid hsl(204, 70%, 53%); /* 统一左侧边框颜色 */
            }

            .weather-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px hsla(0, 0%, 0%, 0.1);
            }

            .card-title {
                color: hsl(210, 29%, 20%);
                font-size: 18px;
                font-weight: bold;
                margin-bottom: 8px;
            }

            .card-content {
                color: hsl(0, 0%, 33%);
                font-size: 16px;
                display: flex;
                align-items: center;
            }

            .date-section {
                background-color: white; /* 统一背景色 */
                border-left: 4px solid hsl(204, 70%, 53%); /* 统一左侧边框颜色 */
            }

            /* 响应式设计 */
            @media (min-width: 768px) {
                .weather-container {
                    display: grid;
                    grid-template-columns: repeat(2, 1fr);
                    gap: 15px;
                }

                .date-section {
                    grid-column: 1 / -1;
                }

                .weather-section {
                    grid-row: 2;
                    grid-column: 1;
                }

                .temp-section {
                    grid-row: 2;
                    grid-column: 2;
                }

                .wind-section {
                    grid-row: 3;
                    grid-column: 1;
                }

                .humidity-section {
                    grid-row: 3;
                    grid-column: 2;
                }
            }
        </style>
    </head>
    <body>
        <div class="weather-container">
            <h2 class="title">{% info.title %}</h2>

            {% for item in info.data %}
            <div class="weather-card date-section">
                <div class="card-title">{% item.name %}</div>
                <div class="card-content">{% item.content %}</div>
            </div>
            {% /for %}
        </div>
    </body>
    </html>
    '''
}

@tool[
    description: "Display information, including textual information only",
    terminal: true
]
public func textListUI(info: TextInfo): String {
    template_text_list(info)
}

@jsonable
public class ImgItem {
    @field["title"]
    let title: String
    @field["The URL of the image, it must be valid"]
    let url: String
}

@template
func template_img_list(items: Array<ImgItem>) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>卡片式图片列表</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                background-color: hsl(0, 0%, 96%);
                padding: 16px;
            }
            .card-list {
                display: grid;
                gap: 16px;
            }
            .card {
                background-color: white;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
                overflow: hidden;
                transition: transform 0.2s, box-shadow 0.2s;
            }
            .card:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
            }
            .card img {
                width: 100%;
                height: auto;
                display: block;
            }
            .card h3 {
                font-size: 16px;
                font-weight: 500;
                padding: 12px 16px;
                color: hsl(0, 0%, 20%);
            }
        </style>
    </head>
    <body>
    <div class="card-list">
        {% for item in items %}
        <div class="card">
            <img src="{% item.url %}">
            <h3>{% item.title %}</h3>
        </div>
        {% /for %}
    </div>
    </body>
    </html>
    '''
}

@tool[
    description: "Image information display, including text and image information",
    terminal: true
]
public func imgListUI(items: Array<ImgItem>): String {
    template_img_list(items)
}

@jsonable
public class TextURLItem {
    @field["title"]
    let title: String
    @field["URL hyperlink"]
    let url: String
    @field["Brief description"]
    let description: String
}

@template
func template_text_url_list(items: Array<TextURLItem>) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>链表展示</title>
        <link href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css" rel="stylesheet">
        <style>
            /* 基础样式 */
            body {
                font-family: 'Inter', system-ui, sans-serif;
                margin: 0;
                padding: 0;
                background-color: hsl(210, 40%, 98%);
                color: hsl(220, 13%, 13%);
            }

            /* 容器样式 */
            .container {
                max-width: 1280px;
                margin: 0 auto;
                padding: 0 16px;
            }

            /* 卡片样式 */
            .card {
                background-color: white;
                border-radius: 12px;
                box-shadow: 0 4px 6px -1px hsla(0, 0%, 0%, 0.1), 0 2px 4px -1px hsla(0, 0%, 0%, 0.06);
                padding: 24px;
                margin-bottom: 32px;
                transition: all 0.3s ease;
            }

            .card:hover {
                box-shadow: 0 10px 15px -3px hsla(0, 0%, 0%, 0.1), 0 4px 6px -2px hsla(0, 0%, 0%, 0.05);
            }

            /* 链接列表样式 */
            .link-list {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .link-item {
                margin-bottom: 16px;
                border-bottom: 1px solid hsl(210, 14%, 89%);
                padding-bottom: 16px;
                transition: all 0.3s ease;
            }

            .link-item:last-child {
                border-bottom: none;
                padding-bottom: 0;
                margin-bottom: 0;
            }

            .link-title {
                display: inline-block;
                font-size: 18px;
                font-weight: 600;
                color: hsl(217, 91%, 60%);
                text-decoration: none;
                margin-bottom: 8px;
                transition: all 0.2s ease;
                position: relative;
            }

            .link-title::after {
                content: '';
                position: absolute;
                width: 0;
                height: 2px;
                bottom: -2px;
                left: 0;
                background-color: hsl(217, 91%, 60%);
                transition: width 0.3s ease;
            }

            .link-title:hover::after {
                width: 100%;
            }

            .link-url {
                display: block;
                font-size: 14px;
                color: hsl(215, 19%, 35%);
                margin-bottom: 8px;
                word-break: break-all;
            }

            .link-url a {
                color: hsl(215, 19%, 35%);
                text-decoration: none;
                transition: color 0.2s ease;
            }

            .link-url a:hover {
                color: hsl(217, 91%, 60%);
            }

            .link-description {
                font-size: 16px;
                color: hsl(220, 9%, 46%);
                line-height: 1.5;
            }
        </style>
    </head>
    <body class="min-h-screen">
    <!-- 主内容区 -->
    <main class="container py-8">
        <!-- 链接列表 -->
        <div class="card">
            <ul class="link-list">
                {% for item in items %}
                <li class="link-item">
                    <h3 class="link-title">
                        <a href="{% item.url %}" target="_blank">{% item.title %}</a>
                    </h3>
                    <p class="link-description">{% item.description %}</p>
                </li>
                {% /for %}
            </ul>
        </div>
    </main>
    </body>
    </html>
    '''
}

@tool[
    description: "Informational displays, including text and hyperlinks that can be redirected",
    terminal: true
]
public func textURLListUI(items: Array<TextURLItem>): String {
    template_text_url_list(items)
}

@jsonable
public class LineItemData {
    @field["legend"]
    let name: String
    @field["Data Information Array"]
    let data: Array<Int64>
}

@jsonable
public class LineChatData {
    @field["The title of the chart"]
    let title: String
    @field["Label of the horizontal axis (x-axis)"]
    let xLabel: String
    @field["Label of the vertical axis (y-axis)"]
    let yLabel: String
    @field["A specific value or classification on an x-axis"]
    let xAxisLabel: Array<String>
    @field["One or more sets of data information"]
    let dataArr: Array<LineItemData>
}

@template
func template_line_chart(data: LineChatData) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>交互式折线图</title>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.8/dist/chart.umd.min.js"></script>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                padding: 20px;
                max-width: 800px;
                margin: 0 auto;
            }
            .chart-container {
                position: relative;
                margin-top: 20px;
                height: 400px;
            }
            h3 {
                text-align: center;
                color: hsl(0, 0%, 20%);
            }
            .controls {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
                margin-bottom: 20px;
            }
            button {
                padding: 8px 16px;
                background-color: hsl(217, 89%, 61%);
                color: white;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                transition: background-color 0.2s;
            }
            button:hover {
                background-color: hsl(221, 67%, 52%);
            }
        </style>
    </head>
    <body>
    <h3>{% data.title %}</h3>
    <div class="controls">
        <button id="toggleSmooth">切换平滑曲线</button>
        <button id="togglePoints">显示/隐藏数据点</button>
    </div>

    <div class="chart-container">
        <canvas id="lineChart"></canvas>
    </div>

    <script>
        // 基础数据
        const months = '{% data.xAxisLabel %}'.slice(1, -1).split(",").map(item => `'\${item.trim()}'`);

        // 初始化图表
        let lineChart;
        let isSmooth = true;
        let showPoints = true;

        function initChart() {
            const ctx = document.getElementById('lineChart').getContext('2d');

            const dataList = [];
            {% for item in data.dataArr %}
                dataList.push({
                    label: '{% item.name %}',
                    data: {% item.data %},
                    tension: isSmooth ? 0.4 : 0,
                    pointRadius: showPoints ? 4 : 0,
                });
            {% /for %}

            // 创建图表
            lineChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: months,
                    datasets: dataList
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        tooltip: {
                            mode: 'index',
                            intersect: false,
                            callbacks: {
                                label: function(context) {
                                    let label = context.dataset.label || '';
                                    if (label) {
                                        label += ': ';
                                    }
                                    label += context.parsed.y;
                                    return label;
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: '{% data.yLabel %}'
                            }
                        },
                        x: {
                            title: {
                                display: true,
                                text: '{% data.xLabel %}'
                            }
                        }
                    },
                    interaction: {
                        mode: 'nearest',
                        axis: 'x',
                        intersect: false
                    },
                    animations: {
                        tension: {
                            duration: 1000,
                            easing: 'linear'
                        }
                    }
                }
            });
        }

        // 初始化图表
        initChart();

        document.getElementById('toggleSmooth').addEventListener('click', function() {
            isSmooth = !isSmooth;
            lineChart.data.datasets.forEach(dataset => {
                dataset.tension = isSmooth ? 0.4 : 0;
            });
            lineChart.update();
        });

        document.getElementById('togglePoints').addEventListener('click', function() {
            showPoints = !showPoints;
            lineChart.data.datasets.forEach(dataset => {
                dataset.pointRadius = showPoints ? 4 : 0;
            });
            lineChart.update();
        });
    </script>
    </body>
    </html>
    '''
}

@tool[
    description: "It is used to display the trend of data changes",
    terminal: true
]
public func lineChatUI(data: LineChatData): String {
    template_line_chart(data)
}

@jsonable
public class PieChatData {
    @field["The title of the chart"]
    let title: String
    @field["Compare the categories of items"]
    let categories: Array<String>
    @field["The length of the array is the same as that of categories, and the content in desc[i] is used to describe categories[i]"]
    let desc: Array<String>
    @field["The length of the array is the same as that of categories, and the data in PCT[i] corresponds to the proportion of categories[i] in the whole, the sum of all item data in PCT is 100"]
    let PCT: Array<Int64>
}

@template
func template_pie_chart(data: PieChatData) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>自适应交互式饼图</title>
        <link href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.8/dist/chart.umd.min.js"></script>
        <style>
            body {
                font-family: 'Inter', system-ui, sans-serif;
                background-color: hsl(210, 17%, 98%);
                margin: 0;
                padding: 0;
                color: hsl(215, 28%, 17%);
            }

            .container {
                max-width: 100%;
                margin: 0 auto;
                padding: clamp(1rem, 3vw, 2rem);
            }

            .card {
                background-color: white;
                border-radius: clamp(0.75rem, 2vw, 1.25rem);
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                overflow: hidden;
            }

            .card-body {
                padding: clamp(1rem, 3vw, 1.5rem);
            }

            .chart-container {
                position: relative;
                width: 100%;
                /* 动态计算高度，保持图表比例 */
                height: clamp(300px, 50vh, 500px);
            }

            .card-footer {
                padding: clamp(1rem, 3vw, 1.5rem);
                background-color: hsl(210, 17%, 98%);
                border-top: 1px solid hsl(210, 14%, 93%);
            }

            .stats-grid {
                display: grid;
                grid-template-columns: 1fr;
                gap: clamp(0.75rem, 2vw, 1.25rem);
            }

            @media (min-width: 640px) {
                .stats-grid {
                    grid-template-columns: repeat(2, 1fr);
                }
            }

            @media (min-width: 1024px) {
                .stats-grid {
                    grid-template-columns: repeat(3, 1fr);
                }
            }

            .stat-card {
                background-color: white;
                padding: clamp(0.75rem, 2vw, 1rem);
                border-radius: clamp(0.375rem, 1vw, 0.5rem);
                box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
                border: 1px solid hsl(216, 16%, 95%);
                transition: box-shadow 0.3s ease;
            }

            .stat-card:hover {
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            }

            .stat-header {
                display: flex;
                align-items: center;
            }

            .stat-dot {
                width: clamp(0.5rem, 1.5vw, 0.75rem);
                height: clamp(0.5rem, 1.5vw, 0.75rem);
                border-radius: 50%;
                margin-right: clamp(0.25rem, 1vw, 0.5rem);
            }

            .stat-title {
                font-weight: 500;
                font-size: clamp(0.875rem, 2vw, 1rem);
            }

            .stat-description {
                font-size: clamp(0.75rem, 1.5vw, 0.875rem);
                color: hsl(220, 14%, 41%);
                margin-top: 0.25rem;
            }
        </style>
    </head>
    <body>
    <div class="container">
        <div class="card">
            <div class="card-body">
                <div class="chart-container">
                    <canvas id="salesChart"></canvas>
                </div>
            </div>
            <div class="card-footer">
                <div class="stats-grid">
                    {% for i in 0..data.categories.size %}
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-dot" style="background-color: hsl(217, 91%, 60%);"></div>
                            <span class="stat-title">{% data.categories[i] %}</span>
                        </div>
                        <p class="stat-description">{% data.desc[i] %}</p>
                    </div>
                    {% /for %}
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const ctx = document.getElementById('salesChart').getContext('2d');
            const kind = '{% data.categories %}'.slice(1, -1).split(",").map(item => `'\${item.trim()}'`);

            const data = {
                labels: kind,
                datasets: [{
                    data: {% data.PCT %},
                    borderWidth: 2,
                    hoverOffset: 20,
                    borderRadius: 6,
                }]
            };

            // 响应式配置
            const isSmallScreen = window.innerWidth < 640;

            const config = {
                type: 'pie',
                data: data,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: isSmallScreen ? 'bottom' : 'right',
                            labels: {
                                padding: isSmallScreen ? 10 : 20,
                                font: {
                                    size: isSmallScreen ? 12 : 14,
                                    family: 'Inter'
                                },
                                usePointStyle: true,
                                pointStyle: 'circle'
                            }
                        },
                        tooltip: {
                            backgroundColor: 'hsla(222, 47%, 11%, 0.9)',
                            titleFont: {
                                size: isSmallScreen ? 14 : 16,
                                family: 'Inter',
                                weight: 'bold'
                            },
                            bodyFont: {
                                size: isSmallScreen ? 12 : 14,
                                family: 'Inter'
                            },
                            padding: 12,
                            cornerRadius: 8,
                            displayColors: true,
                            callbacks: {
                                label: function(context) {
                                    const label = context.label || '';
                                    const value = context.raw || 0;
                                    const total = context.dataset.data.reduce((acc, val) => acc + val, 0);
                                    const percentage = Math.round((value / total) * 100);
                                    return `\${label}: \${percentage}%`;
                                }
                            }
                        },
                        title: {
                            display: true,
                            text: '{% data.title %}',
                            font: {
                                size: isSmallScreen ? 16 : 18,
                                family: 'Inter',
                                weight: 'bold'
                            },
                            padding: {
                                top: 10,
                                bottom: 20
                            }
                        }
                    },
                    animation: {
                        animateRotate: true,
                        animateScale: true,
                        duration: 2000,
                        easing: 'easeOutQuart'
                    },
                    cutout: isSmallScreen ? '30%' : '20%',
                    elements: {
                        arc: {
                            borderWidth: 1
                        }
                    }
                }
            };

            const myChart = new Chart(ctx, config);

            // 窗口大小变化时重新渲染图表
            window.addEventListener('resize', function() {
                myChart.destroy();
                const newIsSmallScreen = window.innerWidth < 640;

                // 更新配置
                config.options.plugins.legend.position = newIsSmallScreen ? 'bottom' : 'right';
                config.options.plugins.legend.labels.padding = newIsSmallScreen ? 10 : 20;
                config.options.plugins.legend.labels.font.size = newIsSmallScreen ? 12 : 14;
                config.options.plugins.title.font.size = newIsSmallScreen ? 16 : 18;
                config.options.cutout = newIsSmallScreen ? '30%' : '20%';

                // 重新创建图表
                myChart = new Chart(ctx, config);
            });
        });
    </script>
    </body>
    </html>
    '''
}

@tool[
    description: "Displays the proportional relationship of each piece of data, which is suitable for categorical data",
    terminal: true
]
public func pieChatUI(data: PieChatData): String {
    template_pie_chart(data)
}

@jsonable
public class TicketInfo {
    @field["Train number or flight number"]
    let tripID: String
    @field["The name of the departure station"]
    let startStation: String
    @field["Departure time, the year is not required, such as '6月1日 周日 8:00'"]
    let startTime: String
    @field["Destination Station"]
    let endStation: String
    @field["Arrival time, the year is not required, such as '6月1日 周日 11:00'"]
    let endTime: String
    @field["Travel Time, such as '3小时20分'"]
    let duration: String
    @field["Ticket Price, sucn as '二等座 ￥100.00'"]
    let price: String
    @field["Departure date, such as '2025-06-01'"]
    let data: String
    @field["Seat information, such as '12车05A号'"]
    let seatInfo: String
//    @field["The name of the passenger"]
//    let name: String
//    @field["QR code URL"]
//    let qrCode: String
}

@template
func template_ticket(info: TicketInfo) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>电子车票</title>
        <style>
            body {
                font-family: 'Arial', sans-serif;
                background-color: hsl(210, 36%, 96%);
                margin: 0;
                padding: 20px;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
            }

            .ticket {
                width: 400px;
                background-color: white;
                border-radius: 12px;
                box-shadow: 0 10px 25px hsla(210, 22%, 49%, 0.2);
                overflow: hidden;
                position: relative;
            }

            .ticket-header {
                background-color: hsl(205, 78%, 60%);
                color: white;
                padding: 20px;
                text-align: center;
                position: relative;
            }

            .ticket-header::after {
                content: '';
                position: absolute;
                bottom: -10px;
                left: 0;
                width: 100%;
                height: 20px;
                background-color: white;
                border-radius: 50% 50% 0 0 / 100% 100% 0 0;
            }

            .ticket-body {
                padding: 30px 20px 20px;
            }

            .journey-info {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 25px;
            }

            .station {
                font-size: 24px;
                font-weight: bold;
                color: hsl(209, 61%, 16%);
            }

            .time {
                font-size: 14px;
                color: hsl(210, 22%, 49%);
            }

            .duration {
                text-align: center;
                color: hsl(205, 78%, 60%);
                font-size: 14px;
                width: 100px;
            }

            .line {
                height: 1px;
                background-color: hsla(210, 22%, 49%, 0.2);
                margin: 5px 0;
            }

            .details {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 15px;
                margin-top: 20px;
            }

            .detail-item {
                padding: 10px;
                border-radius: 6px;
                background-color: hsl(210, 36%, 96%);
            }

            .detail-label {
                font-size: 12px;
                color: hsl(210, 22%, 49%);
                margin-bottom: 3px;
            }

            .detail-value {
                font-size: 16px;
                font-weight: 500;
                color: hsl(209, 61%, 16%);
            }

            .qr-code {
                text-align: center;
                margin-top: 20px;
                padding: 15px;
                background-color: hsl(210, 36%, 96%);
                border-radius: 6px;
            }

            .qr-code img {
                max-width: 100%;
                height: auto;
                border-radius: 6px;
            }

            .dashed-line {
                height: 1px;
                border-top: 2px dashed hsla(210, 22%, 49%, 0.3);
                margin: 20px 0;
            }

            .ticket-footer {
                text-align: center;
                padding: 10px;
                font-size: 12px;
                color: hsl(210, 22%, 49%);
            }
        </style>
    </head>
    <body>
    <div class="ticket">
        <div class="ticket-header">
            <h2>电子车票</h2>
            <p>{% info.tripID %}</p>
        </div>
        <div class="ticket-body">
            <div class="journey-info">
                <div>
                    <div class="station">{% info.startStation %}</div>
                    <div class="time">{% info.startTime %}</div>
                </div>
                <div class="duration">
                    <i class="fa fa-train" aria-hidden="true"></i> 3小时20分
                </div>
                <div>
                    <div class="station">{% info.endStation %}</div>
                    <div class="time">{% info.endTime %}</div>
                </div>
            </div>

            <div class="line"></div>

            <div class="details">
                <div class="detail-item">
                    <div class="detail-label">日期</div>
                    <div class="detail-value">{% info.data %}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">座位</div>
                    <div class="detail-value">{% info.seatInfo %}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">票价</div>
                    <div class="detail-value">{% info.price %}</div>
                </div>
    <!--            <div class="detail-item">-->
    <!--                <div class="detail-label">乘客</div>-->
    <!--                <div class="detail-value"></div>-->
    <!--            </div>-->
            </div>

    <!--        <div class="qr-code">-->
    <!--            <img src="" alt="车票二维码" />-->
    <!--        </div>-->

            <div class="ticket-footer">
                <p>请提前30分钟检票进站 | 禁止携带易燃易爆物品</p>
            </div>
        </div>
    </div>
    </body>
    </html>
    '''
}

@tool[
    description: "Displaying infomation about a single ticket",
    terminal: true
]
public func ticketUI(info: TicketInfo): String {
    template_ticket(info)
}

@template
func template_ticket_list(arr: Array<TicketInfo>) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>车票列表</title>
        <link href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css" rel="stylesheet">
        <style>
            body {
                font-family: 'Arial', sans-serif;
                background-color: hsl(210, 36%, 96%);
                margin: 0;
                padding: 20px;
                color: hsl(209, 61%, 16%);
            }

            .container {
                max-width: 800px;
                margin: 0 auto;
            }

            h1 {
                text-align: center;
                color: hsl(205, 78%, 60%);
                margin-bottom: 30px;
            }

            .ticket-list {
                display: grid;
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .ticket {
                background-color: white;
                border-radius: 10px;
                box-shadow: 0 4px 15px hsla(210, 22%, 49%, 0.1);
                overflow: hidden;
                transition: transform 0.2s ease;
            }

            .ticket:hover {
                transform: translateY(-3px);
            }

            .ticket-header {
                background-color: hsl(205, 78%, 60%);
                color: white;
                padding: 15px 20px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .train-number {
                font-size: 18px;
                font-weight: bold;
            }

            .ticket-type {
                background-color: hsla(0, 0%, 100%, 0.2);
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 14px;
            }

            .ticket-body {
                padding: 20px;
            }

            .journey-info {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 15px;
            }

            .station {
                font-size: 22px;
                font-weight: bold;
            }

            .time {
                font-size: 14px;
                color: hsl(210, 22%, 49%);
            }

            .duration {
                text-align: center;
                color: hsl(205, 78%, 60%);
                font-size: 14px;
                width: 100px;
            }

            .details {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
                gap: 10px;
                margin-top: 15px;
                font-size: 14px;
            }

            .detail-item {
                display: flex;
                flex-direction: column;
            }

            .detail-label {
                color: hsl(210, 22%, 49%);
                font-size: 12px;
            }

            .dashed-line {
                height: 1px;
                border-top: 2px dashed hsla(210, 22%, 49%, 0.2);
                margin: 15px 0;
            }

            .actions {
                display: flex;
                justify-content: flex-end;
                padding: 15px 20px;
                background-color: hsl(210, 36%, 98%);
            }

            .btn {
                padding: 8px 15px;
                border-radius: 4px;
                cursor: pointer;
                font-size: 14px;
                transition: background-color 0.2s ease;
                margin-left: 10px;
            }

            .btn-view {
                background-color: hsl(205, 78%, 60%);
                color: white;
                border: none;
            }

            .btn-view:hover {
                background-color: hsl(205, 68%, 50%);
            }

            .btn-cancel {
                background-color: hsl(0, 0%, 90%);
                color: hsl(209, 61%, 16%);
                border: none;
            }

            .btn-cancel:hover {
                background-color: hsl(0, 0%, 80%);
            }

            @media (max-width: 500px) {
                .ticket-header {
                    flex-direction: column;
                    align-items: flex-start;
                }

                .ticket-type {
                    margin-top: 5px;
                }

                .journey-info {
                    flex-direction: column;
                    text-align: center;
                }

                .duration {
                    margin: 15px 0;
                }

                .details {
                    grid-template-columns: 1fr 1fr;
                }
            }
        </style>
    </head>
    <body>
    <div class="container">
        <h1>我的车票</h1>

        <div class="ticket-list">
        {% for item in arr %}
            <div class="ticket">
                <div class="ticket-header">
                    <div class="train-number">{% item.tripID %}</div>
                    <div class="ticket-type">电子票</div>
                </div>
                <div class="ticket-body">
                    <div class="journey-info">
                        <div>
                            <div class="station">{% item.startStation %}</div>
                            <div class="time">{% item.startTime %}</div>
                        </div>
                        <div class="duration">
                            <i class="fa fa-train" aria-hidden="true"></i> {% item.duration %}
                        </div>
                        <div>
                            <div class="station">{% item.endStation %}</div>
                            <div class="time">{% item.endTime %}</div>
                        </div>
                    </div>

                    <div class="dashed-line"></div>

                    <div class="details">
                        <div class="detail-item">
                            <div class="detail-label">日期</div>
                            <div>{% item.data %}</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">座位</div>
                            <div>{% item.seatInfo %}</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">票价</div>
                            <div>{% item.price %}</div>
                        </div>
    <!--                    <div class="detail-item">-->
    <!--                        <div class="detail-label">乘客</div>-->
    <!--                        <div></div>-->
    <!--                    </div>-->
                    </div>
                </div>
                <div class="actions">
                    <button class="btn btn-cancel">退票</button>
                    <button class="btn btn-view">查看详情</button>
                </div>
            </div>
        {% /for %}
        </div>
    </div>
    </body>
    </html>
    '''
}

@tool[
    description: "Displaying information about multiple purchased tickets",
    terminal: true
]
public func ticketListUI(arr: Array<TicketInfo>): String {
    template_ticket_list(arr)
}

@jsonable
public class MeetingInfo {
    @field["Conference subject"]
    let subject: String
    @field["Meeting time, displayed in the format '2025-06-10 09:30-10:30'"]
    let time: String
    @field["Meeting location"]
    let location: String
    @field["Convener of the meeting"]
    let convener: String
    @field["Attendees"]
    let attendees: String
    @field["Description of the meeting"]
    let description: String
    @field["Meeting link"]
    let url: String
}

@template
func template_meeting(info: MeetingInfo) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>会议通知</title>
        <script src="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/js/font-awesome.min.js"></script>
        <style>
            :root {
                --primary: hsl(220, 100%, 54%);
                --secondary: hsl(179, 85%, 42%);
                --success: hsl(134, 100%, 35%);
                --warning: hsl(30, 100%, 50%);
                --danger: hsl(0, 91%, 60%);
                --info: hsl(216, 12%, 54%);
                --light: hsl(210, 17%, 95%);
                --dark: hsl(216, 12%, 14%);
                --white: hsl(0, 0%, 100%);
                --gray-100: hsl(210, 17%, 98%);
                --gray-200: hsl(210, 16%, 93%);
                --gray-300: hsl(210, 14%, 89%);
                --gray-400: hsl(210, 14%, 83%);
                --gray-500: hsl(210, 11%, 71%);
                --gray-600: hsl(210, 9%, 31%);
                --gray-700: hsl(210, 10%, 23%);
                --gray-800: hsl(210, 12%, 16%);
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: 'Inter', system-ui, sans-serif;
                background-color: var(--light);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 0 1rem;
            }

            main {
                flex-grow: 1;
                padding: 1.5rem 0;
            }

            .meeting-card {
                background-color: var(--white);
                border-radius: 0.75rem;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                overflow: hidden;
                margin-bottom: 2rem;
                animation: fadeIn 0.5s ease-in-out;
            }

            @keyframes fadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }

            .card-header {
                position: relative;
            }

            .card-header::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 0.25rem;
                background: linear-gradient(90deg, var(--primary), var(--secondary));
            }

            .card-content {
                padding: 1.5rem;
            }

            @media (min-width: 768px) {
                .card-content {
                    padding: 2rem;
                }
            }

            .meeting-header {
                display: flex;
                flex-direction: column;
                margin-bottom: 1.5rem;
            }

            @media (min-width: 768px) {
                .meeting-header {
                    flex-direction: row;
                    align-items: center;
                    justify-content: space-between;
                }
            }

            .meeting-title {
                font-size: clamp(1.25rem, 3vw, 2rem);
                font-weight: bold;
                color: var(--dark);
                margin-bottom: 0.75rem;
                text-shadow: 0 1px 2px rgba(0,0,0,0.1);
            }

            .meeting-info {
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 1rem;
                color: var(--gray-600);
                font-size: 0.875rem;
            }

            .meeting-info-item {
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            .meeting-info i {
                color: var(--primary);
            }

            .meeting-details {
                display: grid;
                grid-template-columns: 1fr;
                gap: 1.5rem;
                margin-bottom: 2rem;
            }

            .detail-group {
                background-color: var(--gray-100);
                border-radius: 0.5rem;
                padding: 1rem;
            }

            .detail-title {
                font-size: 1rem;
                font-weight: 600;
                color: var(--dark);
                margin-bottom: 0.75rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            .detail-title i {
                color: var(--primary);
            }

            .detail-list {
                list-style: none;
            }

            .detail-item {
                margin-bottom: 0.75rem;
                display: flex;
                flex-direction: column;
            }

            .detail-label {
                font-size: 0.875rem;
                color: var(--gray-500);
                margin-bottom: 0.25rem;
            }

            .detail-value {
                font-size: 0.9375rem;
                color: var(--gray-800);
            }

            .meeting-description {
                margin-bottom: 2rem;
            }

            .description-title {
                font-size: 1.25rem;
                font-weight: 600;
                color: var(--dark);
                margin-bottom: 1rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            .description-title i {
                color: var(--primary);
            }

            .description-content {
                line-height: 1.6;
                color: var(--gray-700);
                text-align: justify;
            }

            .action-buttons {
                display: flex;
                flex-wrap: wrap;
                gap: 1rem;
            }

            .btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 0.5rem;
                padding: 0.5rem 1.25rem;
                border-radius: 0.375rem;
                font-size: 0.9375rem;
                font-weight: 500;
                transition: all 0.2s;
                cursor: pointer;
                border: 1px solid transparent;
            }

            .btn-primary {
                background-color: var(--primary);
                color: var(--white);
            }

            .btn-primary:hover {
                background-color: hsl(220, 100%, 47%);
            }

            .btn-outline {
                background-color: transparent;
                border-color: var(--primary);
                color: var(--primary);
            }

            .btn-outline:hover {
                background-color: hsl(220, 100%, 97%);
            }

            .btn-danger {
                background-color: var(--danger);
                color: var(--white);
            }

            .btn-danger:hover {
                background-color: hsl(0, 91%, 53%);
            }
        </style>
    </head>
    <body>
    <!-- 主要内容 -->
    <main class="container">
        <!-- 会议通知卡片 -->
        <div class="meeting-card">
            <div class="card-header">
                <div class="card-content">
                    <div class="meeting-header">
                        <div>
                            <h2 class="meeting-title">{% info.subject %}</h2>
                            <div class="meeting-info">
                                <div class="meeting-info-item">
                                    <i class="fa fa-user-o"></i>
                                    <span>发起人：{% info.convener %}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="meeting-details">
                        <div class="detail-group">
                            <h3 class="detail-title">
                                <i class="fa fa-calendar-check-o"></i>
                                会议基本信息
                            </h3>
                            <ul class="detail-list">
                                <li class="detail-item">
                                    <span class="detail-label">会议主题</span>
                                    <span class="detail-value">{% info.subject %}</span>
                                </li>
                                <li class="detail-item">
                                    <span class="detail-label">会议时间</span>
                                    <span class="detail-value">{% info.time %}</span>
                                </li>
                                <li class="detail-item">
                                    <span class="detail-label">会议链接</span>
                                    <span class="detail-value"><a href="{% info.url %}">{% info.url %}</a></span>
                                </li>
                                <li class="detail-item">
                                    <span class="detail-label">会议地点</span>
                                    <span class="detail-value">{% info.location %}</span>
                                </li>
                                <li class="detail-item">
                                    <span class="detail-label">召集人</span>
                                    <span class="detail-value">{% info.convener %}</span>
                                </li>
                                <li class="detail-item">
                                    <span class="detail-label">参会人员</span>
                                    <span class="detail-value">{% info.attendees %}</span>
                                </li>
                            </ul>
                        </div>
                    </div>

                    <div class="meeting-description">
                        <h3 class="description-title">
                            <i class="fa fa-file-text-o"></i>
                            会议描述
                        </h3>
                        <div class="description-content">
                            {% info.description %}
                        </div>
                    </div>

                    <div class="action-buttons">
                        <button class="btn btn-primary">
                            <i class="fa fa-check-circle"></i>
                            确认参加
                        </button>
                        <button class="btn btn-outline">
                            <i class="fa fa-pencil"></i>
                            修改回复
                        </button>
                        <button class="btn btn-outline">
                            <i class="fa fa-bell"></i>
                            设置提醒
                        </button>
                        <button class="btn btn-danger">
                            <i class="fa fa-times-circle"></i>
                            无法参加
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </main>
    </body>
    </html>
    '''
}

@tool[
    description: "Display meeting information that users need to attend",
    terminal: true
]
public func meetingUI(info: MeetingInfo): String {
    template_meeting(info)
}

@jsonable
public class CompareInfo {
    @field["Subject Information"]
    let title: String
    @field["A list of the names of the items compared"]
    let name: Array<String>
    @field["A list of types to compare"]
    let category: Array<String>
    @field["""
        Parameter values for each item in each category. First dimension: the length of the corresponding name list (number of items);
        Second dimension: the length of the corresponding category list (number of categories). If the size of name is [2], the size of category is [3], and the size of param is [2, 3].
        such as 'name=['apple','banana'], category=['price','sweetness', 'hardness'], then param=[['high','moderate', 'hard'],['low','sweet', 'soft']]"""]
    let param: Array<Array<String>>
}

@template
func template_compare(info: CompareInfo) {
    '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>商品对比页面</title>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.8/dist/chart.umd.min.js"></script>
        <style>
            /* 基础样式 */
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Inter', system-ui, sans-serif;
            }

            body {
                max-width: 1200px;
                margin: 0 auto;
                padding: 20px;
                line-height: 1.6;
                color: hsl(210, 11%, 15%);
                background-color: hsl(0, 0%, 98%);
            }

            /* 标题区域 */
            .header {
                text-align: center;
                margin: 40px 0;
            }

            .header h1 {
                font-size: clamp(1.5rem, 3vw, 2.5rem);
                color: hsl(210, 10%, 23%);
                margin-bottom: 10px;
                font-weight: 700;
            }

            .header p {
                color: hsl(210, 9%, 31%);
                max-width: 800px;
                margin: 0 auto;
            }

            /* 对比表格 */
            .compare-table {
                width: 100%;
                border-collapse: collapse;
                background: hsl(0, 0%, 100%);
                border-radius: 8px;
                box-shadow: 0 1px 3px hsla(0, 0%, 0%, 0.1);
                overflow: hidden;
            }

            .compare-table th,
            .compare-table td {
                padding: 15px 20px;
                text-align: left;
                border-bottom: 1px solid hsl(210, 14%, 89%);
            }

            .compare-table th {
                background: hsl(210, 16%, 93%);
                font-weight: 600;
                width: 20%;
            }

            .product-name {
                text-align: center;
                background: hsl(210, 16%, 93%);
                font-weight: 700;
                color: hsl(210, 10%, 23%);
            }

            .price {
                color: hsl(145, 63%, 42%);
                font-weight: 700;
            }

            .highlight {
                background: hsl(45, 100%, 96%);
            }

            /* 图表区域 */
            .chart-section {
                margin-top: 40px;
                background: hsl(0, 0%, 100%);
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 1px 3px hsla(0, 0%, 0%, 0.1);
            }

            .chart-section h2 {
                margin-bottom: 20px;
                color: hsl(210, 10%, 23%);
                font-size: 1.25rem;
                font-weight: 600;
            }

            /* 响应式调整 */
            @media (max-width: 768px) {
                .filter-group {
                    flex-direction: column;
                }

                .compare-table th {
                    font-size: 0.9em;
                    padding: 10px;
                }

                .compare-table td {
                    font-size: 0.9em;
                    padding: 10px;
                }
            }
        </style>
    </head>
    <body>
    <header class="header">
        <h1>{% info.title %}</h1>
    </header>

    <table class="compare-table">
        <thead>
        <tr>
            <th>参数</th>
            {% for n in info.name %}
                <th class="product-name">{% n %}</th>
            {% /for %}
        </tr>
        </thead>
        <tbody>
            {% for j in 0..info.category.size %}
                <tr>
                    <th>{% info.category[j] %}</th>
                    {% for i in 0..info.name.size %}
                        <td>{% info.param[i][j] %}</td>
                    {% /for %}
                </tr>
            {% /for %}
        </tbody>
    </table>
    </body>
    </html>
    '''
}

@tool[
    description: "Display comparative information of two or more items",
    terminal: true
]
public func CompareUI(info: CompareInfo): String {
    template_compare(info)
}

@tool[
    description: "Call this if you don't have a suitable UI, which directly returns the input information",
    terminal: true
]
public func generalUI(data: String): String {
    return data
}