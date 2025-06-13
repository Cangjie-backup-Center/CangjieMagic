/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package magic.examples.fun_idea

import std.io.*
import std.collection.*
import encoding.json.*
import encoding.url.*
import net.http.*
import net.tls.*
import log.*

import magic.dsl.*
import magic.prompt.*
import magic.prelude.*
import magic.model.*
import magic.tool.*
import magic.config.Config
import magic.log.*

@jsonable
class AMapWeatherResponse {
    let status: String
    let count: String
    let info: String
    let infocode: String
    let lives: ArrayList<AMapWeatherDataLive>
}

@jsonable
class AMapWeatherDataLive {
    let province: String
    let city: String
    let adcode: String
    let weather: String
    let temperature: String
    let winddirection: String
    let windpower: String
    let humidity: String
    let reporttime: String
    let temperature_float: String
    let humidity_float: String
}

// 定义天气查询工具
@tool[description: "获取指定城市的实时天气",
      parameters = { city: "城市" }]
func getWeather(city: String): String {
    // 实际应调用天气API
    return getAmapWeather(city)

    // 或者模拟数据
    // let weatherData = HashMap<String, String>()
    // weatherData.put("北京", "晴 28℃")
    // weatherData.put("上海", "多云 25℃")
    // weatherData.put("广州", "雷阵雨 30℃")
    // weatherData.put("成都", "阴 22℃")
    //return weatherData.get(city) ?? ""
}


@agent[model: "siliconflow:deepseek-ai/DeepSeek-V3", tools: [getWeather], temperature: 0.7]
class JokeMaster {
    @prompt[pattern: APE](
        action: "结合实时天气生成幽默回复",
        purpose: "让用户在获取实用信息的同时获得快乐",
        expectation: "给出天气情况和温度数值，并给出含有天气元素的创意笑话或谐音梗"
    )
}


func getAmapWeather(city: String, extensions!: String = "base"): String {
    // 请从如下链接获取高德API Key https://console.amap.com/dev/key/app
    let AMAP_KEY = "<AMap App Key>"
    
    let url = "https://restapi.amap.com/v3/weather/weatherInfo?" + 
              "city=${city}" +
              "&extensions=${extensions}" +
              "&key=${AMAP_KEY}"

    var tlsConfig = TlsClientConfig()
    tlsConfig.verifyMode = TrustAll
    let client = ClientBuilder()
                    .tlsConfig(tlsConfig)
                    .build()

    // 构造HTTPS请求
    let request = HttpRequestBuilder()
                    .method("GET")
                    .url(url)
                    .header("Accept", "application/json")
                    .build()

    try {
        LogUtils.info("getting weather data from : ${url}")
        
        // 发送HTTP请求
        let response = client.send(request)
        
        // 处理响应
        if (response.status != 200) {
            LogUtils.info( "请求失败，状态码：${response.status}")
            return ""
        }
        

        let jsonData = JsonValue.fromStr(inputStreamToString(response.body))
        LogUtils.info("weather data result: ${jsonData.toJsonString()}")

        let weatherData = AMapWeatherResponse.fromJsonValue(jsonData)
        if (weatherData.status == "1") {
            return formatWeather(weatherData.lives[0])
        } else {
            LogUtils.info("响应数据格式异常")
            return ""
        }
    } catch (e: Exception) {
        LogUtils.info("请求异常：${e.message}")
        return ""
    }
}

func inputStreamToString(input: InputStream): String {
    let reader = StringReader(input)
    return reader.readToEnd()
}

// 格式化天气信息
private func formatWeather(data: AMapWeatherDataLive): String {
    
    let template = """
    【实时天气】
    城市：${data.city}
    天气：${data.weather}
    温度：${data.temperature}℃
    湿度：${data.humidity}%
    风向：${data.winddirection}
    风力：${data.windpower}级
    更新时间：${data.reporttime}
    """
    LogUtils.info("${template}")
    return template
}


func chat(agent: Agent, question: String) {
    println("\n")
    println("Q: ${question}")
    println("A: ${agent.chat(AgentRequest(question)).content}")
}

// 注册自定义工具
main() {
    Config.logLevel = LogLevel.INFO
    Config.logFile = "./logs/fun_idea.log"

    let jester = JokeMaster()
    
    chat(jester, "用成都天气编个熊猫谐音梗")
    chat(jester, "今天上海天气怎么样？讲个应景的笑话")
}