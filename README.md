# Swift 属性包装器 Demo

## 简介

本 demo 展示 Swift 属性包装器（@propertyWrapper）的用法。属性包装器是 Swift 5.1 引入的强大特性，允许我们为属性添加"包装逻辑"，在访问属性时执行自定义代码。

## 基本原理

### 什么是属性包装器？

属性包装器本质上是一个**包装属性的结构体或类**，它通过 `wrappedValue` 属性来控制属性的读取和赋值。

基本结构：

```swift
@propertyWrapper
struct WrapperName {
    private var value: Type

    var wrappedValue: Type {
        get { value }
        set { value = newValue }
    }
}
```

当我们使用 `@WrapperName var property: Type` 时：
1. 编译器创建一个隐藏的存储属性 `_property`
2. 生成计算属性 `property`，访问 `_property.wrappedValue`

### 属性包装器 vs 宏

属性包装器和 Swift 5.9+ 的 @Observable 宏有关系：
- @propertyWrapper：装饰单个属性
- @Observable：装饰整个类，让所有属性都响应式

@propertyWrapper 是 @Observable 等更高级特性的基础技术。

---

## 启动和使用

### 环境要求

- Swift 5.1+
- macOS 或 Linux

### 安装和运行

```bash
cd swift-property-wrapper-demo
swift run
```

---

## 教程

### 基本属性包装器

最简单的属性包装器：

```swift
@propertyWrapper
struct TwelveOrLess {
    private var number: Int = 0

    var wrappedValue: Int {
        get { number }
        set { number = min(newValue, 12) }
    }
}
```

使用它：

```swift
struct SmallRectangle {
    @TwelveOrLess var width: Int
    @TwelveOrLess var height: Int
}

var rect = SmallRectangle()
rect.width = 10
print(rect.width)  // 输出 10

rect.width = 15
print(rect.width)  // 输出 12（被限制最大值）
```

**原理**：每次设置 `width` 时，属性包装器的 `set` 会被调用，自动将值限制在 12 以内。

### 带参数的属性包装器

属性包装器可以接受初始化参数：

```swift
@propertyWrapper
struct Range {
    private var value: Int = 0
    let range: ClosedRange<Int>

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Int = 0, range: ClosedRange<Int>) {
        self.range = range
        self.wrappedValue = wrappedValue
    }
}
```

使用：

```swift
struct BoundedRectangle {
    @Range(range: 0...100) var width: Int
    @Range(range: 0...50) var height: Int
}

var bounded = BoundedRectangle()
bounded.width = 150    // 自动限制到 100
bounded.height = -10   // 自动限制到 0
print("宽度: \(bounded.width), 高度: \(bounded.height)")  // 100, 0
```

### 投影值（Projected Value）

属性包装器可以提供第二个访问入口——**投影值**，通过 `$property` 访问：

```swift
@propertyWrapper
struct Logging {
    private var value: Int = 0

    var wrappedValue: Int {
        get { value }
        set {
            print("设置值: \(newValue)")
            value = newValue
        }
    }

    var projectedValue: Logging {
        return self  // 投影值是包装器本身
    }
}
```

使用投影值：

```swift
struct Counter {
    @Logging var count: Int
}

var counter = Counter()
counter.count = 5           // 输出: "设置值: 5"
print("count = \(counter.count)")

// 使用投影值（$count）访问包装器本身
print("投影: \(counter.$count)")
```

投影值的常见用途：
- **验证**：返回验证结果（如 `user.$idCard` 返回是否有效）
- **元数据**：返回关于属性的额外信息
- **控制权**：提供对包装器的直接访问

### 身份证验证示例

这是一个实用的投影值示例：

```swift
@propertyWrapper
struct Validated {
    private var isValid: Bool = false

    var wrappedValue: String {
        didSet {
            isValid = validate(wrappedValue)
        }
    }

    var projectedValue: Bool { isValid }

    private func validate(_ id: String) -> Bool {
        return id.count == 18  // 简单验证：18位身份证
    }
}

struct User {
    @Validated var idCard: String
}

var user = User()
user.idCard = "123456789012345678"
print("身份证: \(user.idCard), 有效: \(user.$idCard)")  // true

user.idCard = "123"
print("身份证: \(user.idCard), 有效: \(user.$idCard)")  // false
```

**原理**：
- 每次设置 `idCard` 时，`didSet` 会自动调用验证函数
- 投影值 `$idCard` 返回验证结果布尔值

### 使用场景

属性包装器的常见用途：

1. **值限制** — 限制属性的取值范围（如上面的 Range、TwelveOrLess）
2. **自动验证** — 验证输入是否符合要求（如 Validated）
3. **延迟加载** — 第一次访问时才计算值
4. **线程安全** — 访问属性时加锁
5. **用户默认存储** — 自动读写 UserDefaults
6. **日志记录** — 记录属性访问和修改

---

## 关键代码详解

### TwelveOrLess 包装器

```swift
@propertyWrapper
struct TwelveOrLess {
    private var number: Int = 0

    var wrappedValue: Int {
        get { number }
        set { number = min(newValue, 12) }
    }
}
```

- `private var number`：实际存储值的私有属性
- `wrappedValue`：计算属性，get 时返回 number，set 时限制最大值
- `min(newValue, 12)`：确保值永远不会超过 12

### 编译器展开

当你写：

```swift
@TwelveOrLess var width: Int
```

编译器会生成类似这样的代码：

```swift
private var _width = TwelveOrLess()
var width: Int {
    get { _width.wrappedValue }
    set { _width.wrappedValue = newValue }
}
```

---

## 总结

属性包装器是 Swift 中非常强大的元编程特性：

1. **代码复用** — 把属性的通用逻辑封装到包装器中
2. **声明式语法** — 使用 `@` 语法让代码更简洁
3. **投影值** — 通过 `$` 提供额外的访问入口
4. **SwiftUI 基础** — @State、@Binding 等都是属性包装器

掌握属性包装器，能让你写出更优雅、更可维护的 Swift 代码。
