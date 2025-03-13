/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package magic.utils

const BEGIN = "\u{1b}["
const RESET = "\u{1b}[0m"

protected enum Color <: ToString {
    | Red
    | Green
    | Yellow
    | Blue
    | Magenta
    | Cyan

    override public func toString(): String {
        match (this) {
            case Red     => "31"
            case Green   => "32"
            case Yellow  => "33"
            case Blue    => "34"
            case Magenta => "35"
            case Cyan    => "36"
        }
    }
}