package magic.ui.arkui

import magic.dsl.*
import magic.jsonable.*
import std.collection.*
import stdx.encoding.json.{JsonValue, JsonObject, JsonException, JsonKind, JsonInt, JsonString, JsonBool, JsonFloat, JsonArray, JsonNull}


@jsonable
public class CalendarPickerInfo {
    @field["Title of the calendar picker, displayed at the top as explanatory text"]
    let title: String
    @field["Start optional date of the date picker, format: YYYY-M-D, restricts the earliest date selectable by the user"]
    let start_date: String
    @field["End optional date of the date picker, format: YYYY-M-D, restricts the latest date selectable by the user"]
    let end_date: String
}

@template[]
public func template_calendar_picker(info: CalendarPickerInfo) {
    '''
        namespace NativeModule {
            class ArkUICalendarPickerNode : public ArkUINode {
            public:
                ArkUICalendarPickerNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_CALENDAR_PICKER)) {}

                /**
                * @brief 设置日历选择器选中状态背景样式（圆角半径）
                * @param radius 圆角半径值：<0=直角矩形；0~16=圆角矩形；≥16=圆形（范围[0, +∞)）
                */
                void SetHintRadius(float radius) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = radius}};
                    ArkUI_AttributeItem item = {value, 1};
                    int32_t ret = nativeModule_->setAttribute(handle_, NODE_CALENDAR_PICKER_HINT_RADIUS, &item);
                    if (ret != 0) {
                        printf("SetHintRadius failed! ret=%d, radius=%.2f", ret, radius);
                    }
                }

                /**
                * @brief 设置日历选择器选中日期（年/月/日）
                * @param year 选中日期的年（u32类型）
                * @param month 选中日期的月（u32类型）
                * @param day 选中日期的日（u32类型）
                */
                void SetSelectedDate(uint32_t year, uint32_t month, uint32_t day) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {
                        {.u32 = year},
                        {.u32 = month},
                        {.u32 = day}
                    };
                    ArkUI_AttributeItem item = {value, 3};
                    int32_t ret = nativeModule_->setAttribute(handle_, NODE_CALENDAR_PICKER_SELECTED_DATE, &item);
                    if (ret != 0) {
                        printf("SetSelectedDate failed! ret=%d, %d-%d-%d", ret, year, month, day);
                    }
                }

                /**
                * @brief 获取日历选择器选中日期（年/月/日）
                * @param outYear 输出选中日期的年
                * @param outMonth 输出选中日期的月
                * @param outDay 输出选中日期的日
                * @return bool true=获取成功，false=获取失败
                */
                bool GetSelectedDate(uint32_t& outYear, uint32_t& outMonth, uint32_t& outDay) {
                    assert(handle_);
                    const ArkUI_AttributeItem* attrItem = nativeModule_->getAttribute(handle_, NODE_CALENDAR_PICKER_SELECTED_DATE);
                    if (attrItem == nullptr || attrItem->value == nullptr || attrItem->size < 3) {
                        printf("GetSelectedDate failed! ");
                        return false;
                    }
                    outYear = attrItem->value[0].u32;
                    outMonth = attrItem->value[1].u32;
                    outDay = attrItem->value[2].u32;
                    return true;
                }

                /**
                * @brief 设置日历选择器与入口组件的对齐方式及偏移
                * @param alignment 对齐模式（ArkUI_CalendarAlignment枚举）
                * @param offsetX x轴偏移量（可选，默认0.0f）
                * @param offsetY y轴偏移量（可选，默认0.0f）
                */
                void SetEdgeAlignment(ArkUI_CalendarAlignment alignment, float offsetX = 0.0f, float offsetY = 0.0f) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {
                        {.i32 = static_cast<int32_t>(alignment)},
                        {.f32 = offsetX},
                        {.f32 = offsetY}
                    };
                    ArkUI_AttributeItem item = {value, 3};
                    int32_t ret = nativeModule_->setAttribute(handle_, NODE_CALENDAR_PICKER_EDGE_ALIGNMENT, &item);
                    if (ret != 0) {
                        printf("SetEdgeAlignment failed! ret=%d, alignment=%d, offset(%.2f, %.2f)", ret, (int)alignment, offsetX, offsetY);
                    }
                }

                /**
                * @brief 设置日历选择器入口区域的文本样式（颜色/字号/字重）
                * @param fontColor 字体颜色（u32类型，ARGB格式）
                * @param fontSize 字体大小（fp单位，f32类型）
                * @param fontWeight 字体权重（ArkUI_FontWeight枚举）
                */
                void SetTextStyle(uint32_t fontColor, float fontSize, ArkUI_FontWeight fontWeight) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {
                        {.u32 = fontColor},
                        {.f32 = fontSize},
                        {.i32 = static_cast<int32_t>(fontWeight)}
                    };
                    ArkUI_AttributeItem item = {value, 3};
                    int32_t ret = nativeModule_->setAttribute(handle_, NODE_CALENDAR_PICKER_TEXT_STYLE, &item);
                    if (ret != 0) {
                        printf("SetTextStyle failed! ret=%d, color=0x%X, size=%.2f, weight=%d", ret, fontColor, fontSize, (int)fontWeight);
                    }
                }

                /**
                * @brief 设置日历选择器的起始日期
                * @param startDate 起始日期字符串（格式："YYYY-M-D"）
                */
                void SetStartDate(const char* startDate) {
                    assert(handle_);
                    if (startDate == nullptr || strlen(startDate) == 0) {
                        printf("SetStartDate error: invalid date string!");
                        return;
                    }
                    ArkUI_AttributeItem item = {};
                    item.string = const_cast<char*>(startDate);
                    int32_t ret = nativeModule_->setAttribute(handle_, NODE_CALENDAR_PICKER_START, &item);
                    if (ret != 0) {
                        printf("SetStartDate failed! ret=%d, date=%s", ret, startDate);
                    }
                }

                /**
                * @brief 设置日历选择器的结束日期
                * @param endDate 结束日期字符串（格式："YYYY-M-D"）
                */
                void SetEndDate(const char* endDate) {
                    assert(handle_);
                    if (endDate == nullptr || strlen(endDate) == 0) {
                        printf("SetEndDate error: invalid date string!");
                        return;
                    }
                    ArkUI_AttributeItem item = {};
                    item.string = const_cast<char*>(endDate);
                    int32_t ret = nativeModule_->setAttribute(handle_, NODE_CALENDAR_PICKER_END, &item);
                    if (ret != 0) {
                        printf("SetEndDate failed! ret=%d, date=%s", ret, endDate);
                    }
                }

                /**
                * @brief 重置选中状态背景样式为默认值
                */
                void ResetHintRadius() {
                    assert(handle_);
                    nativeModule_->resetAttribute(handle_, NODE_CALENDAR_PICKER_HINT_RADIUS);
                }

                /**
                * @brief 重置选中日期为默认值
                */
                void ResetSelectedDate() {
                    assert(handle_);
                    nativeModule_->resetAttribute(handle_, NODE_CALENDAR_PICKER_SELECTED_DATE);
                }
            };
        }  // namespace NativeModule

        // 外部C接口，供外部调用
        extern "C" {
            using namespace NativeModule;

            std::shared_ptr<ArkUIBaseNode> CreateDatePicker() {
                auto column = std::make_shared<ArkUIColumnNode>();
                column->SetBorderWidth(1);
                column->SetPercentWidth(1);
                column->SetCornerRadius(20);
                column->SetBorderColor(0xFFefefef);
                column->SetShadowStyle(ARKUI_SHADOW_STYLE_OUTER_DEFAULT_MD);

                auto title = std::make_shared<ArkUITextNode>();
                title->SetTextContent(\"{% info.title %}\");  // 替换为日期选择器标题
                title->SetFontSize(22);
                title->SetPercentWidth(1);
                title->SetPadding(15, 0.0, 10, 15);
                title->SetFontWeight(ARKUI_FONT_WEIGHT_W600);
                column->AddChild(title);

                auto calendarPicker = std::make_shared<ArkUICalendarPickerNode>();

                calendarPicker->SetHintRadius(20.0f);
                calendarPicker->SetEdgeAlignment(ArkUI_CalendarAlignment::ARKUI_CALENDAR_ALIGNMENT_CENTER, 10.0f, 5.0f);
                calendarPicker->SetTextStyle(0xFF182431, 14.0f, ArkUI_FontWeight::ARKUI_FONT_WEIGHT_NORMAL);
                calendarPicker->SetStartDate(\"{% info.start_date %}\");
                calendarPicker->SetEndDate(\"{% info.end_date %}\");
                auto onClick = [](ArkUI_NodeEvent *event) {
                        // 从组件事件获取事件类型
                        auto eventType = OH_ArkUI_NodeEvent_GetEventType(event);
                        switch (eventType) {
                            case NODE_CALENDAR_PICKER_EVENT_ON_CHANGE: {
                                auto componentEvent = OH_ArkUI_NodeEvent_GetNodeComponentEvent(event);
                                std::string yearStr = std::to_string(componentEvent->data[0].u32);
                                std::string monthStr = std::to_string(componentEvent->data[1].u32);
                                std::string dataStr = std::to_string(componentEvent->data[2].u32);
                                g_click_callback(\"{% info.title %}\", yearStr+"-"+monthStr+"-"+dataStr);
                            }
                            default: {
                                break;
                            }
                        }
                    };
                calendarPicker->RegisterOnCalendarPickerChange(onClick);
                column->SetHeight(450);

                // 7. 将行容器添加到列容器
                column->AddChild(calendarPicker);

                return column;
            }
        }  // extern "C"
    '''
}