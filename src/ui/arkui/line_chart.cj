package magic.ui.arkui

import magic.dsl.*
import magic.prelude.*
import magic.jsonable.*
import std.collection.*
import stdx.encoding.json.{JsonValue, JsonObject, JsonException, JsonKind, JsonInt, JsonString, JsonBool, JsonFloat, JsonArray, JsonNull}


@jsonable
public class LineItemData {
    @field["legend"]
    let name: String
    @field["Data Information Array"]
    let data: Array<Float64>
    @field["color(0xAARRGGBB)"]
    let color: String
}

@jsonable
public class LineChartInfo {
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

@ui[
    description: "折线图：可视化展示数据随时间/维度变化的趋势走向",
    lang: "arkui",
    kind: "display"
]
public func template_line_chart(info: LineChartInfo) {
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
        #include "native_drawing/drawing_point.h"
        #include <native_drawing/drawing_round_rect.h>
        #include <sstream>
        #include <iomanip>

        namespace NativeModule {
        struct LineSeries {
            std::string name;        // 折线名称（用于图例/标识）
            std::vector<float> data; // 折线数据点
            uint32_t lineColor;      // 折线颜色（ARGB）

            LineSeries(std::string seriesName, std::vector<float> seriesData, uint32_t lColor = 0xFF0066CC)
                : name(std::move(seriesName)), data(std::move(seriesData)), lineColor(lColor) {}
        };

        struct LineCharData {
            std::string xLabel;
            std::string yLabel;
            std::vector<std::string> xAxisLabel;
            std::vector<LineSeries> data;

            LineCharData(std::string xLbl, std::string yLbl, std::vector<std::string> xAxisLbl,
                        std::vector<LineSeries> series = {})
                : xLabel(std::move(xLbl)), yLabel(std::move(yLbl)), xAxisLabel(std::move(xAxisLbl)), data(std::move(series)) {}
        };

        struct ChartPointCache {
            float screenX;          // 点的实际屏幕X坐标（绘制时计算）
            float screenY;          // 点的实际屏幕Y坐标（绘制时计算）
            int32_t seriesIndex;    // 所属折线索引
            int32_t xIndex;         // 所属X轴刻度索引
            float rawYValue;        // 点的原始Y数值（避免重复取值）

            ChartPointCache(float sX, float sY, int32_t sIdx, int32_t xIdx, float yVal)
                : screenX(sX), screenY(sY), seriesIndex(sIdx), xIndex(xIdx), rawYValue(yVal) {}
        };

        // 图表全局配置
        struct ChartConfig {
            float padding = 150.0f;              // 内边距
            float gridLineWidth = 1.0f;          // 网格线宽度
            uint32_t gridColor = 0x1A000000;     // 网格线颜色
            uint32_t axisColor = 0xFF000000;     // 坐标轴颜色
            float axisWidth = 2.0f;              // 坐标轴宽度
            float axisTickLength = 10.0f;        // 坐标轴刻度长度
            int32_t yAxisTickCount = 6;          // Y轴刻度数量
            float textSize = 40.0f;              // 刻度/图例文字大小
            float axisLabelTextSize = 40.0f;     // X/Y轴名称label文字大小
            uint32_t textColor = 0xFF000000;     // 文字颜色
            float legendItemHeight = 60.0f;      // 单个图例项高度
            uint32_t tipBoxBgColor = 0xCC2196F3;    // 提示框背景色（半透蓝色）
            uint32_t tipBoxTextColor = 0xFFFFFFFF;  // 提示框文字色（白色）
            float tipBoxTextSize = 36.0f;           // 提示框文字大小
            float tipBoxOffsetX = -20.0f;            // 提示框相对点击点X偏移（右移）
            float tipBoxOffsetY = -100.0f;          // 提示框相对点击点Y偏移（上移）
            float tipBoxBorderRadius = 8.0f;        // 提示框圆角
            float clickErrorRange = 50.0f;           // 点击容差
        };

        class ArkUICustomMultiLineChart : public ArkUINode {
        public:
            explicit ArkUICustomMultiLineChart(LineCharData chartData, ChartConfig config = ChartConfig())
                : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_CUSTOM)),
                chartInputData(std::move(chartData)), chartConfig(std::move(config)),
                isShowTipBox(false), clickRawX(0.0f), clickRawY(0.0f),
                matchXIndex(0), matchRawYValue(0.0f),
                minY(std::numeric_limits<float>::max()), maxY(std::numeric_limits<float>::min()), xPointCount(0) {
                // 注册绘制事件
                nativeModule_->addNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
                nativeModule_->registerNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_DRAW, 0, this);
                OH_ArkUI_RegisterDrawCallbackOnNodeHandle(handle_, nullptr, [](void *userData) {});
            }

            ~ArkUICustomMultiLineChart() override {
                nativeModule_->removeNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
                nativeModule_->unregisterNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_DRAW);
                OH_ArkUI_UnregisterDrawCallbackOnNodeHandle(handle_);
            }

            static std::shared_ptr<ArkUICustomMultiLineChart> Create(const LineCharData &chartData,
                                                                    const ChartConfig &config = ChartConfig()) {
                return std::make_shared<ArkUICustomMultiLineChart>(chartData, config);
            }

            void OnClick(ArkUI_NodeEvent * event) {
                if (pointCacheList.empty()) {
                    isShowTipBox = false;
                    TriggerNodeRedraw();
                    return;
                }

                // 从点击事件中获取原始触摸坐标
                auto inputEvent = OH_ArkUI_NodeEvent_GetInputEvent(event);
                float clickX  = OH_ArkUI_PointerEvent_GetX(inputEvent) * 3.25;
                float clickY = OH_ArkUI_PointerEvent_GetY(inputEvent) * 3.25;

                bool isMatched = false;
                float minMatchDistance = chartConfig.clickErrorRange; // 最大允许误差
                ChartPointCache bestMatchPoint(0, 0, 0, 0, 0);

                for (const auto &cachePoint : pointCacheList) {
                    // 找到更近的匹配点
                    if (clickX < cachePoint.screenX + minMatchDistance && clickX > cachePoint.screenX - minMatchDistance && clickY < cachePoint.screenY + minMatchDistance && clickY > cachePoint.screenY - minMatchDistance) {
                        bestMatchPoint = cachePoint;
                        isMatched = true;
                        break;
                    }
                }

                if (isMatched) {
                    // 保存匹配结果（供提示框绘制使用，无任何计算）
                    isShowTipBox = true;
                    clickRawX = clickX;
                    clickRawY = clickY;
                    matchXIndex = bestMatchPoint.xIndex;
                    matchRawYValue = bestMatchPoint.rawYValue;
                } else {
                    isShowTipBox = false;
                }

                TriggerNodeRedraw();
            }

        private:
            ChartConfig chartConfig;
            LineCharData chartInputData;
            float minY = std::numeric_limits<float>::max();
            float maxY = std::numeric_limits<float>::min();
            int32_t xPointCount = 0;
            bool isShowTipBox;       // 是否显示坐标提示框
            float clickRawX;                  // 点击原始X坐标（组件内）
            float clickRawY;                  // 点击原始Y坐标（组件内）
            int32_t matchXIndex;              // 点击匹配到的X轴刻度索引
            float matchRawYValue;             // 点击匹配到的原始Y值
            std::vector<ChartPointCache> pointCacheList;

            void ClearPointCache() {
                if (!pointCacheList.empty()) {
                    pointCacheList.clear();
                }
            }

            // 触发节点重绘的markDirty封装方法
            void TriggerNodeRedraw() {
                if (handle_) {
                    ArkUI_NativeNodeAPI_1* nodeAPI = nullptr;
                    OH_ArkUI_GetModuleInterface(ARKUI_NATIVE_NODE, ArkUI_NativeNodeAPI_1, nodeAPI);
                    nodeAPI->markDirty(handle_, NODE_NEED_RENDER);
                }
            }

            static void OnStaticCustomEvent(ArkUI_NodeCustomEvent *event) {
                auto customNode = reinterpret_cast<ArkUICustomMultiLineChart *>(OH_ArkUI_NodeCustomEvent_GetUserData(event));
                if (OH_ArkUI_NodeCustomEvent_GetEventType(event) == ARKUI_NODE_CUSTOM_EVENT_ON_DRAW) {
                    customNode->OnDraw(event);
                }
            }

            void CalculateGlobalExtremes() {
                minY = std::numeric_limits<float>::max();
                maxY = std::numeric_limits<float>::min();
                xPointCount = static_cast<int32_t>(chartInputData.xAxisLabel.size());

                for (const auto &series : chartInputData.data) {
                    // 校验：折线数据长度与X轴标签数量一致
                    if (series.data.size() != xPointCount) {
                        continue;
                    }
                    for (float yVal : series.data) {
                        minY = std::min(minY, yVal);
                        maxY = std::max(maxY, yVal);
                    }
                }

                // 边界处理：避免X/Y范围为0
                if (minY == maxY) {
                    minY--;
                    maxY++;
                }
                float yR = maxY - minY;
                minY -= yR * 0.1f;
                maxY += yR * 0.1f;
                minY = std::floor(minY);
                maxY = std::ceil(maxY);
                if (minY == maxY)
                    maxY++;
            }

            // 绘制网格线
            void DrawGrid(OH_Drawing_Canvas *canvas, const ArkUI_IntSize &size) {
                OH_Drawing_Pen *gridPen = OH_Drawing_PenCreate();
                OH_Drawing_PenSetColor(gridPen, chartConfig.gridColor);
                OH_Drawing_PenSetWidth(gridPen, chartConfig.gridLineWidth);
                OH_Drawing_PenSetAntiAlias(gridPen, true);
                OH_Drawing_CanvasAttachPen(canvas, gridPen);

                const float drawWidth = static_cast<float>(size.width) - 2 * chartConfig.padding;
                const float drawHeight = static_cast<float>(size.height) - 2 * chartConfig.padding;
                const float xStart = chartConfig.padding;
                const float yStart = chartConfig.padding;
                const float xEnd = chartConfig.padding + drawWidth;
                const float yEnd = chartConfig.padding + drawHeight;

                // 水平网格线（按Y轴刻度数量绘制）
                float yStep = drawHeight / (chartConfig.yAxisTickCount - 1);
                for (int i = 1; i < chartConfig.yAxisTickCount - 1; ++i) {
                    float y = yStart + i * yStep;
                    OH_Drawing_CanvasDrawLine(canvas, xStart, y, xEnd, y);
                }

                // 垂直网格线（按X轴数据范围均分，数量=Y轴刻度数-1）
                float xStep = drawWidth / (xPointCount - 1);
                for (int i = 1; i < xPointCount - 1; ++i) {
                    float x = xStart + i * xStep;
                    OH_Drawing_CanvasDrawLine(canvas, x, yStart, x, yEnd);
                }

                OH_Drawing_CanvasDetachPen(canvas);
                OH_Drawing_PenDestroy(gridPen);
            }

            // 绘制X/Y坐标轴
            void DrawAxis(OH_Drawing_Canvas *canvas, const ArkUI_IntSize &size) {
                // 坐标轴画笔
                OH_Drawing_Pen *axisPen = OH_Drawing_PenCreate();
                OH_Drawing_PenSetColor(axisPen, chartConfig.axisColor);
                OH_Drawing_PenSetWidth(axisPen, chartConfig.axisWidth);
                OH_Drawing_PenSetAntiAlias(axisPen, true);
                OH_Drawing_CanvasAttachPen(canvas, axisPen);

                const float drawWidth = static_cast<float>(size.width) - 2 * chartConfig.padding;
                const float drawHeight = static_cast<float>(size.height) - 2 * chartConfig.padding;
                const float xAxisY = chartConfig.padding + drawHeight; // X轴Y坐标
                const float yAxisX = chartConfig.padding;              // Y轴X坐标

                // 绘制坐标轴
                OH_Drawing_CanvasDrawLine(canvas, yAxisX, chartConfig.padding, yAxisX, xAxisY);             // Y轴
                OH_Drawing_CanvasDrawLine(canvas, yAxisX, xAxisY, chartConfig.padding + drawWidth, xAxisY); // X轴

                // 文字画刷
                OH_Drawing_Brush *textBrush = OH_Drawing_BrushCreate();
                OH_Drawing_BrushSetColor(textBrush, chartConfig.textColor);
                OH_Drawing_CanvasAttachBrush(canvas, textBrush);

                // X轴刻度（均分，显示数值）
                float xStep = drawWidth / (xPointCount - 1);
                for (int i = 0; i < xPointCount; ++i) {
                    float x = yAxisX + i * xStep;
                    // 刻度短线
                    OH_Drawing_CanvasDrawLine(canvas, x, xAxisY, x, xAxisY + chartConfig.axisTickLength);
                    std::string xText = chartInputData.xAxisLabel[i];
                    OH_Drawing_Point *textPos = OH_Drawing_PointCreate(x, xAxisY + chartConfig.axisTickLength + 35);
                    DrawText(canvas, xText.c_str(), textPos, chartConfig.textSize);
                }

                // Y轴刻度（均分，显示数值）
                float yStep = drawHeight / (chartConfig.yAxisTickCount - 1);
                for (int i = 0; i < chartConfig.yAxisTickCount; ++i) {
                    float y = xAxisY - i * yStep;
                    float yVal = minY + i * (maxY - minY) / (chartConfig.yAxisTickCount - 1);
                    std::string yTickText = std::to_string(static_cast<int>(yVal));
                    // 刻度短线
                    OH_Drawing_CanvasDrawLine(canvas, yAxisX, y, yAxisX - chartConfig.axisTickLength, y);
                    OH_Drawing_Point *textPos = OH_Drawing_PointCreate(yAxisX - chartConfig.axisTickLength - 70, y + 12);
                    DrawText(canvas, yTickText.c_str(), textPos, chartConfig.textSize);
                    OH_Drawing_PointDestroy(textPos);
                }

                if (!chartInputData.xLabel.empty()) {
                    float xLabelX = yAxisX + drawWidth / 2.0f;
                    float xLabelY = xAxisY + chartConfig.axisTickLength + 100.0f;
                    OH_Drawing_Point *xLabelPos = OH_Drawing_PointCreate(xLabelX, xLabelY);
                    DrawText(canvas, chartInputData.xLabel.c_str(), xLabelPos, chartConfig.axisLabelTextSize);
                    OH_Drawing_PointDestroy(xLabelPos);
                }

                // 绘制Y轴名称label
                if (!chartInputData.yLabel.empty()) {
                    OH_Drawing_CanvasSave(canvas);
                    float rotateCenterX = yAxisX - chartConfig.axisTickLength - 85.0f;
                    float rotateCenterY = chartConfig.padding + drawHeight / 2.0f;
                    OH_Drawing_CanvasRotate(canvas, -90.0f, rotateCenterX, rotateCenterY);
                    OH_Drawing_Point *yLabelPos = OH_Drawing_PointCreate(rotateCenterX, rotateCenterY);
                    DrawText(canvas, chartInputData.yLabel.c_str(), yLabelPos, chartConfig.axisLabelTextSize);
                    OH_Drawing_PointDestroy(yLabelPos);
                    OH_Drawing_CanvasRestore(canvas);
                }

                // 释放资源
                OH_Drawing_CanvasDetachBrush(canvas);
                OH_Drawing_CanvasDetachPen(canvas);
                OH_Drawing_BrushDestroy(textBrush);
                OH_Drawing_PenDestroy(axisPen);
            }

            // 通用文字绘制方法
            void DrawText(OH_Drawing_Canvas *canvas, const char *text, const OH_Drawing_Point *pos, float textSize) {
                OH_Drawing_Font *font = OH_Drawing_FontCreate();
                OH_Drawing_FontSetTextSize(font, textSize);
                OH_Drawing_FontSetThemeFontFollowed(font, true);
                OH_Drawing_TextBlob *textBlob =
                    OH_Drawing_TextBlobCreateFromString(text, font, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8);
                if (textBlob) {
                    float x_value, y_value;
                    // 获取X坐标
                    OH_Drawing_PointGetX(pos, &x_value);
                    // 获取Y坐标
                    OH_Drawing_PointGetY(pos, &y_value);
                    OH_Drawing_CanvasDrawTextBlob(canvas, textBlob, x_value, y_value);
                    OH_Drawing_TextBlobDestroy(textBlob);
                }
                OH_Drawing_FontDestroy(font);
            }

            // 绘制多图例
            void DrawMultiLegend(OH_Drawing_Canvas *canvas, const ArkUI_IntSize &size) {
                // 图例整体尺寸计算
                const float legendItemWidth = 120.0f;
                const float legendTotalHeight = chartConfig.legendItemHeight * chartInputData.data.size();
                const float legendX = static_cast<float>(size.width) - chartConfig.padding - legendItemWidth;
                const float legendY = chartConfig.padding + 20.0f;

                // 逐个绘制折线图例
                for (size_t i = 0; i < chartInputData.data.size(); ++i) {
                    const auto &series = chartInputData.data[i];
                    float itemY = legendY + i * chartConfig.legendItemHeight;

                    // 绘制折线标识
                    OH_Drawing_Pen *linePen = OH_Drawing_PenCreate();
                    OH_Drawing_PenSetColor(linePen, series.lineColor);
                    OH_Drawing_PenSetWidth(linePen, 3.0);
                    OH_Drawing_PenSetAntiAlias(linePen, true);
                    OH_Drawing_CanvasAttachPen(canvas, linePen);
                    OH_Drawing_CanvasDrawLine(canvas, legendX + 15, itemY - 50, legendX + 45, itemY - 50);
                    OH_Drawing_CanvasDetachPen(canvas);

                    // 绘制数据点标识
                    OH_Drawing_Brush *pointBrush = OH_Drawing_BrushCreate();
                    OH_Drawing_BrushSetColor(pointBrush, 0xFF003399);
                    OH_Drawing_CanvasAttachBrush(canvas, pointBrush);
                    OH_Drawing_Point *point = OH_Drawing_PointCreate(legendX + 30, itemY - 50);
                    OH_Drawing_CanvasDrawCircle(canvas, point, 5.0 / 2); // 图例点缩小一半
                    OH_Drawing_PointDestroy(point);
                    OH_Drawing_CanvasDetachBrush(canvas);

                    // 绘制折线名称
                    OH_Drawing_Brush *textBrush = OH_Drawing_BrushCreate();
                    OH_Drawing_BrushSetColor(textBrush, chartConfig.textColor);
                    OH_Drawing_CanvasAttachBrush(canvas, textBrush);
                    OH_Drawing_Point *textPos = OH_Drawing_PointCreate(legendX + 55, itemY - 45);
                    DrawText(canvas, series.name.c_str(), textPos, chartConfig.textSize);
                    OH_Drawing_CanvasDetachBrush(canvas);

                    // 释放单图例资源
                    OH_Drawing_BrushDestroy(pointBrush);
                    OH_Drawing_BrushDestroy(textBrush);
                    OH_Drawing_PenDestroy(linePen);
                }
            }

            // 绘制单条折线
            void DrawSingleLineSeries(OH_Drawing_Canvas *canvas, const ArkUI_IntSize &size, const LineSeries &series, int32_t seriesIndex) {
                const float drawWidth = static_cast<float>(size.width) - 2 * chartConfig.padding;
                const float drawHeight = static_cast<float>(size.height) - 2 * chartConfig.padding;
                const float xAxisY = chartConfig.padding + drawHeight;
                const float yAxisX = chartConfig.padding;
                const float xStep = drawWidth / (xPointCount - 1);
                const float yRatio = drawHeight / (maxY - minY);

                // 创建折线画笔
                OH_Drawing_Pen *linePen = OH_Drawing_PenCreate();
                OH_Drawing_PenSetColor(linePen, series.lineColor);
                OH_Drawing_PenSetWidth(linePen, 4.0);
                OH_Drawing_PenSetAntiAlias(linePen, true);
                OH_Drawing_CanvasAttachPen(canvas, linePen);

                // 创建数据点画刷
                OH_Drawing_Brush *pointBrush = OH_Drawing_BrushCreate();
                OH_Drawing_BrushSetColor(pointBrush, 0xFF003399);
                OH_Drawing_BrushSetAntiAlias(pointBrush, true);

                // 构建折线路径并绘制数据点
                OH_Drawing_Path *linePath = OH_Drawing_PathCreate();
                for (size_t i = 0; i < series.data.size(); ++i) {
                    float yVal = series.data[i];
                    float x = yAxisX + i * xStep;
                    float y = xAxisY - (yVal - minY) * yRatio;
                    i == 0 ? OH_Drawing_PathMoveTo(linePath, x, y) : OH_Drawing_PathLineTo(linePath, x, y);
                    pointCacheList.emplace_back(x, y, seriesIndex, static_cast<int32_t>(i), yVal);

                    // 绘制数据点
                    OH_Drawing_Point *circleCenter = OH_Drawing_PointCreate(x, y);
                    OH_Drawing_CanvasAttachBrush(canvas, pointBrush);
                    OH_Drawing_CanvasDrawCircle(canvas, circleCenter, 5.0);
                    OH_Drawing_CanvasDetachBrush(canvas);
                    OH_Drawing_PointDestroy(circleCenter);
                }

                // 绘制折线
                OH_Drawing_CanvasDrawPath(canvas, linePath);

                // 释放资源
                OH_Drawing_PathDestroy(linePath);
                OH_Drawing_BrushDestroy(pointBrush);
                OH_Drawing_CanvasDetachPen(canvas);
                OH_Drawing_PenDestroy(linePen);
            }

            // 绘制坐标提示框
            void DrawCoordinateTipBox(OH_Drawing_Canvas *canvas) {
                if (!isShowTipBox) return; // 未触发点击则不绘制
                if (matchXIndex < 0 || matchXIndex >= static_cast<int32_t>(chartInputData.xAxisLabel.size())) {
                    return;
                }

                float tipX = clickRawX + chartConfig.tipBoxOffsetX;
                float tipY = clickRawY + chartConfig.tipBoxOffsetY;

                std::string tipXText = "X: " + chartInputData.xAxisLabel[matchXIndex];
                std::ostringstream oss;
                oss << "Y: ";
                if (std::floor(matchRawYValue) == matchRawYValue) {
                    oss << static_cast<int>(matchRawYValue);
                } else {
                    oss << std::fixed << std::setprecision(2) << matchRawYValue;
                }
                std::string tipYText = oss.str();

                OH_Drawing_Font *font = OH_Drawing_FontCreate();
                OH_Drawing_FontSetTextSize(font, chartConfig.tipBoxTextSize);
                OH_Drawing_FontSetThemeFontFollowed(font, true);
                OH_Drawing_TextBlob* tipXTextBlob = OH_Drawing_TextBlobCreateFromString(
                    tipXText.c_str(), font, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8
                );
                OH_Drawing_TextBlob* tipYTextBlob = OH_Drawing_TextBlobCreateFromString(
                    tipYText.c_str(), font, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8
                );
                OH_Drawing_Rect* tipTextRect = OH_Drawing_RectCreate(0, 0, 0, 0);
                OH_Drawing_TextBlobGetBounds(tipXTextBlob, tipTextRect);
                float tipXTextW = OH_Drawing_RectGetWidth(tipTextRect);
                float tipXTextH = OH_Drawing_RectGetHeight(tipTextRect);
                OH_Drawing_TextBlobGetBounds(tipYTextBlob, tipTextRect);
                float tipYTextW = OH_Drawing_RectGetWidth(tipTextRect);
                float tipYTextH = OH_Drawing_RectGetHeight(tipTextRect);
                float tipTextW = std::max(tipXTextW, tipYTextW) + 50;
                float tipTextH = tipXTextH + 80 + tipYTextH;
                OH_Drawing_Brush *bgBrush = OH_Drawing_BrushCreate();
                OH_Drawing_Rect* tipBaseRect = OH_Drawing_RectCreate(tipX, tipY - 20,
                                                                tipX + tipTextW, tipY + tipTextH -20);
                OH_Drawing_BrushSetColor(bgBrush, chartConfig.tipBoxBgColor);
                OH_Drawing_CanvasAttachBrush(canvas, bgBrush);
                OH_Drawing_RoundRect *roundRect = OH_Drawing_RoundRectCreate(tipBaseRect, chartConfig.tipBoxBorderRadius, chartConfig.tipBoxBorderRadius);
                OH_Drawing_CanvasDrawRoundRect(canvas, roundRect);
                OH_Drawing_CanvasDetachBrush(canvas);

                // 5. 绘制坐标文字（居中显示）
                OH_Drawing_Brush *textBrush = OH_Drawing_BrushCreate();
                OH_Drawing_BrushSetColor(textBrush, chartConfig.tipBoxTextColor);
                OH_Drawing_CanvasAttachBrush(canvas, textBrush);
                // 文字居中位置计算
                OH_Drawing_Point *textXPos = OH_Drawing_PointCreate(
                    tipX + 20,
                    tipY + tipXTextH + 10
                );
                DrawText(canvas, tipXText.c_str(), textXPos, chartConfig.tipBoxTextSize);
                OH_Drawing_Point *textYPos = OH_Drawing_PointCreate(
                    tipX + 20,
                    tipY + tipXTextH + tipYTextH + 30
                );
                DrawText(canvas, tipYText.c_str(), textYPos, chartConfig.tipBoxTextSize);

                // 6. 释放资源
                OH_Drawing_PointDestroy(textXPos);
                OH_Drawing_PointDestroy(textYPos);
                OH_Drawing_BrushDestroy(textBrush);
                OH_Drawing_BrushDestroy(bgBrush);
                OH_Drawing_RoundRectDestroy(roundRect);
                OH_Drawing_RectDestroy(tipBaseRect);
                OH_Drawing_RectDestroy(tipTextRect);
                OH_Drawing_TextBlobDestroy(tipXTextBlob);
                OH_Drawing_TextBlobDestroy(tipYTextBlob);
                OH_Drawing_FontDestroy(font);
            }

            void OnDraw(ArkUI_NodeCustomEvent *event) {
                // 获取绘制上下文（API 12标准）
                auto drawContext = OH_ArkUI_NodeCustomEvent_GetDrawContextInDraw(event);
                auto canvas = reinterpret_cast<OH_Drawing_Canvas *>(OH_ArkUI_DrawContext_GetCanvas(drawContext));
                ArkUI_IntSize size = OH_ArkUI_DrawContext_GetSize(drawContext);

                ClearPointCache();
                CalculateGlobalExtremes();

                // 分层绘制（从底层到顶层）
                DrawGrid(canvas, size);                          // 1. 网格
                DrawAxis(canvas, size);                    // 2. 坐标轴
                DrawMultiLegend(canvas, size);             // 3. 图例
                for (size_t i = 0; i < chartInputData.data.size(); ++i) { // 4. 所有折线
                    DrawSingleLineSeries(canvas, size, chartInputData.data[i], static_cast<int32_t>(i));
                }
                DrawCoordinateTipBox(canvas);
            }
        };
       }  // namespace NativeModule

       // 外部C接口，供外部调用
        extern "C" {
            using namespace NativeModule;

            std::shared_ptr<ArkUIBaseNode> DrawLineChart() {
                std::vector<LineSeries> seriesList;
                {% for (index, lineSeries) in enumerate(info.dataArr) %}
                    std::vector<float> data_{% index %};
                    {% for point in lineSeries.data %}
                        data_{% index %}.push_back({% point %});
                    {% /for %}
                    seriesList.push_back(LineSeries(\"{% lineSeries.name %}\", data_{% index %}, {% lineSeries.color %}));
                {% /for %}

                std::vector<std::string> xAxisLabel;
                {% for label in info.xAxisLabel %}
                    xAxisLabel.push_back(\"{% label %}\");
                {% /for %}

                LineCharData chartGlobalData {\"{% info.xLabel %}\", \"{% info.yLabel %}\",  xAxisLabel, seriesList};

                auto chartNode = ArkUICustomMultiLineChart::Create(chartGlobalData);
                chartNode->SetPercentWidth(1);
                chartNode->SetHeight(250);
                chartNode->SetBackgroundColor(0xFFF5F5F5);
                auto onClick = [chartNode](ArkUI_NodeEvent *event) {
                    // 从组件事件获取事件类型
                    auto eventType = OH_ArkUI_NodeEvent_GetEventType(event);
                    switch (eventType) {
                        case NODE_ON_CLICK_EVENT: {
                            chartNode->OnClick(event);
                        }
                        default: {
                            break;
                        }
                    }
                };
                chartNode->RegisterOnClick(onClick);

                auto column = std::make_shared<ArkUIColumnNode>();
                auto title = std::make_shared<ArkUITextNode>();
                title->SetTextContent(\"{% info.title %}\");
                title->SetFontSize(20);
                title->SetPercentWidth(1);
                title->SetPadding(15, 0, 10, 05);
                title->SetFontWeight(ARKUI_FONT_WEIGHT_W600);

                column->AddChild(title);
                column->AddChild(chartNode);
                column->SetMargin(0, 0, 15, 0);
                return column;
            }
        }  // extern "C"
   '''
}