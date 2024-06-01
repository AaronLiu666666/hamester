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


## 三方依赖库

### 数据库：sqlite

### 数据库orm：floor

### 视频缩略图：video_thumbnail

### 精彩时刻截图：ffmpeg_kit_flutter