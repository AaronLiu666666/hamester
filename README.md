# Hamster - 仓鼠

<div align=center><img src="https://github.com/AaronLiu666666/hamester/blob/master/android/app/src/main/res/mipmap-hdpi/hamester_logo.png" width="100px" height="100px"></div>

**Hamster** 是一个用于本地视频媒体文件播放和管理的安卓应用。应用名称 "Hamster"（仓鼠）寓意着像仓鼠一样收藏和管理视频。主要功能包括视频播放、标签管理和精彩时刻的标记。

## 主要功能模块

### 设置

- **媒体文件扫描目录设置**：用户可以设置应用扫描的媒体文件目录。

### 媒体库列表

- **显示媒体文件**：展示媒体文件扫描目录中的所有视频文件。
- **播放视频**：点击视频文件即可进入视频播放页面。
- **视频详情**：长按视频文件进入视频详情页面，显示视频详细信息（视频名称、时长、文件大小、标签和精彩时刻）。

### 视频详情

- **视频信息**：显示视频的详细信息，包括视频名称、时长、文件大小、标签和精彩时刻。
- **标签和精彩时刻**：点击标签进入标签详情页面，点击精彩时刻直接进入播放页面。
- **编辑视频信息**：可以设置视频文件的别名和备注信息，并删除视频（同时删除该视频的所有精彩时刻）。

### 视频播放页面

- **播放视频**：中间区域播放视频。
- **视频列表滚动条**：下方横向滚动条显示视频列表，可滚动加载和切换视频播放。
- **精彩时刻滚动条**：上方横向滚动条显示当前视频的精彩时刻，可滚动加载和切换播放。
- **播放设置**：支持设置播放倍速和全屏。
- **截取精彩时刻**：右侧中间有一个摄像机形状的按钮，点击截取当前视频画面帧，创建精彩时刻。用户可以为精彩时刻添加标签和描述信息，不存在的标签会自动创建，并使用当前精彩时刻截图作为标签封面。

### 标签列表

- **展示所有标签**：点击标签播放第一个视频的精彩时刻，视频下方滚动条显示所有打了该标签的精彩时刻列表，上方显示正播放视频的精彩时刻列表。
- **标签详情**：长按标签进入标签详情页面。

### 标签详情页面

- **标签名称**：顶部显示标签名称，使用“/”分割，点击某个层级显示该层级的标签详情。
- **标签详情**：包含三个tab页：
    - **精彩时刻列表**：展示所有打了该标签的精彩时刻，点击播放，长按进入精彩时刻详情。
    - **视频列表**：展示所有打了该标签的视频列表，点击播放，长按进入视频详情。
    - **编辑标签**：编辑标签名称和信息，修改标签封面图片，删除标签（同时删除该标签下的所有精彩时刻）。

### 关联库（精彩时刻）列表

- **展示所有精彩时刻**：每个精彩时刻的封面为其截图。点击进入播放页面，播放页面滚动列表只显示一个精彩时刻。
- **精彩时刻详情**：长按进入精彩时刻详情，修改描述信息，删除精彩时刻。

### 搜索功能

- **媒体库**：根据视频文件名、视频别名、视频标签名、精彩时刻描述模糊搜索匹配视频。
- **标签库**：根据标签名称模糊搜索。
- **关联库**：根据标签名称和精彩时刻描述模糊搜索。

### 翻页模块

- **翻页功能**：媒体库、标签库、关联库列表底部有翻页模块，可回到列表顶部、底部，翻上一页、翻下一页。

### 瀑布流功能
- **瀑布流**：长按底部导航栏媒体库、标签库、关联库进入，会以瀑布流的形式随机展示媒体卡片、标签卡片、关联（精彩时刻）卡片，点击卡片进入播放界面，长按卡片进入详情。

## 安装和使用


## bug & 优化 & new feature

### bug

- [ ] 全屏状态没有两个水平切换列表（媒体精彩时刻水平滚动条、媒体列表水平滚动条），看看能否不用chewie的全屏，chewie全屏强制初始化有点不可控
- [x] 切换全屏,从全屏回到竖屏 会从seekto或者开始位置重新播放不会保留切换前位置
- [ ] 嵌套跳转问题：如从tag info进视频info再选另一个tag进还是一开始的tag（getx不传tagId导致）
- [x] 长视频精彩时刻截图错误，thumbnail插件在seekTo过大时截图位置会不到seekTo位置（改用使用ffmpeg实现）
- [x] ffmpeg精彩时刻截图失败（命令中视频文件名没用引号包裹）
- [x] 播放一会会息屏（使用wakelock插件强制播放状态不息屏）
- [x] 播放界面 音量时间距离拖动条太近了
- [x] 列表card：文件名等name太长导致图片显示太小或不显示（改成只显示一行文本，长按悬浮展示完整文本）

### 优化

- [ ] 视频播放页面，快速重复点击精彩时刻按钮重复弹窗精彩时刻（关联）创建页面
- [ ] 精彩时刻创建 标签输入框改为可输入下拉框
- [ ] 修改标签名重名自动合并,弹出确认框（删除原标签，将原标签的关联关系关联到重名标签）
- [ ] 标签列表 点进详情搜索like %名称
- [ ] 视频播放页面快进快退10s
- [ ] 列表显示当前页、总页数、总条数 页码跳转等
- [ ] 视频时长初始化，视频时长排序功能（以及其他列表自定义排序实现）
- [ ] 视频从非开始位置播放，即seekTo不等于0情况，会先闪过一帧片头，优化等到跳到了位置再播放不要闪过片头
- [ ] 本地视频播放或者seekTo加载时长优化
- [ ] 动画、播放状态记录及恢复：在视频播放页面，创建精彩时刻应该暂停不是切换状态，并且记录进入创建页面前的状态，回来后恢复状态，瀑布流动画也是如此
- [ ] 瀑布流动画播放暂停按钮切换时图表显示有问题
- [ ] 下一页、尾页有时跳转的是当前页的末尾
- [x] 精彩时刻详情展示创建时间
- [x] 播放页面长按进入详情（关联详情/媒体详情）
- [ ] 数据库设计优化，精彩时刻-标签，应该是1对多关系，不应该是一对一
- [ ] 精彩时刻详情提供编辑功能，编辑时可以对精彩时刻删减、增加标签
- [ ] 初始化遍历扫描时，已删除或者不在扫描路径里的文件进行数据清除，清除媒体、精彩时刻
- [ ] 主页homepage下改名 标签 媒体 精彩

### new feature 

- [ ] 报表统计功能，哪天标签最多、视频标签最多之类的
- [ ] 精彩时段：视频播放页面增加一个新按钮，按一下开始记录开始moment，再按一下记录结束moment，然后弹出打标签，给时间段打标签，精彩时段
- [ ] 精彩时段：精彩时段一键导出合成视频
- [ ] 视频播放：选择bgm
- [ ] 精彩时段轮播（精彩时段就播放精彩时段，遇到精彩时刻，播放精彩时刻后n秒）
- [ ] 自定义标签详情实现：针对某些标签可单独编写自定义页面，实现更加多样详情页面
- [x] 瀑布流
- [x] 视频播放页面：精彩时刻滚动条、媒体列表滚动条（在不同位置进入显示不同媒体列表）
- [ ] 关联拓扑图（像obsidian那样的拓扑图）
- [x] 列表：上一页、下一页、首页、尾页



## 三方依赖库

### 状态管理：GetX
[get | Flutter package (pub.dev)](https://pub.dev/packages/get)

### 数据库：sqlite

### 数据库orm：floor

### 视频缩略图：video_thumbnail

### 精彩时刻截图：ffmpeg_kit_flutter

### 视频播放器：chewie

### 权限处理：permission_handler
