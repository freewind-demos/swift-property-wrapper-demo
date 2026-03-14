# Swift 属性包装器 Demo

## 简介

展示 Swift 属性包装器（@propertyWrapper）的用法。

## 启动和使用

```bash
cd swift-property-wrapper-demo
swift run
```

## 教程

### 属性包装器

使用 `@propertyWrapper` 定义，添加 `wrappedValue` 属性

### 使用方式

```swift
@PropertyWrapper var property: Type
```

### 投影值

使用 `$property` 访问投影
