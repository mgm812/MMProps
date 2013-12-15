讨论`self.property = nil`在dealloc中使用是否合理?
==============================================


### 什么情况下可以用`self.property = nil`

- 当为`private`属性时, 你可以放心的使用;


### 什么情况下需要使用`[_property release]; _property = nil`?

- 当为`public`属性时, 最好按照apple的要求来;因为`self.property = nil`会触发kvo;

