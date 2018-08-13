# CustomkeyboardView
# 一、自定数字键盘
# 二、实现计算器功能
1. CustomKeyBoardView ：显示的键盘view
2. keyModel：键盘model，定义键盘字母枚举类型， 存储键盘上btn显示的数据源。
3. KeyboardModeHandler：为处理各种类型键盘数据源，即为MVVM中的ViewModel层。
4. KeyBoardCell：自定义键盘cell，定义键盘操作枚举类型(输入数字、输入小数点、输入运算符等)。
5. WaterFallLayout：键盘的瀑布流。
