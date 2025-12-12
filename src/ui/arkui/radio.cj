package magic.ui.arkui

import magic.dsl.*
import magic.jsonable.*
import std.collection.*

@template[
    dump: true,
]
public func template_radio_list(info: TextInfo) {
    '''
        namespace NativeModule {
            class ArkUIRadioNode : public ArkUINode {
            public:
                ArkUIRadioNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_RADIO)) {}
                /**
                * @brief 设置单选框的选中状态
                * @param checked true表示选中，false表示未选中
                */
                void SetChecked(bool checked) {
                    assert(handle_);
                    ArkUI_NumberValue value;
                    value.i32 = checked ? 1 : 0;  // 1表示选中，0表示未选中
                    ArkUI_AttributeItem item = {&value, 1};
                    nativeModule_->setAttribute(handle_, NODE_RADIO_CHECKED, &item);
                }

                /**
                * @brief 设置单选框的值
                * @param value 单选框的值字符串
                */
                void SetValue(const std::string &value) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {nullptr, 0, value.c_str()};
                    nativeModule_->setAttribute(handle_, NODE_RADIO_VALUE, &item);
                }

                /**
                * @brief 设置单选框的组名
                * @param groupName 组名，同一组内只能有一个单选框被选中
                */
                void SetGroupName(const std::string &groupName) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {nullptr, 0, groupName.c_str()};
                    nativeModule_->setAttribute(handle_, NODE_RADIO_GROUP, &item);
                }

                /**
                * @brief 设置单选框的样式（颜色）
                * @param enabledColor 启用状态下的主板颜色（0xARGB格式）
                * @param disabledColor 关闭状态下的边框颜色（0xARGB格式）
                * @param innerColor 启用状态下的内部圆饼颜色（0xARGB格式）
                */
                void SetStyle(uint32_t enabledColor, uint32_t disabledColor, uint32_t innerColor) {
                    assert(handle_);
                    ArkUI_NumberValue values[3];
                    values[0].u32 = enabledColor;   // 启用状态下的主板颜色
                    values[1].u32 = disabledColor;  // 关闭状态下的边框颜色
                    values[2].u32 = innerColor;     // 启用状态下的内部圆饼颜色

                    ArkUI_AttributeItem item = {values, 3};
                    nativeModule_->setAttribute(handle_, NODE_RADIO_STYLE, &item);
                }

                /**
                * @brief 设置单选框的样式为默认值
                */
                void ResetStyle() {
                    assert(handle_);
                    // 默认值：
                    // enabledColor: 0xFF007DFF (蓝色)
                    // disabledColor: 0xFF182431 (深灰色)
                    // innerColor: 0xFFFFFFFF (白色)
                    SetStyle(0xFF007DFF, 0xFF182431, 0xFFFFFFFF);
                }
            };
        }  // namespace NativeModule

        // 外部C接口，供外部调用
        extern "C" {
            using namespace NativeModule;

            std::shared_ptr<ArkUIBaseNode> CreateRadioListExample() {
                auto column = std::make_shared<ArkUIColumnNode>();
                column->SetBorderWidth(1);
                column->SetPercentWidth(1);
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
                // 2：创建Radio子组件并挂载到Row上。
                {% for item in info.data %}
                {
                    auto row = std::make_shared<ArkUIRowNode>();
                    auto radioItem = std::make_shared<ArkUIRadioNode>();
                    auto textInfo = std::make_shared<ArkUITextNode>();
                    radioItem->SetGroupName(\"{% item.content %}\");
                    radioItem->SetValue(\"{% item.content %}\");
                    textInfo->SetTextContent(\"{% item.content %}\");
                    textInfo->SetFontSize(18);
                    row->AddChild(radioItem);
                    row->AddChild(textInfo);
                    row->SetMargin(0, 0, 10, 0);
                    row->SetBorderColor(0xFFefefef);
                    row->SetBorderWidth(1);
                    row->SetPercentWidth(0.9);
                    row->SetCornerRadius(15);
                    row->SetPadding(15, 10, 15, 10);
                    column->AddChild(row);
                }
                {% /for %}
                return column;
            }
        }  // extern "C"
    '''
}