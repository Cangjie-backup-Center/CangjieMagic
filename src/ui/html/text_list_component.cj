/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.ui.html

import magic.dsl.*
import magic.prelude.*



@jsonable
public class TextInfo {
    @field["The theme to be presented"]
    let title: String
    @field["The data information to be displayed"]
    let data: Array<String>
}

@template
func template_text_list(info: TextInfo) {
    '''
    <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>简洁百搭文本列表</title>
          <style>
        /* 列表容器样式 */
        .text-list {
          max-width: 800px;
          margin: 0 auto;
          background: hsl(0, 0%, 100%);
          border-radius: 8px;
          box-shadow: 0 2px 12px hsla(0, 0%, 0%, 0.05);
          overflow: hidden;
        }

        /* 列表标题（可选） */
        .text-list__title {
          padding: 1rem 1.5rem;
          font-size: 1.1rem;
          font-weight: 600;
          color: hsl(205, 10%, 15%);
          border-bottom: 1px solid hsl(210, 17%, 94%);
        }

        /* 列表项容器 */
        .text-list__items {
          list-style: none;
        }

        /* 列表项样式 */
        .text-list__item {
          padding: 1rem 1.5rem;
          font-size: 0.95rem;
          color: hsl(210, 9%, 31%);
          border-bottom: 1px solid hsl(210, 17%, 94%);
          transition: background-color 0.2s ease;
          cursor: default;
          display: flex;
          align-items: center;
          gap: 0.75rem;
        }

        /* 最后一项去掉下边框 */
        .text-list__item:last-child {
          border-bottom: none;
        }

        /* 悬停效果 */
        .text-list__item:hover {
          background-color: hsl(210, 17%, 98%);
        }

        /* 列表项前缀图标/标记 */
        .text-list__item::before {
          content: "";
          display: inline-block;
          width: 4px;
          height: 4px;
          border-radius: 50%;
          background-color: hsl(210, 100%, 50%);
          flex-shrink: 0;
        }

        /* 高亮列表项（可选） */
        .text-list__item--active {
          background-color: hsl(210, 100%, 97%);
          color: hsl(210, 100%, 50%);
          font-weight: 500;
        }

        .text-list__item--active::before {
          background-color: hsl(210, 100%, 50%);
          width: 6px;
          height: 6px;
        }

        /* 响应式适配 */
        @media (max-width: 576px) {
          .text-list {
            border-radius: 4px;
          }
          .text-list__item, .text-list__title {
            padding: 0.8rem 1rem;
          }
          .text-list__title {
            font-size: 1rem;
          }
          .text-list__item {
            font-size: 0.9rem;
          }
        }
      </style>
    </head>
    <body>
      <div class="text-list">
        <div class="text-list__title">{% info.title %}</div>
        <ul class="text-list__items">
          {% for item in info.data %}
          <li class="text-list__item">{% item %}</li>
          {% /for %}
        </ul>
      </div>
    </body>
    </html>
    '''
}

@tool[description: '''
    功能类型：纯文本列表，
    使用场景：以列表的形式展示信息，如步骤说明列表，
    交互特性：信息展示型，仅用于呈现信息，无交互，
    风格属性：简约通用型''',
 terminal: true
]
public func textListUI(info: TextInfo): String {
    template_text_list(info)
}