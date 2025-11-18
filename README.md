# CubeBuffer
CubeBuffer 是一个面向神经网络加速器的高维数据缓存单元，支持灵活的多维数据块访问与高效并行读写。
## 特性
- 三维地址空间：逻辑上按 S(SRAM)/B(BANK)/G(GROUP)三级坐标组织数据
- 高带宽读写：B/G 维度分别对应 BANK/GROUP，支持多路并行读写
- 多元化读写：支持基于Window+Cell的二元滑动窗口访问，支持硬件padding操作
- 多精度支持：支持 4/8/16-bit 数据格式，满足不同精度计算需求
- 可配置结构：`BANK_NUM`（8–20，对应 B 维），`GROUP_NUM`（1–15，对应 G 维）
## 应用场景
CNN/Transformer 等 AI 加速器中的特征图、权重或中间激活缓存，减少片外访存并提升计算速度。
## 使用方式
实例化顶层模块 `databuffer`，配置参数并下发指令即可：
```verilog
databuffer #(
	 .BANK_NUM(17),
	 .GROUP_NUM(10)
) u_buffer (...);
```
## 补充说明
- 多数应用场景下SRAM层级仅需要1的并行度，目前暂将S并行设定为1
- 仿真使用行为模型 SRAM_nohold（接口灵活、便于验证）；综合时替换为目标工艺库的 SRAM 实例即可。
