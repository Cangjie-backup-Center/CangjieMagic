package magic.ui.arkui

import magic.dsl.*
import magic.jsonable.*
import std.collection.*
import stdx.encoding.json.{JsonValue, JsonObject, JsonException, JsonKind, JsonInt, JsonString, JsonBool, JsonFloat, JsonArray, JsonNull}


@jsonable
public class PieItemData {
   @field["numerical value"]
   let value: Float64
   @field["label"]
   let label: String
   @field["color(0xAARRGGBB)"]
   let color: String
}

@jsonable
public class PieChartInfo {
   @field["The theme to be presented"]
   let title: String
   @field["The data information to be displayed"]
   let data: Array<PieItemData>
}

@template[
//    dump: true,
]
public func template_pie_chart(info: PieChartInfo) {
   '''
        #include "native_drawing/drawing_point.h"
        #include "native_drawing/drawing_bitmap.h"
        #include "native_drawing/drawing_color.h"
        #include "native_drawing/drawing_color_filter.h"
        #include "native_drawing/drawing_canvas.h"
        #include "native_drawing/drawing_pen.h"
        #include "native_drawing/drawing_pixel_map.h"
        #include "native_drawing/drawing_brush.h"
        #include "native_drawing/drawing_rect.h"
        #include "native_drawing/drawing_font.h"
        #include "native_drawing/drawing_path.h"
        #include "native_drawing/drawing_register_font.h"
        #include "native_drawing/drawing_filter.h"
        #include "native_drawing/drawing_font_collection.h"
        #include "native_drawing/drawing_text_blob.h"
        #include "native_drawing/drawing_sampling_options.h"
        #include "native_drawing/drawing_text_declaration.h"
        #include "native_drawing/drawing_text_typography.h"
        #include "native_drawing/drawing_types.h"
        #include "native_drawing/drawing_typeface.h"

        namespace NativeModule {
            class ArkUICustomNode : public ArkUINode {
            public:
                // 使用自定义组件类型ARKUI_NODE_CUSTOM创建组件。
                ArkUICustomNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_CUSTOM))
                {
                    // 注册自定义事件监听器。
                    nativeModule_->addNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
                    // 声明自定义事件并传递自身作为自定义数据。
                    nativeModule_->registerNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_DRAW, 0, this);
                    // 绘制完成事件通知。
                    OH_ArkUI_RegisterDrawCallbackOnNodeHandle(handle_, nullptr, [](void* userData) {});
                }

                ~ArkUICustomNode() override
                {
                    // 反注册自定义事件监听器。
                    nativeModule_->removeNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
                    // 取消声明自定义事件。
                    nativeModule_->unregisterNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_DRAW);
                    OH_ArkUI_UnregisterDrawCallbackOnNodeHandle(handle_);
                }

            private:
                // ···
                static void OnStaticCustomEvent(ArkUI_NodeCustomEvent *event)
                {
                    // 获取组件实例对象，调用相关实例方法。
                    // ···
                    auto customNode = reinterpret_cast<ArkUICustomNode *>(OH_ArkUI_NodeCustomEvent_GetUserData(event));
                    auto type = OH_ArkUI_NodeCustomEvent_GetEventType(event);
                    switch (type) {
                        case ARKUI_NODE_CUSTOM_EVENT_ON_DRAW:
                            customNode->OnDraw(event);
                            break;
                        default:
                            break;
                    }
                }

                // 饼图数据结构
                struct PieData {
                    float value;          // 数值
                    uint32_t color;       // 颜色 (0xAARRGGBB)
                    std::string label;    // 标签

                    PieData(float v, uint32_t c, const std::string& l)
                : value(v), color(c), label(l) {}
                };

                void OnDraw(ArkUI_NodeCustomEvent *event)
                {
                    auto drawContext = OH_ArkUI_NodeCustomEvent_GetDrawContextInDraw(event);
                    // 获取图形绘制对象。
                    auto canvas = reinterpret_cast<OH_Drawing_Canvas *>(OH_ArkUI_DrawContext_GetCanvas(drawContext));
                    // 获取组件大小。
                    auto size = OH_ArkUI_DrawContext_GetSize(drawContext);
                    // 绘制自定义内容。
                    std::vector<PieData> pieData;
                    {% for (index, item) in enumerate(info.data) %}
                        pieData.push_back(PieData({% item.value %}, {% item.color %}, \"{% item.label %}\"));
                    {% /for %}

                    // 计算总和和角度比例
                    float total = 0;
                    for (const auto& data : pieData) {
                        total += data.value;
                    }
                    if (total <= 0) return;

                    // 创建填充画刷
                    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
                    OH_Drawing_BrushSetAntiAlias(brush, true);

                    // 创建描边画笔（饼图轮廓）
                    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
                    OH_Drawing_PenSetColor(pen, 0xFF000000);  // 黑色轮廓
                    OH_Drawing_PenSetWidth(pen, 2);           // 轮廓宽度2px
                    OH_Drawing_PenSetAntiAlias(pen, true);

                    // 计算饼图中心和半径（取宽高中较小值，避免变形）
                    const float centerX = size.width / 2.0f;
                    const float centerY = size.height / 2.0f;
                    const float radius = std::min(size.width, size.height) * 0.4f;

                    // 创建字型对象
                    OH_Drawing_Font *font = OH_Drawing_FontCreate();
                    // 设置文字大小
                    OH_Drawing_FontSetTextSize(font, 50);
                    // 设置跟随主题字体
                    OH_Drawing_FontSetThemeFontFollowed(font, true);

                    // 逐个绘制扇形
                    float startAngle = 0; // 起始角度（0度在右侧，顺时针）
                    for (const auto& data : pieData) {
                        float sweepAngle = (data.value / total) * 360; // 扇形角度

                        // 创建路径
                        OH_Drawing_Path* path = OH_Drawing_PathCreate();
                        OH_Drawing_PathMoveTo(path, centerX, centerY);
                        OH_Drawing_PathArcTo(path,
                            centerX - radius, centerY - radius,  // 圆弧包围盒左上角
                            centerX + radius, centerY + radius,  // 圆弧包围盒右下角
                            startAngle, sweepAngle); // 顺时针绘制
                        OH_Drawing_PathClose(path); // 闭合路径

                        // 设置填充颜色并填充
                        OH_Drawing_BrushSetColor(brush, data.color);
                        OH_Drawing_CanvasAttachBrush(canvas, brush);         // 绑定画刷到画布
                        OH_Drawing_CanvasDrawPath(canvas, path);             // 绘制路径（填充）
                        OH_Drawing_CanvasDetachBrush(canvas);                // 解绑画刷

                        // 绘制标签（使用官方标准文本接口）
                        float midAngle = startAngle + sweepAngle / 2;
                        float labelRadius = radius; // 标签距离中心的半径
                        // 角度转弧度，注意坐标系Y轴向下，sin值取反
                        float radian = midAngle * M_PI / 180.0f;
                        float labelX = centerX + labelRadius * cos(radian);
                        float labelY = centerY + labelRadius * sin(radian);
                        const std::string str = data.label;
                        // 创建字块对象
                        OH_Drawing_TextBlob *textBlob =
                            OH_Drawing_TextBlobCreateFromString(str.c_str(), font, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8);
                        // 绘制字块
                        OH_Drawing_CanvasDrawTextBlob(canvas, textBlob, labelX, labelY);
                        // 释放字块对象
                        OH_Drawing_TextBlobDestroy(textBlob);

                        // 更新起始角度
                        startAngle += sweepAngle;

                        // 释放路径
                        OH_Drawing_PathDestroy(path);
                    }

                    // 释放资源
                    OH_Drawing_BrushDestroy(brush);
                    OH_Drawing_PenDestroy(pen);
                    OH_Drawing_FontDestroy(font);
                }
            };
       }  // namespace NativeModule

       // 外部C接口，供外部调用
        extern "C" {
            using namespace NativeModule;

            std::shared_ptr<ArkUIBaseNode> DrawPieChart() {
                // 创建节点
                auto column = std::make_shared<ArkUIColumnNode>();
                auto customNode = std::make_shared<ArkUICustomNode>();
                customNode->SetPercentWidth(1);
                customNode->SetHeight(450);
                column->AddChild(customNode);
                return column;
            }
        }  // extern "C"
   '''
}