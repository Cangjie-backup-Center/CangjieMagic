package magic.ui.arkui

import magic.dsl.*
import magic.jsonable.*
import std.collection.*

@template[]
public func template_textinput() {
    '''
        namespace NativeModule {
            class ArkUITextInputNode : public ArkUINode {
            public:
                // 构造函数：创建单行文本框节点，复用父类初始化逻辑
                ArkUITextInputNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_TEXT_INPUT)) {}

                // ===================== 基础字符串属性 =====================
                /**
                * @brief 设置占位符文本
                * @param placeholder 占位符字符串（如"请输入手机号..."）
                */
                void SetPlaceholder(const char* placeholder) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {};
                    item.string = const_cast<char*>(placeholder);
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_PLACEHOLDER, &item);
                }

                /**
                * @brief 设置文本框默认内容
                * @param text 文本内容字符串
                */
                void SetText(const char* text) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {};
                    item.string = const_cast<char*>(text);
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_TEXT, &item);
                }

                /**
                * @brief 设置密码生成规则（自动填充时传给密码库）
                * @param rules 密码生成规则字符串
                */
                void SetPasswordRules(const char* rules) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {};
                    item.string = const_cast<char*>(rules);
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_PASSWORD_RULES, &item);
                }

                /**
                * @brief 设置输入过滤正则表达式（仅匹配单个字符）
                * @param regex 正则表达式字符串
                */
                void SetInputFilter(const char* regex) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {};
                    item.string = const_cast<char*>(regex);
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_INPUT_FILTER, &item);
                }

                // ===================== 基础数值属性（i32/u32/f32） =====================
                /**
                * @brief 设置光标颜色（0xARGB格式）
                * @param color ARGB颜色值（如0xFF0088FF表示蓝色）
                */
                void SetCaretColor(uint32_t color) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.u32 = color}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_CARET_COLOR, &item);
                }

                /**
                * @brief 设置光标样式（宽度）
                * @param width 光标宽度（vp单位，如2.0表示2vp）
                */
                void SetCaretStyle(float width) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = width}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_CARET_STYLE, &item);
                }

                /**
                * @brief 设置是否显示下划线
                * @param show true(1)显示，false(0)隐藏
                */
                void SetShowUnderline(int32_t show) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = show}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_SHOW_UNDERLINE, &item);
                }

                /**
                * @brief 设置最大输入字符数
                * @param maxLength 最大字符数（如11表示手机号最大输入11位）
                */
                void SetMaxLength(int32_t maxLength) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = maxLength}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_MAX_LENGTH, &item);
                }

                /**
                * @brief 设置回车键类型
                * @param type 回车键类型（ArkUI_EnterKeyType枚举值）
                */
                void SetEnterKeyType(ArkUI_EnterKeyType type) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = type}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_ENTER_KEY_TYPE, &item);
                }

                /**
                * @brief 设置占位符文本颜色（0xARGB格式）
                * @param color ARGB颜色值（如0xFF999999表示灰色）
                */
                void SetPlaceholderColor(uint32_t color) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.u32 = color}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_PLACEHOLDER_COLOR, &item);
                }

                /**
                * @brief 设置获焦时是否启用输入法
                * @param enable true(1)启用，false(0)禁用
                */
                void SetEnableKeyboardOnFocus(int32_t enable) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = enable}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_ENABLE_KEYBOARD_ON_FOCUS, &item);
                }

                /**
                * @brief 设置文本框类型
                * @param type 文本框类型（ArkUI_TextInputType枚举值，如密码框、数字框等）
                */
                void SetType(ArkUI_TextInputType type) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = type}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_TYPE, &item);
                }

                /**
                * @brief 设置文本选中背景色（0xARGB格式）
                * @param color ARGB颜色值
                */
                void SetSelectedBackgroundColor(uint32_t color) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.u32 = color}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_SELECTED_BACKGROUND_COLOR, &item);
                }

                /**
                * @brief 设置密码框是否显示密码图标
                * @param show true(1)显示，false(0)隐藏
                */
                void SetShowPasswordIcon(int32_t show) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = show}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_SHOW_PASSWORD_ICON, &item);
                }

                /**
                * @brief 设置文本框是否可编辑
                * @param isEditing true(1)可编辑，false(0)不可编辑
                */
                void SetEditing(int32_t isEditing) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = isEditing}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_EDITING, &item);
                }

                /**
                * @brief 设置文本选中区域（起始/结束位置）
                * @param start 选中起始位置
                * @param end 选中结束位置
                */
                void SetTextSelection(int32_t start, int32_t end) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = start}, {.i32 = end}};
                    ArkUI_AttributeItem item = {value, 2};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_TEXT_SELECTION, &item);
                }

                /**
                * @brief 设置是否启用自动填充
                * @param enable true(1)启用，false(0)禁用
                */
                void SetEnableAutoFill(int32_t enable) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = enable}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_ENABLE_AUTO_FILL, &item);
                }

                /**
                * @brief 设置自动填充类型
                * @param type 填充类型（ArkUI_TextInputContentType枚举值）
                */
                void SetContentType(ArkUI_TextInputContentType type) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = type}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_CONTENT_TYPE, &item);
                }

                /**
                * @brief 设置初始状态是否全选文本
                * @param selectAll true(1)全选，false(0)不全选
                */
                void SetSelectAll(int32_t selectAll) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = selectAll}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_SELECT_ALL, &item);
                }

                /**
                * @brief 设置文本框样式（默认/内联输入）
                * @param style 样式类型（ArkUI_TextInputStyle枚举值）
                */
                void SetStyle(ArkUI_TextInputStyle style) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = style}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_STYLE, &item);
                }

                /**
                * @brief 设置光标位置（字符索引）
                * @param offset 从字符串开头到光标位置的字符数
                */
                void SetCaretOffset(int32_t offset) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = offset}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_CARET_OFFSET, &item);
                }

                /**
                * @brief 设置是否隐藏文本选择菜单
                * @param isHidden true(1)隐藏，false(0)显示
                */
                void SetSelectionMenuHidden(int32_t isHidden) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = isHidden}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_SELECTION_MENU_HIDDEN, &item);
                }

                /**
                * @brief 设置回车提交后是否失去焦点
                * @param blurOnSubmit true(1)失去焦点，false(0)不失去
                */
                void SetBlurOnSubmit(int32_t blurOnSubmit) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = blurOnSubmit}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_BLUR_ON_SUBMIT, &item);
                }

                /**
                * @brief 设置换行规则
                * @param wordBreak 换行规则（ArkUI_WordBreak枚举值）
                */
                void SetWordBreak(ArkUI_WordBreak wordBreak) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = wordBreak}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_WORD_BREAK, &item);
                }

                /**
                * @brief 设置获焦时是否弹出键盘
                * @param show true(1)弹出，false(0)不弹出
                */
                void SetShowKeyboardOnFocus(int32_t show) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = show}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_SHOW_KEYBOARD_ON_FOCUS, &item);
                }

                /**
                * @brief 设置文本框行数（用于计算高度）
                * @param lines 行数（如1表示单行，适配高度）
                */
                void SetNumberOfLines(int32_t lines) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = lines}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_NUMBER_OF_LINES, &item);
                }

                /**
                * @brief 设置字符间距（API 15+，单位fp）
                * @param spacing 字符间距（如0.5表示间距0.5fp）
                */
                void SetLetterSpacing(float spacing) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = spacing}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_LETTER_SPACING, &item);
                }

                /**
                * @brief 设置是否启用文本预览（API 15+）
                * @param enable true(1)启用，false(0)禁用
                */
                void SetEnablePreviewText(int32_t enable) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = enable}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_ENABLE_PREVIEW_TEXT, &item);
                }

                /**
                * @brief 设置文本是否垂直居中（API 18+）
                * @param center true(1)居中，false(0)不居中
                */
                void SetHalfLeading(int32_t center) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = center}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_HALF_LEADING, &item);
                }

                /**
                * @brief 设置键盘样式（API 15+）
                * @param style 键盘样式（ArkUI_KeyboardAppearanceType枚举值）
                */
                void SetKeyboardAppearance(ArkUI_KeyboardAppearance style) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = style}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_KEYBOARD_APPEARANCE, &item);
                }

                // ===================== 复杂多参数属性 =====================
                /**
                * @brief 设置占位符文本字体样式
                * @param fontSize 字体大小（fp，可选，-1则用默认16.0）
                * @param fontStyle 字体样式（ArkUI_FontStyle，可选，-1则用默认NORMAL）
                * @param fontWeight 字体粗细（ArkUI_FontWeight，可选，-1则用默认NORMAL）
                * @param fontFamily 字体家族（可选，如"SimHei, Microsoft YaHei"）
                */
                void SetPlaceholderFont(float fontSize = -1.0f, int32_t fontStyle = -1,
                                        int32_t fontWeight = -1, const char* fontFamily = nullptr) {
                    assert(handle_);
                    std::vector<ArkUI_NumberValue> values;

                    // 添加可选数值参数
                    if (fontSize >= 0) values.push_back({.f32 = fontSize});
                    if (fontStyle >= 0) values.push_back({.i32 = fontStyle});
                    if (fontWeight >= 0) values.push_back({.i32 = fontWeight});

                    // 构建属性项
                    ArkUI_AttributeItem item = {};
                    if (!values.empty()) {
                        item.value = values.data();
                        item.size = values.size();
                    }
                    if (fontFamily != nullptr) {
                        item.string = const_cast<char*>(fontFamily);
                    }

                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_PLACEHOLDER_FONT, &item);
                }

                /**
                * @brief 设置取消按钮样式
                * @param style 按钮样式（ArkUI_CancelButtonStyle枚举值，必选）
                * @param iconSize 按钮图标大小（vp，可选，-1则不设置）
                * @param iconColor 按钮图标颜色（0xARGB，可选，-1则不设置）
                * @param iconSrc 按钮图标图片路径（可选，如"/pages/icon.png"）
                */
                void SetCancelButton(ArkUI_CancelButtonStyle style, float iconSize = -1.0f,
                                    int32_t iconColor = -1, const char* iconSrc = nullptr) {
                    assert(handle_);
                    std::vector<ArkUI_NumberValue> values;
                    values.push_back({.i32 = style});  // 必选参数：按钮样式

                    // 添加可选参数
                    if (iconSize >= 0) values.push_back({.f32 = iconSize});
                    if (iconColor >= 0) values.push_back({.u32 = static_cast<uint32_t>(iconColor)});

                    // 构建属性项
                    ArkUI_AttributeItem item = {};
                    item.value = values.data();
                    item.size = values.size();
                    if (iconSrc != nullptr) {
                        item.string = const_cast<char*>(iconSrc);
                    }

                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_CANCEL_BUTTON, &item);
                }

                /**
                * @brief 设置下划线颜色（四种状态）
                * @param typingColor 输入时下划线颜色（0xARGB，必选）
                * @param normalColor 正常状态颜色（0xARGB，可选，-1则不设置）
                * @param errorColor 错误状态颜色（0xARGB，可选，-1则不设置）
                * @param disabledColor 禁用状态颜色（0xARGB，可选，-1则不设置）
                */
                void SetUnderlineColor(uint32_t typingColor, int32_t normalColor = -1,
                                    int32_t errorColor = -1, int32_t disabledColor = -1) {
                    assert(handle_);
                    std::vector<ArkUI_NumberValue> values;
                    values.push_back({.u32 = typingColor});  // 必选参数：输入时颜色

                    // 添加可选参数
                    if (normalColor >= 0) values.push_back({.u32 = static_cast<uint32_t>(normalColor)});
                    if (errorColor >= 0) values.push_back({.u32 = static_cast<uint32_t>(errorColor)});
                    if (disabledColor >= 0) values.push_back({.u32 = static_cast<uint32_t>(disabledColor)});

                    // 设置属性
                    ArkUI_AttributeItem item = {values.data(), static_cast<int32_t>(values.size())};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_UNDERLINE_COLOR, &item);
                }

                /**
                * @brief 设置自定义键盘
                * @param keyboardHandle 自定义键盘节点句柄（ArkUI_NodeHandle）
                * @param supportAvoidance 是否支持避让功能（可选，false为默认）
                */
                void SetCustomKeyboard(ArkUI_NodeHandle keyboardHandle, bool supportAvoidance = false) {
                    assert(handle_);
                    std::vector<ArkUI_NumberValue> values;
                    values.push_back({.i32 = supportAvoidance ? 1 : 0});  // 可选参数：避让功能

                    // 构建属性项
                    ArkUI_AttributeItem item = {};
                    item.object = keyboardHandle;
                    item.value = values.data();
                    item.size = values.size();

                    nativeModule_->setAttribute(handle_, NODE_TEXT_INPUT_CUSTOM_KEYBOARD, &item);
                }
            };
        }  // namespace NativeModule

        // 外部C接口，供外部调用
        extern "C" {
            using namespace NativeModule;

            std::shared_ptr<ArkUIBaseNode> CreateTextInputExample() {
                auto column = std::make_shared<ArkUIColumnNode>();
                column->SetBorderWidth(1);
                column->SetPercentWidth(1);
                column->SetPercentHeight(1);
                column->SetCornerRadius(20);
                column->SetBorderColor(0xFFefefef);
                column->SetShadowStyle(ARKUI_SHADOW_STYLE_OUTER_DEFAULT_MD);
                auto title = std::make_shared<ArkUITextNode>();
                title->SetTextContent("标题");
                title->SetFontSize(22);
                title->SetPercentWidth(1);
                title->SetPadding(15, 0.0, 10, 15);
                title->SetFontWeight(ARKUI_FONT_WEIGHT_W600);
                column->AddChild(title);

                auto inputNode = std::make_shared<ArkUITextInputNode>();
                inputNode->SetPlaceholder("请输入手机号");          // 占位符
                inputNode->SetMaxLength(11);                        // 最大11位字符
                inputNode->SetType(ARKUI_TEXTINPUT_TYPE_NUMBER);    // 数字输入框
                inputNode->SetShowPasswordIcon(0);                  // 不显示密码图标
                inputNode->SetCaretColor(0xFF0088FF);               // 光标蓝色
                inputNode->SetPercentWidth(0.9);
                inputNode->SetMargin(10, 10, 10, 10);

                // 设置占位符字体：大小14fp、正常样式、加粗、微软雅黑
                inputNode->SetPlaceholderFont(14.0f, ARKUI_FONT_STYLE_NORMAL, ARKUI_FONT_WEIGHT_BOLD, "Microsoft YaHei");

                // 设置下划线颜色：输入时蓝色，正常状态灰色，错误状态红色
                inputNode->SetUnderlineColor(0xFF0088FF, 0xFF999999, 0xFFFF0000);

                // 设置取消按钮：默认样式、图标大小20vp、图标颜色黑色
                inputNode->SetCancelButton(ARKUI_CANCELBUTTON_STYLE_INPUT, 20.0f, 0xFF000000);
                column->AddChild(inputNode);

                auto button = std::make_shared<ArkUIButtonNode>();
                button->SetLabel("确认");
                button->SetButtonType(ARKUI_BUTTON_TYPE_CAPSULE);
                button->SetMinFontScale(0.8f);
                button->SetMaxFontScale(1.2f);
                button->SetWidth(100.0f);
                column->AddChild(button);
                return column;
            }
        }  // extern "C"
    '''
}