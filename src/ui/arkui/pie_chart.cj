package magic.ui.arkui

import magic.dsl.*
import magic.prelude.*
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

@ui[
    description: "饼图，展示数据占比",
    kind: "display"
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
        #include <native_drawing/drawing_round_rect.h>
        #include "native_drawing/drawing_text_blob.h"
        #include "native_drawing/drawing_text_declaration.h"
        #include "native_drawing/drawing_text_typography.h"
        #include "native_drawing/drawing_types.h"
        #include "native_drawing/drawing_typeface.h"

        namespace NativeModule {
            constexpr float SECTOR_ZOOM_OFFSET = 20.0f;  // 扇区放大偏移量(px)
            constexpr float SECTOR_GAP_ANGLE = 0.8f;     // 扇区间隙角度(度)
            constexpr uint32_t DEFAULT_PEN_COLOR = 0xFF000000; // 描边颜色(ARGB)
            constexpr float DEFAULT_PEN_WIDTH = 2.0f;    // 描边宽度
            constexpr float FONT_SIZE_MAIN = 60.0f;      // 主字体大小（预留）
            constexpr float FONT_SIZE_LEGEND = 45.0f;    // 图例字体大小
            constexpr float PIE_AREA_RATIO = 0.75f;      // 环图区域占组件高度比例
            constexpr float OUTER_RADIUS_RATIO = 0.35f;  // 外半径占最小宽高比例
            constexpr float INNER_RADIUS_RATIO = 0.7f;   // 内半径占外半径比例

            const float FONT_SIZE_CENTER_LABEL = 24.0f;
            const float TIP_BOX_PADDING_H = 18.0f;  // Tip框水平内边距
            const float TIP_BOX_PADDING_V = 50.0f;  // Tip框垂直内边距
            const float TIP_BOX_OFFSET_Y = -80.0f;  // Tip框相对扇区中心的Y轴偏移（向上偏移，避免遮挡扇区）
            const uint32_t TIP_BOX_BG_COLOR = 0xFF2C3E50; // Tip框背景色（深灰半透明）
            const uint32_t TIP_BOX_TEXT_COLOR = 0xFFFFFFFF; // Tip框文字颜色（白色）
            const float TIP_BOX_BORDER_RADIUS = 4.0f; // Tip框圆角半径（可选，优化视觉）

            class ArkUICustomRingChartNode : public ArkUINode {
            public:
                // 使用自定义组件类型ARKUI_NODE_CUSTOM创建组件。
                ArkUICustomRingChartNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_CUSTOM)),
                totalValue(0.0f), canvasWidth_(0.0f), canvasHeight_(0.0f),
                    centerX_(0.0f), centerY_(0.0f), outerRadius_(0.0f), innerRadius_(0.0f),
                    brush_(nullptr), pen_(nullptr), fontMain_(nullptr), fontLegend_(nullptr){
                    InitPieData();
                    InitDrawResources();
                    nativeModule_->addNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
                    nativeModule_->registerNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_DRAW, 0, this);
                    OH_ArkUI_RegisterDrawCallbackOnNodeHandle(handle_, nullptr, [](void *userData) {});
                }

                ~ArkUICustomRingChartNode() override {
                    nativeModule_->removeNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
                    nativeModule_->unregisterNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_DRAW);
                    OH_ArkUI_UnregisterDrawCallbackOnNodeHandle(handle_);
                    ReleaseDrawResources();
                }

                void OnClick(ArkUI_NodeEvent * event) {
                    auto inputEvent = OH_ArkUI_NodeEvent_GetInputEvent(event);
                    float clickX  = OH_ArkUI_PointerEvent_GetX(inputEvent) * 3.25;
                    float clickY = OH_ArkUI_PointerEvent_GetY(inputEvent) * 3.25;
                    const float relX = clickX - centerX_;
                    const float relY = clickY - centerY_;

                    // 直角坐标转极坐标：核心用于扇区匹配和无效点击过滤
                    const float clickDistance = sqrt(relX * relX + relY * relY); // 点击点到中心的距离
                    float clickAngle = atan2(relY, relX) * 180.0f / M_PI;       // 极角（度，范围-180~180）
                    if (clickAngle < 0) clickAngle += 360.0f;                   // 转为0~360度正角度，方便匹配

                    // 过滤无效点击：仅点击环图有效区域（内半径 ~ 外半径之间）
                    if (clickDistance < innerRadius_ || clickDistance > outerRadius_) {
                        return;
                    }

                    // 遍历匹配被点击的扇区
                    float currentStartAngle = 0.0f;
                    bool isStateUpdated = false;
                    for (size_t i = 0; i < pieData.size(); ++i) {
                        auto& sectorData = pieData[i];
                        const float originSweep = (sectorData.value / totalValue) * 360;
                        const float drawSweep = std::max(0.5f, originSweep - SECTOR_GAP_ANGLE);

                        // 跳过过小的扇区（无绘制意义）
                        if (drawSweep < 0.5f) {
                            currentStartAngle += originSweep;
                            continue;
                        }

                        // 计算当前扇区的有效角度区间
                        const float sectorStart = currentStartAngle + SECTOR_GAP_ANGLE / 2.0f;
                        const float sectorEnd = sectorStart + drawSweep;
                        currentStartAngle += originSweep;

                        // 匹配到点击扇区，更新选中状态
                        if (clickAngle >= sectorStart && clickAngle <= sectorEnd) {
                            UnselectOtherSectors(i);          // 单扇区独占放大：取消其他扇区选中状态
                            sectorData.isSelected = !sectorData.isSelected; // 切换当前扇区选中状态
                            isStateUpdated = true;
                            break;
                        }
                    }

                    // 状态更新后手动触发重绘（C++层核心步骤，无自动重绘机制）
                    if (isStateUpdated && handle_) {
                        ArkUI_NativeNodeAPI_1* nodeAPI = nullptr;
                        OH_ArkUI_GetModuleInterface(ARKUI_NATIVE_NODE, ArkUI_NativeNodeAPI_1, nodeAPI);
                        nodeAPI->markDirty(handle_, NODE_NEED_RENDER);
                    }
                }

            private:
                static void OnStaticCustomEvent(ArkUI_NodeCustomEvent *event) {
                    auto customNode = reinterpret_cast<ArkUICustomRingChartNode *>(OH_ArkUI_NodeCustomEvent_GetUserData(event));
                    auto type = OH_ArkUI_NodeCustomEvent_GetEventType(event);
                    switch (type) {
                    case ARKUI_NODE_CUSTOM_EVENT_ON_DRAW:
                        customNode->OnDraw(event);
                        break;
                    default:
                        break;
                    }
                }

                void UnselectOtherSectors(size_t selectedIndex) {
                    for (size_t i = 0; i < pieData.size(); ++i) {
                        if (i != selectedIndex) {
                            pieData[i].isSelected = false;
                        }
                    }
                }

                // 饼图数据结构
                struct PieData {
                    float value;       // 数值
                    uint32_t color;    // 颜色 (0xAARRGGBB)
                    std::string label; // 标签
                    bool isSelected = false;   // 是否被选中

                    PieData(float v, uint32_t c, const std::string &l) : value(v), color(c), label(l) {}
                };
                // 初始化环图数据：仅构造时执行一次，避免重绘重复添加
                void InitPieData() {
                    {% for (index, item) in enumerate(info.data) %}
                        pieData.push_back(PieData({% item.value %}, {% item.color %}, \"{% item.label %}\"));
                    {% /for %}

                    // 计算所有扇区数值总和，供角度计算使用
                    for (const auto &data : pieData) {
                        totalValue += data.value;
                    }
                }

                // 初始化绘制资源：仅创建一次，提升重绘性能
                void InitDrawResources() {
                    // 初始化画刷：开启抗锯齿，保证绘制平滑
                    brush_ = OH_Drawing_BrushCreate();
                    if (brush_) {
                        OH_Drawing_BrushSetAntiAlias(brush_, true);
                    }
                    // 初始化画笔：黑色描边、固定宽度、抗锯齿
                    pen_ = OH_Drawing_PenCreate();
                    if (pen_) {
                        OH_Drawing_PenSetColor(pen_, DEFAULT_PEN_COLOR);
                        OH_Drawing_PenSetWidth(pen_, DEFAULT_PEN_WIDTH);
                        OH_Drawing_PenSetAntiAlias(pen_, true);
                    }
                    // 初始化主字体（预留，可用于扇区内部标签绘制）
                    fontMain_ = OH_Drawing_FontCreate();
                    if (fontMain_) {
                        OH_Drawing_FontSetTextSize(fontMain_, FONT_SIZE_MAIN);
                        OH_Drawing_FontSetThemeFontFollowed(fontMain_, true);
                    }
                    // 初始化图例字体：用于绘制底部图例文字
                    fontLegend_ = OH_Drawing_FontCreate();
                    if (fontLegend_) {
                        OH_Drawing_FontSetTextSize(fontLegend_, FONT_SIZE_LEGEND);
                        OH_Drawing_FontSetThemeFontFollowed(fontLegend_, true);
                    }
                }

                // 释放绘制资源：析构时执行，避免内存泄漏
                void ReleaseDrawResources() {
                    if (brush_) { OH_Drawing_BrushDestroy(brush_); brush_ = nullptr; }
                    if (pen_) { OH_Drawing_PenDestroy(pen_); pen_ = nullptr; }
                    if (fontMain_) { OH_Drawing_FontDestroy(fontMain_); fontMain_ = nullptr; }
                    if (fontLegend_) { OH_Drawing_FontDestroy(fontLegend_); fontLegend_ = nullptr; }
                }

                // 环图核心数据：成员变量持久化，供绘制/点击事件共享
                std::vector<PieData> pieData;
                float totalValue; // 所有扇区数值总和

                // 画布/环图参数：绘制时更新，点击事件时复用，保证坐标一致性
                float canvasWidth_;  // 组件实际绘制宽度
                float canvasHeight_; // 组件实际绘制高度
                float centerX_;      // 环图中心X坐标
                float centerY_;      // 环图中心Y坐标
                float outerRadius_;  // 环图基础外半径（未放大）
                float innerRadius_;  // 环图基础内半径（未放大）

                // 绘制资源：成员变量，仅创建一次，避免重复开销
                OH_Drawing_Brush* brush_;
                OH_Drawing_Pen* pen_;
                OH_Drawing_Font* fontMain_;
                OH_Drawing_Font* fontLegend_;

                void OnDraw(ArkUI_NodeCustomEvent *event) {
                    auto drawContext = OH_ArkUI_NodeCustomEvent_GetDrawContextInDraw(event);
                    auto canvas = reinterpret_cast<OH_Drawing_Canvas *>(OH_ArkUI_DrawContext_GetCanvas(drawContext));
                    // 获取组件实际尺寸，更新到成员变量
                    auto size = OH_ArkUI_DrawContext_GetSize(drawContext);
                    canvasWidth_ = size.width;
                    canvasHeight_ = size.height;

                    // 边界判断：数值总和为0/绘制资源未初始化，直接返回
                    if (totalValue <= 0 || !brush_ || !pen_ || !fontLegend_) {
                        return;
                    }

                    // 计算环图基础参数，更新到成员变量（供点击事件使用）
                    const float pieAreaH = canvasHeight_ * PIE_AREA_RATIO;
                    centerX_ = canvasWidth_ * 0.5f;
                    centerY_ = pieAreaH * 0.5f;
                    outerRadius_ = std::min(canvasWidth_, canvasHeight_) * OUTER_RADIUS_RATIO;
                    innerRadius_ = outerRadius_ * INNER_RADIUS_RATIO;

                    // 定义变量存储选中扇区的信息（供后续绘制使用）
                    PieData* selectedSector = nullptr;
                    float selectedSectorCenterAngle = 0.0f; // 选中扇区的中心角度（度）
                    float selectedSectorStartAngle = 0.0f;  // 选中扇区的起始角度（度）
                    float selectedSectorSweepAngle = 0.0f;  // 选中扇区的实际绘制角度（度）

                    // 遍历绘制每个扇区：核心实现选中扇区动态放大
                    float startAngle = 0.0f; // 扇区起始角度（0度在右侧，顺时针递增）
                    for (auto& sectorData : pieData) { // 非const引用，可访问选中状态
                        // 计算扇区原始角度和实际绘制角度（扣除间隙）
                        const float originSweep = (sectorData.value / totalValue) * 360;
                        const float drawSweep = std::max(0.5f, originSweep - SECTOR_GAP_ANGLE);

                        // 跳过过小的扇区，避免绘制异常
                        if (drawSweep < 0.5f) {
                            startAngle += originSweep;
                            continue;
                        }

                        // 核心逻辑：根据选中状态计算动态半径，同步放大内外半径保证环宽不变
                        float curOuterRadius = outerRadius_;
                        float curInnerRadius = innerRadius_;
                        if (sectorData.isSelected) {
                            curOuterRadius += SECTOR_ZOOM_OFFSET;
                            selectedSector = &sectorData;
                            selectedSectorStartAngle = startAngle;
                            selectedSectorSweepAngle = drawSweep;
                            selectedSectorCenterAngle = startAngle + SECTOR_GAP_ANGLE/2.0f + drawSweep/2.0f;
                        }

                        // 创建扇区绘制路径，判空保证健壮性
                        OH_Drawing_Path* sectorPath = OH_Drawing_PathCreate();
                        if (!sectorPath) {
                            startAngle += originSweep;
                            continue;
                        }

                        // 计算扇区实际起始角度（跳过间隙的一半，保证间隙居中）
                        const float actualStartAngle = startAngle + SECTOR_GAP_ANGLE / 2.0f;
                        // 计算外圆弧起点坐标
                        const float startX_outer = centerX_ + curOuterRadius * cos(actualStartAngle * M_PI / 180.0f);
                        const float startY_outer = centerY_ + curOuterRadius * sin(actualStartAngle * M_PI / 180.0f);

                        // 构建环形扇区路径：外圆弧 → 内圆弧 → 闭合
                        OH_Drawing_PathMoveTo(sectorPath, startX_outer, startY_outer);
                        // 绘制顺时针外圆弧
                        OH_Drawing_PathArcTo(sectorPath,
                            centerX_ - curOuterRadius, centerY_ - curOuterRadius,
                            centerX_ + curOuterRadius, centerY_ + curOuterRadius,
                            startAngle, drawSweep);
                        // 计算内圆弧终点坐标
                        const float actualEndAngle = actualStartAngle + drawSweep;
                        const float endX_inner = centerX_ + curInnerRadius * cos(actualEndAngle * M_PI / 180.0f);
                        const float endY_inner = centerY_ + curInnerRadius * sin(actualEndAngle * M_PI / 180.0f);
                        OH_Drawing_PathLineTo(sectorPath, endX_inner, endY_inner);

                        // 绘制逆时针内圆弧，闭合环形
                        OH_Drawing_PathArcTo(sectorPath,
                            centerX_ - curInnerRadius, centerY_ - curInnerRadius,
                            centerX_ + curInnerRadius, centerY_ + curInnerRadius,
                            actualEndAngle, -drawSweep);
                        // 闭合路径，形成完整的环形扇区
                        OH_Drawing_PathClose(sectorPath);

                        // 绘制扇区：填充颜色
                        OH_Drawing_BrushSetColor(brush_, sectorData.color);
                        OH_Drawing_CanvasAttachBrush(canvas, brush_);
                        OH_Drawing_CanvasDrawPath(canvas, sectorPath);
                        OH_Drawing_CanvasDetachBrush(canvas);

                        // 释放路径资源，避免内存泄漏
                        OH_Drawing_PathDestroy(sectorPath);
                        // 更新下一个扇区的起始角度
                        startAngle += originSweep;
                    }

                    if (selectedSector != nullptr) {
                        // 1. 计算选中扇区的占比（保留1位小数，如35.0%）
                        float ratio = (selectedSector->value / totalValue) * 100.0f;
                        char ratioStr[16] = {0};
                        snprintf(ratioStr, sizeof(ratioStr), "%.2f%%", ratio);
                        std::string tipContent = selectedSector->label + ": " + ratioStr; // Tip框内容：名称+占比（换行）

                        // 环形中间显示名称
                        OH_Drawing_TextBlob* centerTextBlob = OH_Drawing_TextBlobCreateFromString(
                            selectedSector->label.c_str(), fontMain_, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8
                        );
                        // 获取文字尺寸，用于计算居中坐标
                        OH_Drawing_Rect* centerTextRect = OH_Drawing_RectCreate(0, 0, 0, 0);
                        OH_Drawing_TextBlobGetBounds(centerTextBlob, centerTextRect);
                        float textW = OH_Drawing_RectGetWidth(centerTextRect);
                        float textH = OH_Drawing_RectGetHeight(centerTextRect);
                        float centerTextX = centerX_ - textW / 2.0f;
                        float centerTextY = centerY_ + textH / 3.0f; // 微调Y轴，匹配文字基线对齐规则
                        OH_Drawing_BrushSetColor(brush_, 0xFF000000);
                        OH_Drawing_CanvasAttachBrush(canvas, brush_);
                        OH_Drawing_CanvasDrawTextBlob(canvas, centerTextBlob, centerTextX, centerTextY);
                        OH_Drawing_CanvasDetachBrush(canvas);
                        // 释放资源
                        OH_Drawing_TextBlobDestroy(centerTextBlob);
                        OH_Drawing_RectDestroy(centerTextRect);

                        // 绘制矩形Tip框（名称+占比）
                        float zoomedOuterRadius = outerRadius_ + SECTOR_ZOOM_OFFSET;
                        // 扇区中心的世界坐标
                        float sectorCenterX = centerX_ + zoomedOuterRadius * cos(selectedSectorCenterAngle * M_PI / 180.0f);
                        float sectorCenterY = centerY_ + zoomedOuterRadius * sin(selectedSectorCenterAngle * M_PI / 180.0f);
                        float tipStartX = sectorCenterX;
                        if (selectedSectorCenterAngle > 90 && selectedSectorCenterAngle < 270) {
                            tipStartX += 70;
                        } else {
                            tipStartX -= 70;
                        }
                        float tipStartY = sectorCenterY + TIP_BOX_OFFSET_Y;

                        // 创建Tip框文字Blob
                        OH_Drawing_TextBlob* tipTextBlob = OH_Drawing_TextBlobCreateFromString(
                            tipContent.c_str(), fontLegend_, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8
                        );
                        OH_Drawing_Rect* tipTextRect = OH_Drawing_RectCreate(0, 0, 0, 0);
                        OH_Drawing_TextBlobGetBounds(tipTextBlob, tipTextRect);
                        float tipTextW = OH_Drawing_RectGetWidth(tipTextRect);
                        float tipTextH = OH_Drawing_RectGetHeight(tipTextRect);

                        // 计算Tip框的实际宽高（文字尺寸 + 内边距）
                        float tipBoxW = tipTextW + 2 * TIP_BOX_PADDING_H;
                        float tipBoxH = tipTextH + 2 * TIP_BOX_PADDING_V; // 增加行间距补偿
                        // Tip框居中：起始X向左偏移半宽，保证Tip框在扇区中心正上方
                        tipStartX -= tipBoxW / 2.0f;

                        // 创建带圆角的Tip框路径
                        OH_Drawing_Path* tipBoxPath = OH_Drawing_PathCreate();
                        OH_Drawing_Rect* tipBaseRect = OH_Drawing_RectCreate(tipStartX, tipStartY,
                                                                    tipStartX + tipBoxW, tipStartY + tipBoxH);
                        OH_Drawing_RoundRect* tipRoundRect = OH_Drawing_RoundRectCreate(
                            tipBaseRect,                // 基础矩形区域
                            TIP_BOX_BORDER_RADIUS,      // 水平圆角半径rx
                            TIP_BOX_BORDER_RADIUS       // 垂直圆角半径ry（与rx一致，正圆圆角）
                        );
                        OH_Drawing_PathAddRoundRect(
                            tipBoxPath,
                            tipRoundRect,       // 传入圆角矩形结构体地址
                            PATH_DIRECTION_CW    // 绘制方向：顺时针
                        );

                        // 填充背景色
                        OH_Drawing_BrushSetColor(brush_, TIP_BOX_BG_COLOR);
                        OH_Drawing_CanvasAttachBrush(canvas, brush_);
                        OH_Drawing_CanvasDrawPath(canvas, tipBoxPath);
                        OH_Drawing_CanvasDetachBrush(canvas);
                        OH_Drawing_CanvasAttachPen(canvas, pen_);
                        OH_Drawing_CanvasDrawPath(canvas, tipBoxPath);
                        OH_Drawing_CanvasDetachPen(canvas);

                        float tipTextDrawX = tipStartX + TIP_BOX_PADDING_H;
                        float tipTextDrawY = tipStartY + TIP_BOX_PADDING_V + (OH_Drawing_FontGetTextSize(fontLegend_) / 3.0f);
                        OH_Drawing_BrushSetColor(brush_, TIP_BOX_TEXT_COLOR);
                        OH_Drawing_CanvasAttachBrush(canvas, brush_);
                        OH_Drawing_CanvasDrawTextBlob(canvas, tipTextBlob, tipTextDrawX, tipTextDrawY);
                        OH_Drawing_CanvasDetachBrush(canvas);
                        // 释放Tip框路径资源
                        OH_Drawing_PathDestroy(tipBoxPath);

                        // 释放文字相关资源
                        OH_Drawing_TextBlobDestroy(tipTextBlob);
                        OH_Drawing_RectDestroy(tipTextRect);

                    }

                    // 绘制底部图例：适配组件宽度，自动换行
                    const float legendBlockW = 30.0f;
                    const float legendBlockH = 30.0f;
                    const float legendTextMargin = 15.0f;
                    const float legendItemColSpace = 50.0f;
                    const float legendItemVSpace = 60.0f;
                    const float legendStartX = legendItemColSpace;
                    float legendStartY = pieAreaH + 20.0f;
                    float currentLegendX = legendStartX;

                    for (const auto& sectorData : pieData) {
                        // 创建图例标识块路径
                        OH_Drawing_Path* legendBlockPath = OH_Drawing_PathCreate();
                        if (!legendBlockPath) continue;
                        // 创建图例文字Blob
                        OH_Drawing_TextBlob *legendTextBlob = OH_Drawing_TextBlobCreateFromString(
                            sectorData.label.c_str(), fontLegend_, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8
                        );
                        if (!legendTextBlob) {
                            OH_Drawing_PathDestroy(legendBlockPath);
                            continue;
                        }

                        // 计算文字绘制坐标
                        float textX = currentLegendX + legendBlockW + legendTextMargin;
                        float textY = legendStartY + legendBlockH / 2.0f + (OH_Drawing_FontGetTextSize(fontLegend_) / 3.0f);
                        // 获取文字尺寸，用于自动换行判断
                        OH_Drawing_Rect* textRect = OH_Drawing_RectCreate(0, 0, 0, 0);
                        OH_Drawing_TextBlobGetBounds(legendTextBlob, textRect);

                        // 自动换行：超出组件宽度则换行绘制
                        if (textX + OH_Drawing_RectGetWidth(textRect) > canvasWidth_ - 20.0f) {
                            currentLegendX = legendStartX;
                            legendStartY += legendItemVSpace;
                            textX = currentLegendX + legendBlockW + legendTextMargin;
                            textY = legendStartY + legendBlockH / 2.0f + (OH_Drawing_FontGetTextSize(fontLegend_) / 3.0f);
                        }

                        // 绘制图例标识块（矩形）
                        OH_Drawing_PathAddRect(legendBlockPath,
                            currentLegendX, legendStartY,
                            currentLegendX + legendBlockW, legendStartY + legendBlockH, PATH_DIRECTION_CW);
                        // 填充标识块颜色 + 描边
                        OH_Drawing_BrushSetColor(brush_, sectorData.color);
                        OH_Drawing_CanvasAttachBrush(canvas, brush_);
                        OH_Drawing_CanvasDrawPath(canvas, legendBlockPath);
                        OH_Drawing_CanvasDetachBrush(canvas);

                        OH_Drawing_CanvasAttachPen(canvas, pen_);
                        OH_Drawing_CanvasDrawPath(canvas, legendBlockPath);
                        OH_Drawing_CanvasDetachPen(canvas);

                        // 绘制图例文字
                        OH_Drawing_CanvasDrawTextBlob(canvas, legendTextBlob, textX, textY);
                        // 更新下一个图例的X坐标
                        currentLegendX += OH_Drawing_RectGetWidth(textRect) + legendItemColSpace + 50.0f;

                        // 释放图例相关资源，避免内存泄漏
                        OH_Drawing_TextBlobDestroy(legendTextBlob);
                        OH_Drawing_PathDestroy(legendBlockPath);
                        OH_Drawing_RectDestroy(textRect);
                    }
                }
            };
       }  // namespace NativeModule

       // 外部C接口，供外部调用
        extern "C" {
            using namespace NativeModule;

            std::shared_ptr<ArkUIBaseNode> DrawPieChart() {
                // 创建节点
                auto column = std::make_shared<ArkUIColumnNode>();
                auto title = std::make_shared<ArkUITextNode>();
                title->SetTextContent(\"{% info.title %}\");
                title->SetFontSize(20);
                title->SetPercentWidth(1);
                title->SetPadding(15, 0, 10, 05);
                title->SetFontWeight(ARKUI_FONT_WEIGHT_W600);
                column->AddChild(title);
                auto customNode = std::make_shared<ArkUICustomRingChartNode>();
                customNode->SetPercentWidth(1);
                customNode->SetHeight(450);
                auto onClick = [customNode](ArkUI_NodeEvent *event) {
                // 从组件事件获取事件类型
                auto eventType = OH_ArkUI_NodeEvent_GetEventType(event);
                    switch (eventType) {
                        case NODE_ON_CLICK_EVENT: {
                            customNode->OnClick(event);
                        }
                        default: {
                            break;
                        }
                    }
                };
                customNode->RegisterOnClick(onClick);
                column->AddChild(customNode);
                column->SetMargin(0, 0, 15, 0);
                return column;
            }
        }  // extern "C"
   '''
}