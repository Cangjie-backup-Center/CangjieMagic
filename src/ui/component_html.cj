package magic.ui

import std.regex.*
import std.collection.*

public class HTMLComponent {
    var css = ''
    var body = ''
    var script = ''

    public HTMLComponent(let template: String, public let index: Int64) {
        var cssParts = template.split("<style>")
        if (cssParts.size > 1) {
            let cssParts = cssParts[1].split("</style>")
            this.css += cssParts[0]
            this.css += "\n"
        }

        var bodyParts = template.split("<body>")
        if (bodyParts.size > 1) {
            bodyParts = bodyParts[1].split("<script>")
            if (bodyParts.size > 1) {
                let scriptParts = bodyParts[1].split("</script>")
                this.script += scriptParts[0]
                this.script += "\n"
                this.body += bodyParts[0]
                this.body += "\n"
            } else {
                bodyParts = bodyParts[0].split("</body>")
                this.body += bodyParts[0]
                this.body += "\n"
            }
        }
        css = css.replace("-{ num }", "_" + index.toString())
        body = body.replace("-{ num }", "_" + index.toString())
        script = script.replace("-{ num }", "_" + index.toString())
    }

    public func getCSS(): String {
        return css
    }

    public func getBody(): String {
        return body
    }

    public func getScript(): String {
        return script
    }
}

public func mergeHTMLComponents(title: String, components: ArrayList<HTMLComponent>): String {
    var css = ''
    var body = ''
    var script = ''

    for (comp in components) {
        css += comp.getCSS()
        body += comp.getBody()
        script += comp.getScript()
    }
    if (body == "") {
        return ""
    }

    var template = '''
    <!DOCTYPE html>
    <html lang="zh-CN">

    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css" rel="stylesheet">
      <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.8/dist/chart.umd.min.js"></script>
      <style>
        ${css}
      </style>
    </head>

    <body>
      <div class="inline-container">
          <h3 style="margin: 0">${title}</h3>
       </div>
      ${body}
        <script>
          ${script}
        </script>
    </body>

    </html>
    '''
    return template
}