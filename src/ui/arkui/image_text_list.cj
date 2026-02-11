package magic.ui.arkui

import magic.dsl.*
import magic.jsonable.*
import std.collection.*
import stdx.encoding.json.{JsonValue, JsonObject, JsonException, JsonKind, JsonInt, JsonString, JsonBool, JsonFloat, JsonArray, JsonNull}

@jsonable
public class ImgTextItem {
    @field["Image url, real valid network address"]
    let icon: String
    @field["Core title, main entry name, ≤10 chars"]
    let title: String
    @field["Supplementary description/attribute/status, ≤15 chars"]
    let subTitle: String
    @field["Core info, concise (value/status/key point), ≤5 chars"]
    let coreInfo: String
    @field["Auxiliary related info, ≤10 chars"]
    let relatedInfo: String
}

@jsonable
public class ImgTextListInfo {
    @field["The theme to be presented"]
    let title: String
    @field["List data set, ImgTextItem array"]
    let data: Array<ImgTextItem>
}

@ui[
    description: "图文结构化列表：图文结合的结构化展示列表，适配需图文联动的信息展示场景",
    lang: "arkui",
    kind: "display"
]
public func template_image_text_list(info: ImgTextListInfo) {
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

            class ArkUIImageNode : public ArkUINode {
            public:
                // 构造函数：创建独立图片节点（ARKUI_NODE_IMAGE = 4）
                ArkUIImageNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_IMAGE)) {}

                /**
                * 设置主图片源（字符串格式：本地资源/网络URL/文件路径）
                * @param src 图片资源路径，如"app.media.icon"、"https://xxx.png"
                */
                void SetSrc(const char* src) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {.string = src};
                    nativeModule_->setAttribute(handle_, NODE_IMAGE_SRC, &item);
                }

                /**
                * 设置图片缩放适配方式
                * @param fit 适配模式，ArkUI_ObjectFit枚举（如ARKUI_OBJECT_FIT_COVER/ARKUI_OBJECT_FIT_CONTAIN）
                */
                void SetObjectFit(ArkUI_ObjectFit fit) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = fit}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_IMAGE_OBJECT_FIT, &item);
                }

                /**
                * 设置占位图（图片加载失败/加载中时显示）
                * @param alt 占位图资源路径，格式同SetSrc
                */
                void SetAlt(const char* alt) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {.string = alt};
                    nativeModule_->setAttribute(handle_, NODE_IMAGE_ALT, &item);
                }

                /**
                * 设置图片渲染模式（普通/模板模式）
                * @param mode 渲染模式，ArkUI_ImageRenderMode枚举
                */
                void SetRenderMode(ArkUI_ImageRenderMode mode) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = mode}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_IMAGE_RENDER_MODE, &item);
                }

                /**
                * 设置图片填充色（配合模板渲染模式使用）
                * @param color 颜色值，0xARGB格式（如0xFFFF0000=纯红、0xFF00FF00=纯绿）
                */
                void SetFillColor(uint32_t color) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.u32 = color}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_IMAGE_FILL_COLOR, &item);
                }

                /**
                * 设置图片缩放插值效果（优化缩放清晰度）
                * @param interpolation 插值模式，ArkUI_ImageInterpolation枚举
                */
                void SetInterpolation(ArkUI_ImageInterpolation interpolation) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = interpolation}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_IMAGE_INTERPOLATION, &item);
                }

                /**
                * 设置图片是否可拖拽
                * @param draggable 1=可拖拽，0=不可拖拽
                */
                void SetDraggable(int32_t draggable) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = draggable}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_IMAGE_DRAGGABLE, &item);
                }

                /**
                * 设置是否跟随图片原始尺寸显示
                * @param fitOriginal 1=跟随原始尺寸，0=使用组件设置的宽高
                */
                void SetFitOriginalSize(int32_t fitOriginal) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = fitOriginal}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_IMAGE_FIT_ORIGINAL_SIZE, &item);
                }

                /**
                * 设置图片重复填充方式
                * @param repeat 重复模式，ArkUI_ImageRepeat枚举
                */
                void SetObjectRepeat(ArkUI_ImageRepeat repeat) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = repeat}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_IMAGE_OBJECT_REPEAT, &item);
                }
            };
        }  // namespace NativeModule

        // 外部C接口，供外部调用
        extern "C" {
            using namespace NativeModule;

            std::shared_ptr<ArkUIBaseNode> CreateTextListExample() {
                auto column = std::make_shared<ArkUIColumnNode>();
                auto title = std::make_shared<ArkUITextNode>();
                title->SetTextContent(\"{% info.title %}\");
                title->SetFontSize(20);
                title->SetPercentWidth(1);
                title->SetPadding(15, 0, 10, 05);
                title->SetFontWeight(ARKUI_FONT_WEIGHT_W600);

                auto list = std::make_shared<ArkUIListNode>();
                list->SetPercentWidth(1);
                list->SetScrollBarState(true);
                {% for item in info.data %}
                {
                    auto listItem = std::make_shared<ArkUIListItemNode>();
                    listItem->SetPercentWidth(1);
                    listItem->SetHeight(65); // 每个列表项高度
                    listItem->SetCornerRadius(13);
                    listItem->SetBorderColor(0xFFEFEFEF);
                    listItem->SetBorderWidth(1.0);
                    listItem->SetMargin(0.0, 0.0, 15.0, 0.0);
                    listItem->SetBackgroundColor(0x25E8E8E8);

                    // 水平布局容器
                    auto row = std::make_shared<ArkUIRowNode>();
                    row->SetPercentWidth(1);
                    row->SetPercentHeight(1);
                    row->SetJustifyContent(ARKUI_FLEX_ALIGNMENT_SPACE_BETWEEN);
                    row->SetAlignItems(ARKUI_ITEM_ALIGNMENT_CENTER);
                    row->SetPadding(16, 12, 16, 12);

                    // 左侧区域：图标、title、subtilte
                    auto leftCol = std::make_shared<ArkUIRowNode>();
                    leftCol->SetAlignItems(ARKUI_ITEM_ALIGNMENT_START);

                    // 图标
                    auto icon = std::make_shared<ArkUIImageNode>();
                    icon->SetSrc(\"{% item.icon %}\");
                    icon->SetWidth(40);
                    icon->SetHeight(40);
                    leftCol->AddChild(icon);

                    // title
                    auto leftTextCol = std::make_shared<ArkUIColumnNode>();
                    auto dateText = std::make_shared<ArkUITextNode>();
                    dateText->SetTextContent(\"{% item.title %}\");
                    dateText->SetFontSize(14);
                    dateText->SetFontColor(0xFF333333);
                    dateText->SetMargin(0, 0, 5, 15);
                    leftTextCol->AddChild(dateText);

                    // subtitle
                    auto condText = std::make_shared<ArkUITextNode>();
                    condText->SetTextContent(\"{% item.subTitle %}\");
                    condText->SetFontSize(12);
                    condText->SetFontColor(0xFF999999);
                    leftTextCol->AddChild(condText);
                    leftCol->AddChild(leftTextCol);

                    // 右侧区域
                    auto rightCol = std::make_shared<ArkUIColumnNode>();
                    rightCol->SetAlignItems(ARKUI_ITEM_ALIGNMENT_END);

                    // coreInfo
                    auto tempText = std::make_shared<ArkUITextNode>();
                    tempText->SetTextContent(\"{% item.coreInfo %}\");
                    tempText->SetFontSize(18);
                    tempText->SetFontColor(0xFF333333);
                    tempText->SetMargin(0, 0, 5, 0);
                    rightCol->AddChild(tempText);

                    // relatedInfo
                    auto infoText = std::make_shared<ArkUITextNode>();
                    infoText->SetTextContent(\"{% item.relatedInfo %}\");
                    infoText->SetFontSize(12);
                    infoText->SetFontColor(0xFF999999);
                    rightCol->AddChild(infoText);

                    // 组装布局
                    row->AddChild(leftCol);
                    row->AddChild(rightCol);
                    listItem->InsertChild(row, 0);
                    list->AddChild(listItem);
                }
                {% /for %}

                column->AddChild(title);
                column->AddChild(list);
                column->SetMargin(0, 0, 15, 0);
                return column;
            }
        }  // extern "C"
    '''
}