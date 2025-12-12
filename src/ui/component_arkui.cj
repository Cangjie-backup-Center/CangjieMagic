package magic.ui

import std.regex.*
import std.collection.*

public class ArkUIComponent {
    var code: String = ""
    var head: String = ""
    var nativeModule: String = ""
    var UINode: String = ""
    var mainFunc: String = ""

    public ArkUIComponent(let template: String, let index: Int64) {
        this.nativeModule = ""
        this.UINode = ""
        this.code = template
        // 提取 #include 语句
        extractIncludes(code)

        // 提取 NativeModule 命名空间中的类
        extractNativeModuleClass(code, index)

        // 提取 extern "C" 中的函数
        extractExternCFunctions(code, index)
    }

    // 提取#include语句
    func extractIncludes(content: String) {
        let includePattern = Regex("#include\\s*[<\"](.*?)[>\"]")
        let matches = includePattern.findAll(content)

        for (m in matches) {
            if (head.isEmpty()) {
                head = m.matchString(0)
            } else {
                head = "${head}\n${m.matchString(0)}"
            }
        }
    }

    // 提取namespace NativeModule中的类并添加索引后缀
    func extractNativeModuleClass(content: String, index: Int64) {
        let nativeModulePattern = Regex("namespace\\s+NativeModule\\s*\\{((?:[^{}]++|\\{(?1)\\})*)\\}")
        let nativeModuleMatch = nativeModulePattern.find(content)

        match (nativeModuleMatch) {
            case Some(r) =>
                var classContent = r.matchString(0)

                // 查找类名并添加索引后缀
                let classPattern = Regex("class\\s+(\\w+)")
                let classMatches = classPattern.findAll(classContent)

                if (index !=0) {
                    for (classMatch in classMatches) {
                        let originalClassName = classMatch.matchString(0).split(" ")[1]
                        let newClassName = "${originalClassName}_${index}"

                        // 替换类名
                        classContent = classContent.replace(originalClassName, newClassName)
                        this.code = this.code.replace(originalClassName, newClassName)
                    }
                }
                this.nativeModule = "${classContent}"
            case None =>
                // 没有找到匹配内容，保持为空
                this.nativeModule = ""
        }
    }

    func removeLastParen(s: String): String {
        if (s.size == 0) {
            return s
        }
        let runes = s.toRuneArray()
        let last = runes[runes.size - 1]
        if (last == r'(') {
            var result = ""
            for (i in 0..runes.size - 1) {
                result = result + String(runes[i])
            }
            return result
        } else {
            return s
        }
    }

    // 提取extern "C"中的函数并处理类名和函数名
    func extractExternCFunctions(content: String, index: Int64) {
        let externPattern = Regex("extern\\s+\\\"C\\\"\\s*\\{((?:[^{}]++|\\{(?1)\\})*)\\}")
        let externMatch = externPattern.find(content)
        match (externMatch) {
            case Some(r) =>
                var externContent = r.matchString(0)
                // 提取函数定义
                let functionPattern = Regex("(?m)^[\\s\\w:*&<>]+\\s+(\\w+)\\s*\\([^)]*\\)\\s*\\{(?:[^{}]*|\\{[^{}]*\\})*\\}")
                let functionMatches = functionPattern.findAll(externContent)
                var modifiedFunctions = ""
                if (index !=0) {
                    for (funcMatch in functionMatches) {
                        var funcContent = funcMatch.matchString(0)
                        // 提取函数名
                        let funcNamePattern = Regex("[\\s\\w:*&<>]+?\\s+(\\w+)\\s*\\(")
                        let funcNameMatch = funcNamePattern.find(funcContent)

                        match (funcNameMatch) {
                            case Some(nameMatch) =>
                                var originalFuncName = removeLastParen(nameMatch.matchString(0))
                                var newFuncName = "${originalFuncName}_${index}"

                                // 替换函数名
                                funcContent = funcContent.replace(originalFuncName, newFuncName)

                                // 添加到调用列表
                                let originalFuncNameArr = originalFuncName.split(" ")
                                originalFuncName = originalFuncNameArr[originalFuncNameArr.size - 1]
                                if (externContent.count(originalFuncName) == 1) {
                                    mainFunc = "${originalFuncName}_${index}"
                                }
                                externContent = externContent.replace(originalFuncName, "${originalFuncName}_${index}")
                            case _ => ()
                                // 没有找到函数名，跳过处理
                        }
                    }
                }

                UINode = externContent
            case None =>
                // 没有找到extern "C"块，保持为空
                UINode = ""
        }
    }

    public func getHead(): String {
        return head
    }

    public func getNativeModule(): String {
        return nativeModule
    }

    public func getUINode(): String {
        return UINode
    }

    public func getMainFunc(): String {
        return mainFunc
    }
}

public func mergeArkUIComponents(title: String, components: ArrayList<ArkUIComponent>, mode!: String = 'Column'): String {
    var common = '''
        #include "napi/native_api.h"
        #include <arkui/native_node.h>
        #include <arkui/native_interface.h>
        #include <arkui/native_type.h>
        #include <cassert>
        #include <list>
        #include <memory>
        #include <string>

        // 命名空间封装所有实现
        namespace NativeModule {

            // NativeModule单例类，提供NDK接口访问
            class NativeModuleInstance {
            public:
                static NativeModuleInstance* GetInstance() {
                    static NativeModuleInstance instance;
                    return &instance;
                }

                NativeModuleInstance() {
                    OH_ArkUI_GetModuleInterface(ARKUI_NATIVE_NODE, ArkUI_NativeNodeAPI_1, arkUINativeNodeApi_);
                    assert(arkUINativeNodeApi_);
                }

                ArkUI_NativeNodeAPI_1* GetNativeNodeAPI() { return arkUINativeNodeApi_; }

            private:
                ArkUI_NativeNodeAPI_1* arkUINativeNodeApi_ = nullptr;
            };

            // 基础节点类
            class ArkUIBaseNode {
            public:
                explicit ArkUIBaseNode(ArkUI_NodeHandle handle)
                    : handle_(handle), nativeModule_(NativeModuleInstance::GetInstance()->GetNativeNodeAPI()) {}

                virtual ~ArkUIBaseNode() {
                    if (!children_.empty()) {
                        for (const auto& child : children_) {
                            nativeModule_->removeChild(handle_, child->GetHandle());
                        }
                        children_.clear();
                    }
                    nativeModule_->disposeNode(handle_);
                }

                void AddChild(const std::shared_ptr<ArkUIBaseNode>& child) {
                    children_.emplace_back(child);
                    OnAddChild(child);
                }

                void RemoveChild(const std::shared_ptr<ArkUIBaseNode>& child) {
                    children_.remove(child);
                    OnRemoveChild(child);
                }

                void InsertChild(const std::shared_ptr<ArkUIBaseNode>& child, int32_t index) {
                    if (index >= children_.size()) {
                        AddChild(child);
                    } else {
                        auto iter = children_.begin();
                        std::advance(iter, index);
                        children_.insert(iter, child);
                        OnInsertChild(child, index);
                    }
                }

                ArkUI_NodeHandle GetHandle() const { return handle_; }

            protected:
                virtual void OnAddChild(const std::shared_ptr<ArkUIBaseNode>& child) {}
                virtual void OnRemoveChild(const std::shared_ptr<ArkUIBaseNode>& child) {}
                virtual void OnInsertChild(const std::shared_ptr<ArkUIBaseNode>& child, int32_t index) {}

                ArkUI_NodeHandle handle_;
                ArkUI_NativeNodeAPI_1* nativeModule_ = nullptr;

            private:
                std::list<std::shared_ptr<ArkUIBaseNode>> children_;
            };

            class ArkUINode : public ArkUIBaseNode {
            public:
                explicit ArkUINode(ArkUI_NodeHandle handle) : ArkUIBaseNode(handle) {}

                ~ArkUINode() override {}

                void SetWidth(float width) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = width}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_WIDTH, &item);
                }
                void SetPercentWidth(float percent) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = percent}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_WIDTH_PERCENT, &item);
                }
                void SetHeight(float height) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = height}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_HEIGHT, &item);
                }
                void SetPercentHeight(float percent) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = percent}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_HEIGHT_PERCENT, &item);
                }
                void SetBackgroundColor(uint32_t color) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.u32 = color}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_BACKGROUND_COLOR, &item);
                }
                void SetPadding(float top, float right, float bottom, float left) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {
                        {.f32 = top},
                        {.f32 = right},
                        {.f32 = bottom},
                        {.f32 = left}
                    };
                    ArkUI_AttributeItem item = {value, 4};
                    nativeModule_->setAttribute(handle_, NODE_PADDING, &item);
                }
                void SetMargin(float top, float right, float bottom, float left) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {
                        {.f32 = top},
                        {.f32 = right},
                        {.f32 = bottom},
                        {.f32 = left}
                    };
                    ArkUI_AttributeItem item = {value, 4};
                    nativeModule_->setAttribute(handle_, NODE_MARGIN, &item);
                }
                void SetCornerRadius(float radius) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = radius}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_BORDER_RADIUS, &item);
                }
                void SetBorderWidth(float width) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = width}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_BORDER_WIDTH, &item);
                }
                void SetBorderColor(uint32_t color) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.u32 = color}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_BORDER_COLOR, &item);
                }
                void SetAlignment(ArkUI_Alignment alignment) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = static_cast<int32_t>(alignment)}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_ALIGNMENT, &item);
                }
                void SetShadowStyle(ArkUI_ShadowStyle style) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = static_cast<int32_t>(style)}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_SHADOW, &item);
                }

            protected:
                // 组件树操作的实现类对接。
                void OnAddChild(const std::shared_ptr<ArkUIBaseNode> &child) override {
                    nativeModule_->addChild(handle_, child->GetHandle());
                }
                void OnRemoveChild(const std::shared_ptr<ArkUIBaseNode> &child) override {
                    nativeModule_->removeChild(handle_, child->GetHandle());
                }
                void OnInsertChild(const std::shared_ptr<ArkUIBaseNode> &child, int32_t index) override {
                    nativeModule_->insertChildAt(handle_, child->GetHandle(), index);
                }
            };

            class ArkUITextNode : public ArkUINode {
            public:
                ArkUITextNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_TEXT)) {}
                void SetFontSize(float fontSize) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = fontSize}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_FONT_SIZE, &item);
                }
                void SetFontWeight(ArkUI_FontWeight weight) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = static_cast<int32_t>(weight)}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_FONT_WEIGHT, &item);
                }
                void SetFontColor(uint32_t color) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.u32 = color}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_FONT_COLOR, &item);
                }
                void SetTextContent(const std::string &content) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {nullptr, 0, content.c_str()};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_CONTENT, &item);
                }
                void SetTextAlign(ArkUI_TextAlignment align) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = align}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_TEXT_ALIGN, &item);
                }
            };

            class ArkUIRowNode : public ArkUINode {
            public:
                ArkUIRowNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_ROW)) {}

                void SetJustifyContent(ArkUI_FlexAlignment align) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = align}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_ROW_JUSTIFY_CONTENT, &item);
                }
                void SetAlignItems(ArkUI_ItemAlignment align) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = align}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_ROW_ALIGN_ITEMS, &item);
                }
            };

            class ArkUIColumnNode : public ArkUINode {
            public:
                ArkUIColumnNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_COLUMN)) {}

                void SetJustifyContent(ArkUI_FlexAlignment align) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = align}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_COLUMN_JUSTIFY_CONTENT, &item);
                }
                void SetAlignItems(ArkUI_ItemAlignment align) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = align}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_COLUMN_ALIGN_ITEMS, &item);
                }
            };

            class ArkUIGridNode : public ArkUINode {
            public:
                ArkUIGridNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_GRID)) {}

                void SetColumnTemplate(const std::string& templateStr) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {};
                    item.string = const_cast<char*>(templateStr.c_str()); // 注意字符串生命周期
                    nativeModule_->setAttribute(handle_, NODE_GRID_COLUMN_TEMPLATE, &item);
                }
                void SetRowTemplate(const std::string& templateStr) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {};
                    item.string = const_cast<char*>(templateStr.c_str()); // 注意字符串生命周期
                    nativeModule_->setAttribute(handle_, NODE_GRID_ROW_TEMPLATE, &item);
                }
                void SetColumnGap(float gap) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = gap}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_GRID_COLUMN_GAP, &item);
                }
                void SetRowGap(float gap) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.f32 = gap}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_GRID_ROW_GAP, &item);
                }
                void SetNodeAdapter(const ArkUI_NodeAdapter& adapter) {
                    assert(handle_);
                    ArkUI_AttributeItem item = {};
                    item.object = const_cast<ArkUI_NodeAdapter*>(&adapter); // 注意适配器对象生命周期
                    nativeModule_->setAttribute(handle_, NODE_GRID_NODE_ADAPTER, &item);
                }
                void SetCachedCount(int32_t count) {
                    assert(handle_);
                    ArkUI_NumberValue value[] = {{.i32 = count}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_GRID_CACHED_COUNT, &item);
                }
                void SetColumns(int32_t columns) {
                    assert(handle_);
                    std::string templateStr = "repeat(" + std::to_string(columns) + ", 1fr)";
                    SetColumnTemplate(templateStr);
                }
                void SetRowSpacing(float spacing) {
                    SetRowGap(spacing);
                }
                void SetColumnSpacing(float spacing) {
                    SetColumnGap(spacing);
                }
            };

            class ArkUIGridItemNode : public ArkUINode {
            public:
                ArkUIGridItemNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_GRID_ITEM)) {}
            };

            class ArkUIFlexNode : public ArkUINode {
            public:
                ArkUIFlexNode()
                    : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_FLEX)) {}

                void SetFlexGrow(float grow) {
                    assert(handle_);
                    if (grow < 0.0f) {
                        grow = 0.0f;
                    }
                    ArkUI_NumberValue value[] = {{.f32 = grow}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_FLEX_GROW, &item);
                }

                void SetFlexShrink(float shrink) {
                    assert(handle_);
                    if (shrink < 0.0f) {
                        shrink = 1.0f;
                    }
                    ArkUI_NumberValue value[] = {{.f32 = shrink}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_FLEX_SHRINK, &item);
                }

                void SetFlexBasis(float basis) {
                    assert(handle_);
                    if (basis < 0.0f) {
                        basis = 0.0f;
                    }
                    ArkUI_NumberValue value[] = {{.f32 = basis}};
                    ArkUI_AttributeItem item = {value, 1};
                    nativeModule_->setAttribute(handle_, NODE_FLEX_BASIS, &item);
                }
            };
        }  // namespace NativeModule
    '''

    let commonComponent = ArkUIComponent(common, 0)
    var head = commonComponent.getHead()
    var nativeModule = commonComponent.getNativeModule()
    var UINode = commonComponent.getUINode()
    var returnValue = ''
    var mainCode = match (mode) {
        case "Column" =>
            returnValue = 'column'
            '''
                auto column = std::make_shared<ArkUIColumnNode>();
            '''
        case "Flex" =>
            returnValue = 'flex'
            '''
                auto flex = std::make_shared<ArkUIFlexNode>();
            '''
        case "Grid" =>
            returnValue = 'grid'
            '''
                auto grid = std::make_shared<ArkUIGridNode>();
                // grid->SetColumnTemplate("1fr 1fr 2fr");  // 3列，宽度占比1:1:2
                // grid->SetRowTemplate("1fr 1fr 2fr");     // 3行，高度占比1:1:2
            '''
        case _ => ''
    }

    let titleComp = '''
        auto title = std::make_shared<ArkUITextNode>();
        title->SetTextContent("${title}");
        title->SetFontSize(25);
        title->SetPercentWidth(1);
        title->SetPadding(15, 15, 10, 15);
        title->SetFontWeight(ARKUI_FONT_WEIGHT_W600);
        title->SetTextAlign(ARKUI_TEXT_ALIGNMENT_CENTER);
    '''
    mainCode = mainCode + '\n' + titleComp + '\n' + '${returnValue}->AddChild(title);'

    for ((i, comp) in enumerate(components)) {
        head = head + '\n' + comp.getHead()
        nativeModule = nativeModule + '\n' + comp.getNativeModule()
        UINode = UINode + '\n' + comp.getUINode()
        mainCode = mainCode + '\n' + 'auto component_${i} = ${comp.getMainFunc()}();'  + '\n' + '${returnValue}->AddChild(component_${i});'
    }
    var template = head + '\n' + nativeModule + '\n' + UINode
    template = template + '''
        extern "C" {
        using namespace NativeModule;

        std::shared_ptr<ArkUIBaseNode> CreateArkUI() {
            ${mainCode}
            return ${returnValue};
        }
        }  // extern "C"
    '''
    return template
}
