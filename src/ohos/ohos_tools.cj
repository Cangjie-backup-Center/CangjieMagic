package magic.ohos

import magic.dsl.*
import magic.prelude.*
import std.collection.{collectArray, map}
import std.time.{DateTime, Duration, TimeZone}
@When[ohos == "true"]
import ohos.ark_interop.{JSContext, JSValue, JSObject}
@When[ohos == "true"]
import ohos.base.AppLog

/**
 * Get current location information
 */
@When[ohos == "true"]
@tool[description: "Obtain the user's current location",
]
public func getCurLocation(): String {
    let requestGen = {
        ctx: JSContext =>
        let request = ctx.object()
        request["locatingPriority"] = ctx.number(1282).toJSValue()
        request["locatingTimeoutMs"] = ctx.number(10000).toJSValue()
        request.toJSValue()
    }
    ArkAPI.ohosGlobalFuncSync<String>(
        "geoLocationManager",
        "getCurrentLocation",
        {ctx => [requestGen(ctx)]},
        {
            ctx, jv =>
            let obj = jv.asObject(ctx)
            "latitude: " + obj['latitude'].toNumber().toString() + "longitude: " + obj['longitude']
                .toNumber()
                .toString()
        }
    )
}

@When[ohos == "true"]
private func combineContactInfomation(ctx: JSContext, jv: JSValue): String {
    let obj = jv.asObject(ctx)
    var result = ''
    if (obj['name'].isObject()) {
        result += 'contact name: ' + obj['name'].asObject(ctx)['fullName'].toString()
    }
    if (obj['nickName'].isObject()) {
        result += ' contact nick name: ' + obj['nickName'].asObject(ctx)['nickName'].toString()
    }
    if (obj['phoneNumbers'].isArray()) {
        for (j in 0..obj['phoneNumbers'].asArray().size) {
            let numObj = obj['phoneNumbers'].asArray()[j]
            if (numObj.isObject()) {
                if (j != 0) {
                    result += ', '
                }
                result += ' phone number: ' + numObj.asObject(ctx)['phoneNumber'].toString()
            }
        }
    }
    if (obj['emails'].isArray()) {
        for (j in 0..obj['emails'].asArray().size) {
            let emailObj = obj['emails'].asArray()[j]
            if (emailObj.isObject()) {
                if (j != 0) {
                    result += ', '
                }
                result += 'email: ' + emailObj.asObject(ctx)['email'].toString()
            }
        }
    }
    result
}

@When[ohos == "true"]
@tool[description: "Get all contacts in address book",
]
public func queryContacts(): String {
    AppLog.info("==>queryContacts0")
    let onResolve = {
        ctx: JSContext, jv: JSValue =>
            var result = ''
            AppLog.info("==>queryContacts1")
            if (jv.isArray()) {
                AppLog.info("==>queryContacts2")
                for (i in 0..jv.asArray().size) {
                    AppLog.info("==>queryContacts3")
                    let jvi =jv.asArray()[i]
                    AppLog.info("==>queryContacts4")
                    let obj = jvi.asObject(ctx)
                    AppLog.info("==>queryContacts5")
                    result += 'contact id: ' + obj['id'].toNumber().toString() + 'contact key: ' +
                        obj['key'].toString()
                    AppLog.info("==>queryContacts6")
                    result += combineContactInfomation(ctx, jvi)
                    result += '\n'
                }
            }
            AppLog.info("==>queryContacts7")
        result
    }
    ArkAPI.ohosGlobalFuncSync<String>('contact', 'queryContacts', {ctx => [ArkAPI.getAbilityContext(ctx)]}, onResolve)
}

@When[ohos == "true"]
@tool[description: "Obtain contact information by key(need to use the 'queryContacts' tool to obtain the key)",
 parameters: {
 key: "contact key"
 }
]
public func queryContact(key: String): String {
    let onResolve = {ctx: JSContext, jv: JSValue => combineContactInfomation(ctx, jv)}
    ArkAPI.ohosGlobalFuncSync<String>('contact', 'queryContact', {ctx => [ArkAPI.getAbilityContext(ctx), ctx.string(key).toJSValue()]}, onResolve)
}

@When[ohos == "true"]
@tool[description: "Add a contact to the address book",
 parameters: {
 name: "contact name",
 phoneNumbers: "contact phone number array",
 emails: "contact email array",
 nickName: "contact nickName"
 }
]
public func addContact(name: String, phoneNumbers: Array<String>, emails: Array<String>, nickName: String): String {
    let buildContect = {
        context: JSContext =>
            let contact = context.object()
        let nameObj = context.object()
        nameObj.setProperty("fullName", context.string(name).toJSValue())
        contact.setProperty("name", nameObj.toJSValue())
        var emailArr: ArrayList<JSObject> = ArrayList<JSObject>()
        for (i in 0..emails.size) {
            let emailObj = context.object()
            emailObj.setProperty("email", context.string(emails[i]).toJSValue())
            emailArr.append(emailObj)
        }
        contact.setProperty("emails", ArkAPI.toJSArray(context, emailArr.toArray(), {ctx, item => item.toJSValue()}))

        var phoneArr: ArrayList<JSObject> = ArrayList<JSObject>()
        for (i in 0..phoneNumbers.size) {
            let phoneObj = context.object()
            phoneObj.setProperty("phoneNumber", context.string(phoneNumbers[i]).toJSValue())
            phoneArr.append(phoneObj)
        }
        contact.setProperty("phoneNumbers", ArkAPI.toJSArray(context, phoneArr.toArray(), {ctx, item => item.toJSValue()}))
        let nickNameObj = context.object()
        nickNameObj.setProperty("nickName", context.string(nickName).toJSValue())
        contact.setProperty("nickName", nickNameObj.toJSValue())
        contact.toJSValue()
    }
    ArkAPI.ohosGlobalFuncSync<Unit>('contact', 'addContact', {ctx => [ArkAPI.getAbilityContext(ctx), buildContect(ctx)]})
    return "addContact sucess"
}

@When[ohos == "true"]
@tool[description: "Delete a contact to the address book",
 parameters: {
 key: "contact key"
 }
]
public func deleteContact(key: String): String {
    ArkAPI.ohosGlobalFuncSync<Unit>('contact', 'deleteContact', {ctx => [ArkAPI.getAbilityContext(ctx), ctx.string(key).toJSValue()]})
    return "deleteContact sucess"
}

@When[ohos == "true"]
@tool[description: "Add a specified event based on the user's requirements",
 parameters: {
 title: "The title of the event. If the user does not specify a title, it defaults to '(无标题)'.",
 startTime: "The start time of the event. Input format:yyyy/MM/DD HH:mm:ss, such as: 2025/01/01 10:00:00 +08:00",
 endTime: "The end time of the event. Input format:yyyy/MM/DD HH:mm:ss, such as: 2025/01/01 10:00:00 +08:00",
 reminderTime: "The time of the event reminder in minutes."
 }
]
public func addCalendarEvent(title: String, startTime: String, endTime: String, reminderTime: Array<Int64>): String {
    let calendarManager = ArkAPI.ohosGlobalFunc<JSObject>("calendarManager", "getCalendarManager",
        {ctx => [ArkAPI.getAbilityContext(ctx)]}, {ctx, jv => jv.asObject(ctx)})
    let calendar = ArkAPI.arkObjectFuncSync<JSObject>(calendarManager, "getCalendar", {ctx => []},
            {ctx, jv => jv.asObject(ctx)})
    let addParam = {
        context: JSContext =>
        let eventToAdd = context.object()
        eventToAdd.setProperty("title", context.string(title).toJSValue())
        let eventTy = ArkAPI.getModuleProperty("calendarManager", "EventType").asObject(context).getProperty('NORMAL')
        eventToAdd.setProperty("type", eventTy)
        eventToAdd.setProperty("timeZone", context.string('Asia/Shanghai').toJSValue())
        let pattern = 'yyyy/MM/dd HH:mm:ss OOOO'
        let start: DateTime = DateTime.parse(startTime, pattern)
        let end: DateTime = DateTime.parse(endTime, pattern)
        eventToAdd.setProperty("startTime",
            context.number(Float64(start.toUnixTimeStamp().toMilliseconds())).toJSValue())
        eventToAdd.setProperty("endTime",
            context.number(Float64(end.toUnixTimeStamp().toMilliseconds())).toJSValue())
        if (reminderTime.size > 0) {
            eventToAdd.setProperty("reminderTime",
                ArkAPI.toJSArray(context, reminderTime, {ctx, item => context.number(Int32(item)).toJSValue()}))
        }
        eventToAdd.toJSValue()
    }
    ArkAPI.arkObjectFuncSync<Unit>(calendar, "addEvent", {ctx => [addParam(ctx)]})
    return "addCalendarEvent Succeed"
}

@When[ohos == "true"]
@tool[description: "Delete the events from calendar(need to get the id of the event first)",
 parameters: {
 ids: "Array of event Ids",
 }
]
public func deletsCalendarEvents(ids: Array<Int64>): String {
    let calendarManager = ArkAPI.ohosGlobalFunc<JSObject>("calendarManager", "getCalendarManager",
        {ctx => [ArkAPI.getAbilityContext(ctx)]}, {ctx, jv => jv.asObject(ctx)})
    let calendar = ArkAPI.arkObjectFuncSync<JSObject>(calendarManager, "getCalendar", {ctx => []},
            {ctx, jv => jv.asObject(ctx)})
    ArkAPI.arkObjectFuncSync<Unit>(calendar, "deleteEvents", {ctx => [ArkAPI.toJSArray<Float64>(ctx, ids |> map({id: Int64 => Float64(id)}) |> collectArray)]})
    return "deletsCalendarEvents Succeed"
}

@When[ohos == "true"]
@tool[description: "Get all the events from calendar",
]
public func getCalendarEvents(): String {
    let calendarManager = ArkAPI.ohosGlobalFunc<JSObject>("calendarManager", "getCalendarManager",
        {ctx => [ArkAPI.getAbilityContext(ctx)]}, {ctx, jv => jv.asObject(ctx)})
    let calendar = ArkAPI.arkObjectFuncSync<JSObject>(calendarManager, "getCalendar", {ctx => []},
            {ctx, jv => jv.asObject(ctx)})
    let onResolve = {
        ctx: JSContext, jv: JSValue =>
        var result = ''
        if (jv.isArray()) {
            for (i in 0..jv.asArray().size) {
                let eventObj = jv.asArray()[i].asObject(ctx)
                result += eventObj['id'].toNumber().toString() + eventObj['title'].toString()
                let startTime = eventObj['startTime'].toNumber()
                let endTime = eventObj['endTime'].toNumber()
                let pattern = 'yyyy/MM/dd HH:mm:ss OOOO'
                // TODO: 通过位置获取时区
                let AISA_SH_TZ = TimeZone("Asiz/Shanghai", Duration.hour * 8)
                let start = DateTime
                    .fromUnixTimeStamp(Duration.millisecond * startTime)
                    .inTimeZone(AISA_SH_TZ)
                let end = DateTime
                    .fromUnixTimeStamp(Duration.millisecond * endTime)
                    .inTimeZone(AISA_SH_TZ)
                result += "startTime: " + start.toString(pattern) + "endTime: " + end.toString(pattern)
                result += '\n'
            }
        }
        return result
    }
    ArkAPI.arkObjectFuncSync<String>(calendar, "getEvents", {ctx => []}, onResolve)
}
