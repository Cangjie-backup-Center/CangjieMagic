package magic.ui.arkui

import magic.dsl.*
import magic.jsonable.*
import std.collection.*
import stdx.encoding.json.{JsonValue, JsonObject, JsonException, JsonKind, JsonInt, JsonString, JsonBool, JsonFloat, JsonArray, JsonNull}


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

@template[
    dump: true,
]
public func template_text_list(info: TextInfo) {
    '''
        namespace NativeModule {
            // 列表项节点类
            class ArkUIListItemNode : public ArkUINode {
            public:
                ArkUIListItemNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_LIST_ITEM)) {}
            };

            // 列表节点类
            class ArkUIListNode : public ArkUINode {
            public:
                ArkUIListNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_LIST)) {} // 创建ArkUI的列表组件。

                ~ArkUIListNode() override {}
                // List组件的属性NDK接口封装。
                void SetScrollBarState(bool isShow) {
                    assert(handle_);
                    ArkUI_ScrollBarDisplayMode displayMode =
                        isShow ? ARKUI_SCROLL_BAR_DISPLAY_MODE_ON : ARKUI_SCROLL_BAR_DISPLAY_MODE_OFF;
                    ArkUI_NumberValue value[] = {{.i32 = displayMode}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_SCROLL_BAR_DISPLAY_MODE, &item);
                }

                void SetListItemAlignment(ArkUI_ListItemAlignment alignment) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = static_cast<int32_t>(alignment)}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_LIST_ALIGN_LIST_ITEM, &item);
                }
            };
        }  // namespace NativeModule

        // 外部C接口，供外部调用
        extern "C" {
            using namespace NativeModule;

            // 创建文本节点的函数
            std::shared_ptr<ArkUIColumnNode> createColumnNode(std::string text) {
                auto head = std::make_shared<ArkUITextNode>();
                auto content = std::make_shared<ArkUITextNode>();
                auto column = std::make_shared<ArkUIColumnNode>();
                head->SetTextContent("标题");
                head->SetFontSize(21);
                head->SetPercentWidth(1);
                head->SetPadding(15, 15, 10, 15);
                head->SetFontWeight(ARKUI_FONT_WEIGHT_W600);
                content->SetTextContent(text);
                content->SetFontSize(18);
                content->SetPercentWidth(1);
                content->SetPadding(5.0, 15, 15, 15);
                column->AddChild(head);
                column->AddChild(content);
                return column;
            }

            // 创建列表项的回调函数
            std::shared_ptr<ArkUIListItemNode> createListItem(int32_t index, std::string content) {
                auto listItem = std::make_shared<ArkUIListItemNode>();
                auto textNode = createColumnNode(content);
                listItem->InsertChild(textNode, index);
                listItem->SetBorderWidth(1.0);
                listItem->SetCornerRadius(18);
                listItem->SetBorderColor(0xFFf7f7f7);
                listItem->SetBorderWidth(1.0);
                // listItem->SetPercentWidth(0.9);
                listItem->SetMargin(0.0, 0.0, 15.0, 0.0);
                listItem->SetShadowStyle(ARKUI_SHADOW_STYLE_OUTER_DEFAULT_SM);
                return listItem;
            }

            std::shared_ptr<ArkUIBaseNode> CreateTextListExample() {
                // 创建List组件
                auto list = std::make_shared<ArkUIListNode>();
                list->SetPercentWidth(1);
                list->SetScrollBarState(true);

                // 创建列表项
                {% for (index, item) in enumerate(info.data) %}
                {
                    auto listItem = createListItem({% index %}, \"{% item.content %}\");
                    list->AddChild(listItem);
                }
                {% /for %}

                return list;
            }
        }  // extern "C"
    '''
}

@tool[
    description: "以纯文本为核心内容的列表，每个列表项是一段文字，比如步骤说明列表",
    terminal: true,
    parameters: {
        info: "列表展示信息"
    }
]
public func textListUI(info: TextInfo): String {
    template_text_list(info)
}