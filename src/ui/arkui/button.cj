package magic.ui.arkui

import magic.dsl.*
import magic.prelude.*
import magic.jsonable.*
import std.collection.*
import stdx.encoding.json.{JsonValue, JsonObject, JsonException, JsonKind, JsonInt, JsonString, JsonBool, JsonFloat, JsonArray, JsonNull}


@template[
]
public func template_confirm_btn() {
    '''
        namespace NativeModule {
            class ArkUIButtonNode : public ArkUINode {
            public:
                ArkUIButtonNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_BUTTON)) {}
                /**
                * @brief 设置按钮文本内容
                * @param label 按钮要显示的文本字符串
                */
                void SetLabel(const char* label) {
                    assert(handle_);  // 确保节点句柄有效
                    ArkUI_AttributeItem item = {};  // 初始化属性项
                    item.string = const_cast<char*>(label);  // 设置文本内容
                    nativeModule_->setAttribute(handle_, NODE_BUTTON_LABEL, &item);
                }

                /**
                * @brief 设置按钮类型
                * @param type 按钮类型（ArkUI_ButtonType枚举值）
                */
                void SetButtonType(ArkUI_ButtonType type) {
                    assert(handle_);  // 确保节点句柄有效
                    ArkUI_NumberValue value[] = {{.i32 = type}};  // 封装枚举值
                    ArkUI_AttributeItem item = {value, 1};  // 数值数组 + 数组长度
                    nativeModule_->setAttribute(handle_, NODE_BUTTON_TYPE, &item);
                }

                /**
                * @brief 设置按钮文本最小字体缩放比例
                * @param scale 最小缩放比例（浮点型，如0.8表示80%）
                */
                void SetMinFontScale(float scale) {
                    assert(handle_);  // 确保节点句柄有效
                    ArkUI_NumberValue value[] = {{.f32 = scale}};  // 封装浮点型缩放值
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_BUTTON_MIN_FONT_SCALE, &item);
                }

                /**
                * @brief 设置按钮文本最大字体缩放比例
                * @param scale 最大缩放比例（浮点型，如1.5表示150%）
                */
                void SetMaxFontScale(float scale) {
                    assert(handle_);  // 确保节点句柄有效
                    ArkUI_NumberValue value[] = {{.f32 = scale}};  // 封装浮点型缩放值
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_BUTTON_MAX_FONT_SCALE, &item);
                }
            };
        } // namespace NativeModule

        // 外部C接口，供外部调用
        extern "C" {
            using namespace NativeModule;
            std::shared_ptr<ArkUIBaseNode> CreateConfirmBtn() {
                auto button = std::make_shared<ArkUIButtonNode>();
                button->SetLabel("确认");
                button->SetButtonType(ARKUI_BUTTON_TYPE_CAPSULE);
                button->SetMinFontScale(0.8f);
                button->SetMaxFontScale(1.2f);
                button->SetWidth(100.0f);
                auto onClick = [](ArkUI_NodeEvent *event) {
                    // 从组件事件中获取基础事件对象
                    auto *inputEvent = OH_ArkUI_NodeEvent_GetInputEvent(event);
                    if (inputEvent == nullptr) {
                        return;
                    }
                    // 从组件事件获取事件类型
                    auto eventType = OH_ArkUI_NodeEvent_GetEventType(event);
                    switch (eventType) {
                        case NODE_ON_CLICK_EVENT: {
                            OH_LOG_Print(LOG_APP, LOG_INFO, 0xFF00, "[Sample_NdkAddInteractionEvent]",
                                        "NdkAddInteractionEvent_eventInfoOfCommonEvent eventInfo = %{public}s",
                                        eventInfo.c_str());
                        }
                        default: {
                            break;
                        }
                    }
                };
                button->RegisterOnClick(onClick);
                return button;
            }
        }  // extern "C"
    '''
}