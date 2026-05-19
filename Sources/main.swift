// swift-property-wrapper-demo.swift

// ============ 基本属性包装器 ============
@propertyWrapper
struct TwelveOrLess {
    private var number: Int = 0

    var wrappedValue: Int {
        get { number }
        set { number = min(newValue, 12) }
    }
}

struct SmallRectangle {
    @TwelveOrLess var width: Int
    @TwelveOrLess var height: Int
}

var rect = SmallRectangle()
rect.width = 10
rect.height = 15
print("宽度: \(rect.width), 高度: \(rect.height)")

// ============ 带参数的属性包装器 ============
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

struct BoundedRectangle {
    @Range(range: 0...100) var width: Int
    @Range(range: 0...50) var height: Int
}

var bounded = BoundedRectangle()
bounded.width = 150
bounded.height = -10
print("限制后 - 宽度: \(bounded.width), 高度: \(bounded.height)")

// ============ 属性包装器投影 ============
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
        return self
    }
}

struct Counter {
    @Logging var count: Int
}

var counter = Counter()
counter.count = 5
print("count = \(counter.count)")
print("投影: \(counter.$count)")

// ============ 身份证验证 ============
@propertyWrapper
struct Validated {
    private var value: String = ""
    private var isValid: Bool = false

    var wrappedValue: String {
        get { value }
        set {
            value = newValue
            isValid = Self.validate(newValue)
        }
    }

    var projectedValue: Bool { isValid }

    init(wrappedValue: String = "") {
        self.value = wrappedValue
        self.isValid = Self.validate(wrappedValue)
    }

    private static func validate(_ id: String) -> Bool {
        return id.count == 18
    }
}

struct User {
    @Validated var idCard: String
}

var user = User()
user.idCard = "123456789012345678"
print("身份证: \(user.idCard), 有效: \(user.$idCard)")

user.idCard = "123"
print("身份证: \(user.idCard), 有效: \(user.$idCard)")
